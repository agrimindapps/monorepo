import 'package:core/core.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../../../core/plantis_sync_config.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Implementation of PlantCommentsRepository using the unified sync system
class PlantCommentsRepositoryImpl implements PlantCommentsRepository {
  static const String _appName = 'plantis';

  PlantCommentsRepositoryImpl();

  /// Ensure sync system is properly initialized for comments
  Future<void> _ensureSyncInitialized() async {
    try {
      await PlantisSyncConfig.configure();
    } catch (e) {
      // Log error but don't fail - will fallback to empty data
      print('Warning: Failed to initialize sync for comments: $e');
    }
  }

  @override
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(
    String plantId,
  ) async {
    try {
      // Use UnifiedSyncManager to find all comments and filter locally
      final result = await UnifiedSyncManager.instance.findAll<ComentarioModel>(
        _appName,
      );

      return result.fold(
        (failure) async {
          // If failure is because sync not initialized, try to initialize
          if (failure.message.contains('No sync repository found') ||
              failure.message.contains('not initialized')) {
            await _ensureSyncInitialized();
            // Try again after initialization
            final retryResult = await UnifiedSyncManager.instance
                .findAll<ComentarioModel>(_appName);
            return retryResult.fold((retryFailure) => Left(retryFailure), (
              comments,
            ) {
              final filteredComments =
                  comments
                      .where(
                        (comment) =>
                            !comment.isDeleted && comment.plantId == plantId,
                      )
                      .toList()
                    ..sort(
                      (a, b) => (b.dataCriacao ?? DateTime.now()).compareTo(
                        a.dataCriacao ?? DateTime.now(),
                      ),
                    );
              return Right(filteredComments);
            });
          }
          return Left(failure);
        },
        (comments) {
          // Filter out deleted comments and comments for this specific plant, then sort by creation date (newest first)
          final filteredComments =
              comments
                  .where(
                    (comment) =>
                        !comment.isDeleted && comment.plantId == plantId,
                  )
                  .toList()
                ..sort(
                  (a, b) => (b.dataCriacao ?? DateTime.now()).compareTo(
                    a.dataCriacao ?? DateTime.now(),
                  ),
                );

          return Right(filteredComments);
        },
      );
    } catch (e) {
      // Fallback: return empty list if sync not available
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, ComentarioModel>> addComment(
    String plantId,
    String content,
  ) async {
    try {
      // BUGFIX: Adicionar logs detalhados para debug
      print('📝 PlantCommentsRepository.addComment:');
      print('   Plant ID: $plantId');
      print('   Content: $content');

      // Create new comment with plant association
      final comment = ComentarioModel.create(
        conteudo: content,
        plantId: plantId,
      );

      print('   Created Comment ID: ${comment.id}');
      print('   Created Comment Date: ${comment.dataCriacao}');

      final result = await UnifiedSyncManager.instance.create<ComentarioModel>(
        _appName,
        comment,
      );

      return result.fold((failure) async {
        print('   ❌ Create failed: ${failure.message}');

        // If failure is because sync not initialized, try to initialize
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          print('   🔄 Sync not initialized, initializing...');
          await _ensureSyncInitialized();
          // Try again after initialization
          print('   🔄 Retrying create...');
          final retryResult = await UnifiedSyncManager.instance
              .create<ComentarioModel>(_appName, comment);
          return retryResult.fold(
            (retryFailure) {
              print('   ❌ Retry failed: ${retryFailure.message}');
              return Left(retryFailure);
            },
            (commentId) {
              print('   ✅ Retry succeeded, comment ID: $commentId');
              return Right(comment);
            },
          );
        }
        return Left(failure);
      }, (commentId) {
        print('   ✅ Comment created successfully, ID: $commentId');
        return Right(comment);
      });
    } catch (e, stack) {
      print('   ❌ Exception in addComment: $e');
      print('   Stack: $stack');
      return Left(CacheFailure('Failed to add comment: $e'));
    }
  }

  @override
  Future<Either<Failure, ComentarioModel>> updateComment(
    ComentarioModel comment,
  ) async {
    try {
      // Update comment with new timestamp
      final updatedComment = comment.copyWith(dataAtualizacao: DateTime.now());

      final result = await UnifiedSyncManager.instance.update<ComentarioModel>(
        _appName,
        comment.id,
        updatedComment,
      );

      return result.fold((failure) async {
        // If failure is because sync not initialized, try to initialize
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
          // Try again after initialization
          final retryResult = await UnifiedSyncManager.instance
              .update<ComentarioModel>(_appName, comment.id, updatedComment);
          return retryResult.fold(
            (retryFailure) => Left(retryFailure),
            (_) => Right(updatedComment),
          );
        }
        return Left(failure);
      }, (_) => Right(updatedComment));
    } catch (e) {
      return Left(CacheFailure('Failed to update comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      final result = await UnifiedSyncManager.instance.delete<ComentarioModel>(
        _appName,
        commentId,
      );

      return result.fold((failure) async {
        // If failure is because sync not initialized, try to initialize
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
          // Try again after initialization
          return await UnifiedSyncManager.instance.delete<ComentarioModel>(
            _appName,
            commentId,
          );
        }
        return Left(failure);
      }, (success) => Right(success));
    } catch (e) {
      return Left(CacheFailure('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
    // Get all comments for the plant and delete them
    final commentsResult = await getCommentsForPlant(plantId);

    return commentsResult.fold((failure) => Left(failure), (comments) async {
      // Delete each comment individually using UnifiedSyncManager
      for (final comment in comments) {
        final deleteResult = await UnifiedSyncManager.instance
            .delete<ComentarioModel>(_appName, comment.id);
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }
      return const Right(null);
    });
  }

  /// Clear all comments (for testing or data reset)
  Future<void> clearAllComments() async {
    // Get all comments and delete them
    final result = await UnifiedSyncManager.instance.findAll<ComentarioModel>(
      _appName,
    );
    await result.fold(
      (failure) =>
          throw Exception('Failed to get comments: ${failure.message}'),
      (comments) async {
        for (final comment in comments) {
          await UnifiedSyncManager.instance.delete<ComentarioModel>(
            _appName,
            comment.id,
          );
        }
      },
    );
  }
}
