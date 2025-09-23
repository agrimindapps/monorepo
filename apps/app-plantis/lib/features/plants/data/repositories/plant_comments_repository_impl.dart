import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Implementation of PlantCommentsRepository using the unified sync system
class PlantCommentsRepositoryImpl implements PlantCommentsRepository {
  static const String _appName = 'plantis';

  PlantCommentsRepositoryImpl();

  @override
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(String plantId) async {
    // Use UnifiedSyncManager to find all comments and filter locally
    final result = await UnifiedSyncManager.instance.findAll<ComentarioModel>(_appName);
    
    return result.fold(
      (failure) => Left(failure),
      (comments) {
        // Filter out deleted comments and comments for this specific plant, then sort by creation date (newest first)
        final filteredComments = comments
            .where((comment) => !comment.isDeleted && comment.plantId == plantId)
            .toList()
          ..sort((a, b) => (b.dataCriacao ?? DateTime.now())
              .compareTo(a.dataCriacao ?? DateTime.now()));
        
        return Right(filteredComments);
      },
    );
  }

  @override
  Future<Either<Failure, ComentarioModel>> addComment(String plantId, String content) async {
    // Create new comment with plant association
    final comment = ComentarioModel.create(
      conteudo: content,
      plantId: plantId,
    );

    final result = await UnifiedSyncManager.instance.create<ComentarioModel>(_appName, comment);
    
    return result.fold(
      (failure) => Left(failure),
      (commentId) => Right(comment),
    );
  }

  @override
  Future<Either<Failure, ComentarioModel>> updateComment(ComentarioModel comment) async {
    // Update comment with new timestamp
    final updatedComment = comment.copyWith(
      dataAtualizacao: DateTime.now(),
    );
    
    final result = await UnifiedSyncManager.instance.update<ComentarioModel>(_appName, comment.id, updatedComment);
    
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(updatedComment),
    );
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    return await UnifiedSyncManager.instance.delete<ComentarioModel>(_appName, commentId);
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
    // Get all comments for the plant and delete them
    final commentsResult = await getCommentsForPlant(plantId);
    
    return commentsResult.fold(
      (failure) => Left(failure),
      (comments) async {
        // Delete each comment individually using UnifiedSyncManager
        for (final comment in comments) {
          final deleteResult = await UnifiedSyncManager.instance.delete<ComentarioModel>(_appName, comment.id);
          if (deleteResult.isLeft()) {
            return deleteResult;
          }
        }
        return const Right(null);
      },
    );
  }

  /// Clear all comments (for testing or data reset)
  Future<void> clearAllComments() async {
    // Get all comments and delete them
    final result = await UnifiedSyncManager.instance.findAll<ComentarioModel>(_appName);
    await result.fold(
      (failure) => throw Exception('Failed to get comments: ${failure.message}'),
      (comments) async {
        for (final comment in comments) {
          await UnifiedSyncManager.instance.delete<ComentarioModel>(_appName, comment.id);
        }
      },
    );
  }
}