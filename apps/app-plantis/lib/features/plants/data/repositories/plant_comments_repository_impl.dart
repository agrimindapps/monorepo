import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

import '../../../../core/data/models/comentario_model.dart';
import '../../domain/repositories/plant_comments_repository.dart';

/// Implementation of PlantCommentsRepository using Hive for local storage
class PlantCommentsRepositoryImpl implements PlantCommentsRepository {
  static const String _boxName = 'plant_comments';
  Box<ComentarioModel>? _box;

  /// Initialize the Hive box for comments
  Future<void> _ensureBoxOpen() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ComentarioModel>(_boxName);
    }
  }

  /// Get key format for storing comments by plant
  String _getPlantCommentsPrefix(String plantId) => 'plant_$plantId';

  @override
  Future<Either<Failure, List<ComentarioModel>>> getCommentsForPlant(String plantId) async {
    try {
      await _ensureBoxOpen();
      
      final prefix = _getPlantCommentsPrefix(plantId);
      final comments = <ComentarioModel>[];
      
      // Filter comments for the specific plant
      for (final key in _box!.keys) {
        if (key.toString().startsWith(prefix)) {
          final comment = _box!.get(key);
          if (comment != null && !comment.isDeleted) {
            comments.add(comment);
          }
        }
      }
      
      // Sort by creation date (newest first)
      comments.sort((a, b) => (b.dataCriacao ?? DateTime.now())
          .compareTo(a.dataCriacao ?? DateTime.now()));
      
      return Right(comments);
    } catch (e) {
      return const Left(CacheFailure('Erro ao carregar comentários'));
    }
  }

  @override
  Future<Either<Failure, ComentarioModel>> addComment(String plantId, String content) async {
    try {
      await _ensureBoxOpen();
      
      // Create new comment
      final comment = ComentarioModel.create(
        conteudo: content,
        // Optionally add userId if available from auth context
      );
      
      // Generate unique key for this plant's comment
      final key = '${_getPlantCommentsPrefix(plantId)}_${comment.id}';
      
      // Store in Hive
      await _box!.put(key, comment);
      
      return Right(comment);
    } catch (e) {
      return const Left(CacheFailure('Erro ao adicionar comentário'));
    }
  }

  @override
  Future<Either<Failure, ComentarioModel>> updateComment(ComentarioModel comment) async {
    try {
      await _ensureBoxOpen();
      
      // Find the key for this comment
      String? commentKey;
      for (final key in _box!.keys) {
        final existingComment = _box!.get(key);
        if (existingComment?.id == comment.id) {
          commentKey = key.toString();
          break;
        }
      }
      
      if (commentKey == null) {
        return const Left(NotFoundFailure('Comentário não encontrado'));
      }
      
      // Update comment with new timestamp
      final updatedComment = comment.copyWith(
        dataAtualizacao: DateTime.now(),
        isDirty: true,
      );
      
      await _box!.put(commentKey, updatedComment);
      
      return Right(updatedComment);
    } catch (e) {
      return const Left(CacheFailure('Erro ao atualizar comentário'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await _ensureBoxOpen();
      
      // Find and mark comment as deleted (soft delete)
      String? commentKey;
      for (final key in _box!.keys) {
        final comment = _box!.get(key);
        if (comment?.id == commentId) {
          commentKey = key.toString();
          break;
        }
      }
      
      if (commentKey == null) {
        return const Left(NotFoundFailure('Comentário não encontrado'));
      }
      
      final comment = _box!.get(commentKey);
      if (comment != null) {
        final deletedComment = comment.copyWith(
          isDeleted: true,
          isDirty: true,
        );
        await _box!.put(commentKey, deletedComment);
      }
      
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Erro ao excluir comentário'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsForPlant(String plantId) async {
    try {
      await _ensureBoxOpen();
      
      final prefix = _getPlantCommentsPrefix(plantId);
      final keysToDelete = <String>[];
      
      // Find all comments for this plant
      for (final key in _box!.keys) {
        if (key.toString().startsWith(prefix)) {
          keysToDelete.add(key.toString());
        }
      }
      
      // Delete all comments for the plant
      for (final key in keysToDelete) {
        await _box!.delete(key);
      }
      
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Erro ao excluir comentários da planta'));
    }
  }

  /// Clear all comments (for testing or data reset)
  Future<void> clearAllComments() async {
    try {
      await _ensureBoxOpen();
      await _box!.clear();
    } catch (e) {
      throw Exception('Erro ao limpar todos os comentários: $e');
    }
  }

  /// Close the Hive box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}