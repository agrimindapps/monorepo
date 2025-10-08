import 'package:core/core.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Implementation of PlantCommentsRepository using the unified sync system
@LazySingleton(as: PlantCommentsRepository)
class PlantCommentsRepositoryImpl implements PlantCommentsRepository {
  static const String _appName = 'plantis';

  PlantCommentsRepositoryImpl();

  /// Ensure sync system is properly initialized for comments
  Future<void> _ensureSyncInitialized() async {
    // Sync system removed - no initialization needed
  }

  @override
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(
    String plantId,
  ) async {
    try {
      print('🔍 getCommentsForPlant - Type: $ComentarioModel');
      print('   App: $_appName');
      final result = await UnifiedSyncManager.instance.findAll<ComentarioModel>(
        _appName,
      );
      if (result.isLeft()) {
        final failure = result.fold(
          (l) => l,
          (r) => throw Exception('Unreachable'),
        );
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
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
      }
      final comments = result.fold(
        (l) => throw Exception('Unreachable'),
        (r) => r,
      );
      final filteredComments =
          comments
              .where(
                (comment) => !comment.isDeleted && comment.plantId == plantId,
              )
              .toList()
            ..sort(
              (a, b) => (b.dataCriacao ?? DateTime.now()).compareTo(
                a.dataCriacao ?? DateTime.now(),
              ),
            );

      return Right(filteredComments);
    } catch (e) {
      return const Right([]);
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

      final result = await UnifiedSyncManager.instance.create<ComentarioModel>(
        _appName,
        comment,
      );
      if (result.isLeft()) {
        final failure = result.fold(
          (l) => l,
          (r) => throw Exception('Unreachable'),
        );
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
          final retryResult = await UnifiedSyncManager.instance
              .create<ComentarioModel>(_appName, comment);
          if (retryResult.isRight()) {
            _forceImmediateSync();
          }

          return retryResult.fold(
            (retryFailure) => Left(retryFailure),
            (commentId) => Right(comment),
          );
        }
        return Left(failure);
      }
      _forceImmediateSync();
      return Right(comment);
    } catch (e, stack) {
      print('Failed to add comment: $e\n$stack');
      return Left(CacheFailure('Failed to add comment: $e'));
    }
  }

  /// Forces immediate sync of comments to Firebase
  void _forceImmediateSync() {
    UnifiedSyncManager.instance.forceSyncEntity<ComentarioModel>(_appName).then(
      (Either<Failure, void> result) {
        result.fold(
          (Failure failure) =>
              print('Background sync failed: ${failure.message}'),
          (_) => print('Comment synced to Firebase successfully'),
        );
      },
    );
  }

  @override
  Future<Either<Failure, ComentarioModel>> updateComment(
    ComentarioModel comment,
  ) async {
    try {
      final updatedComment = comment.copyWith(dataAtualizacao: DateTime.now());

      final result = await UnifiedSyncManager.instance.update<ComentarioModel>(
        _appName,
        comment.id,
        updatedComment,
      );
      if (result.isLeft()) {
        final failure = result.fold(
          (l) => l,
          (r) => throw Exception('Unreachable'),
        );
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
          final retryResult = await UnifiedSyncManager.instance
              .update<ComentarioModel>(_appName, comment.id, updatedComment);
          return retryResult.fold(
            (retryFailure) => Left(retryFailure),
            (_) => Right(updatedComment),
          );
        }
        return Left(failure);
      }
      return Right(updatedComment);
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
      if (result.isLeft()) {
        final failure = result.fold(
          (l) => l,
          (r) => throw Exception('Unreachable'),
        );
        if (failure.message.contains('No sync repository found') ||
            failure.message.contains('not initialized')) {
          await _ensureSyncInitialized();
          return await UnifiedSyncManager.instance.delete<ComentarioModel>(
            _appName,
            commentId,
          );
        }
        return Left(failure);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
    final commentsResult = await getCommentsForPlant(plantId);

    return commentsResult.fold((failure) => Left(failure), (comments) async {
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
