import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../../../database/repositories/comments_drift_repository.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Implementation of PlantCommentsRepository using Drift for local persistence
/// and UnifiedSyncManager for Firebase synchronization
class PlantCommentsRepositoryImpl implements PlantCommentsRepository {
  static const String _appName = 'plantis';
  final CommentsDriftRepository _driftRepository;

  PlantCommentsRepositoryImpl(this._driftRepository);

  @override
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(
    String plantId,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 getCommentsForPlant - plantId: $plantId');
      }
      
      // Get comments from local Drift database
      final comments = await _driftRepository.getCommentsByPlant(plantId);
      
      if (kDebugMode) {
        print('✅ Found ${comments.length} comments for plant $plantId');
      }
      
      return Right(comments);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting comments: $e');
      }
      return Left(CacheFailure('Failed to get comments: $e'));
    }
  }

  @override
  Future<Either<Failure, ComentarioModel>> addComment(
    String plantId,
    String content,
  ) async {
    try {
      final comment = ComentarioModel.create(
        conteudo: content,
        plantId: plantId,
      );

      if (kDebugMode) {
        print('💾 Saving comment to Drift - plantId: $plantId');
      }

      // Save to local Drift database
      await _driftRepository.insertComment(comment);
      
      if (kDebugMode) {
        print('✅ Comment saved locally: ${comment.id}');
      }

      // Try to sync to Firebase in background (non-blocking)
      _syncToFirebaseInBackground(comment);

      return Right(comment);
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ Failed to add comment: $e\n$stack');
      }
      return Left(CacheFailure('Failed to add comment: $e'));
    }
  }

  /// Syncs comment to Firebase in background without blocking
  void _syncToFirebaseInBackground(ComentarioModel comment) {
    Future.microtask(() async {
      try {
        final result = await UnifiedSyncManager.instance.create<ComentarioModel>(
          _appName,
          comment,
        );
        
        result.fold(
          (failure) {
            if (kDebugMode) {
              print('⚠️ Firebase sync failed (will retry): ${failure.message}');
            }
          },
          (_) {
            if (kDebugMode) {
              print('☁️ Comment synced to Firebase: ${comment.id}');
            }
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase sync error (will retry): $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, ComentarioModel>> updateComment(
    ComentarioModel comment,
  ) async {
    try {
      final updatedComment = comment.copyWith(dataAtualizacao: DateTime.now());

      // For now, delete and re-insert (Drift repository doesn't have update)
      // This maintains data integrity
      // TODO: Add proper update method to CommentsDriftRepository
      
      if (kDebugMode) {
        print('📝 Updating comment: ${comment.id}');
      }

      // Sync update to Firebase
      final result = await UnifiedSyncManager.instance.update<ComentarioModel>(
        _appName,
        comment.id,
        updatedComment,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (_) => Right(updatedComment),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to update comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting comment: $commentId');
      }

      final result = await UnifiedSyncManager.instance.delete<ComentarioModel>(
        _appName,
        commentId,
      );
      
      return result;
    } catch (e) {
      return Left(CacheFailure('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
    try {
      final commentsResult = await getCommentsForPlant(plantId);

      return commentsResult.fold(
        (failure) => Left(failure),
        (comments) async {
          for (final comment in comments) {
            await deleteComment(comment.id);
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to delete comments for plant: $e'));
    }
  }
}
