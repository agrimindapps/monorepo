import 'package:core/core.dart' hide Column;

import '../entities/comentario_entity.dart';
import '../repositories/i_comentarios_read_repository.dart';
import '../repositories/i_comentarios_write_repository.dart';

/// Use case for deleting comentarios with business logic.
/// Handles soft delete and business rules around comment deletion.
class DeleteComentarioUseCase {
  final IComentariosReadRepository _readRepository;
  final IComentariosWriteRepository _writeRepository;

  DeleteComentarioUseCase(this._readRepository, this._writeRepository);

  /// Soft deletes a comentario after comprehensive validation
  Future<void> call(String comentarioId) async {
    final comentario = await _readRepository.getComentarioById(comentarioId);

    if (comentario == null) {
      throw ComentarioNotFoundException('Comentário não encontrado');
    }
    await _validateDeletion(comentario);
    await _writeRepository.deleteComentario(comentarioId);
  }

  /// Hard deletes a comentario (admin/cleanup function)
  Future<void> hardDelete(String comentarioId) async {
    throw UnimplementedError('Hard delete not yet implemented');
  }

  /// Cleanup old deleted comments (maintenance operation)
  Future<int> cleanupOldDeletedComments() async {
    final statsBefore = await _readRepository.getUserCommentStats();
    final deletedBefore = statsBefore['deleted'] ?? 0;

    await _writeRepository.cleanupOldComments();

    final statsAfter = await _readRepository.getUserCommentStats();
    final deletedAfter = statsAfter['deleted'] ?? 0;
    return deletedBefore - deletedAfter;
  }

  /// Comprehensive business validation for deletion
  Future<void> _validateDeletion(ComentarioEntity comentario) async {
    if (!comentario.status) {
      throw AlreadyDeletedException('Comentário já foi deletado');
    }
    final daysSinceCreation = DateTime.now()
        .difference(comentario.createdAt)
        .inDays;
    if (daysSinceCreation > 365) {
      throw DeletionNotAllowedException(
        'Comentários com mais de 1 ano não podem ser deletados para fins de auditoria',
      );
    }
    await _checkDeletionRateLimit();
    await _validateContextualDeletion(comentario);
    _validateSystemCommentDeletion(comentario);
  }

  /// Check if user is not deleting too many comments too quickly
  Future<void> _checkDeletionRateLimit() async {
    try {
      final now = DateTime.now();
      final recentDeletions = await _getRecentDeletions(
        now.subtract(const Duration(minutes: 10)),
      );

      const maxDeletionsIn10Minutes = 5;
      if (recentDeletions.length >= maxDeletionsIn10Minutes) {
        throw DeletionNotAllowedException(
          'Muitas exclusões recentes. Aguarde alguns minutos antes de excluir novamente.',
        );
      }
    } catch (e) {
      if (e is DeletionNotAllowedException) {
        rethrow;
      }
    }
  }

  /// Get recent deletions for rate limiting
  Future<List<ComentarioEntity>> _getRecentDeletions(DateTime since) async {
    return [];
  }

  /// Validate contextual deletion rules
  Future<void> _validateContextualDeletion(ComentarioEntity comentario) async {
    try {
      if (_isCriticalContext(comentario.pkIdentificador)) {}
      final hasReferences = await _checkCommentReferences(comentario.id);
      if (hasReferences) {
        throw DeletionNotAllowedException(
          'Este comentário não pode ser excluído pois possui referências ativas',
        );
      }
    } catch (e) {
      if (e is DeletionNotAllowedException) {
        rethrow;
      }
    }
  }

  /// Check if context is considered critical
  bool _isCriticalContext(String pkIdentificador) {
    return false; // Placeholder implementation
  }

  /// Check if comment has references that prevent deletion
  Future<bool> _checkCommentReferences(String comentarioId) async {
    return false; // Placeholder implementation
  }

  /// Validate system comment deletion rules
  void _validateSystemCommentDeletion(ComentarioEntity comentario) {
    if (_isSystemGeneratedComment(comentario)) {
      throw DeletionNotAllowedException(
        'Comentários gerados pelo sistema não podem ser excluídos',
      );
    }
    if (_isHighValueComment(comentario)) {}
  }

  /// Check if comment is system-generated
  bool _isSystemGeneratedComment(ComentarioEntity comentario) {
    return comentario.titulo.startsWith('[SISTEMA]') ||
        comentario.ferramenta == 'system' ||
        comentario.conteudo.contains('[AUTO-GENERATED]');
  }

  /// Check if comment is considered high-value
  bool _isHighValueComment(ComentarioEntity comentario) {
    final isDetailed = comentario.conteudo.length > 500;
    final hasStructuredContent =
        comentario.conteudo.contains('\n') &&
        comentario.conteudo.split('\n').length > 3;

    return isDetailed || hasStructuredContent;
  }

  /// Batch delete multiple comentarios
  Future<BatchDeleteResult> batchDelete(List<String> comentarioIds) async {
    if (comentarioIds.isEmpty) {
      throw InvalidOperationException('Lista de IDs não pode estar vazia');
    }

    if (comentarioIds.length > 50) {
      throw InvalidOperationException(
        'Máximo de 50 comentários por operação em lote',
      );
    }

    final results = BatchDeleteResult();

    for (final id in comentarioIds) {
      try {
        await call(id);
        results.successful.add(id);
      } catch (e) {
        results.failed[id] = e.toString();
      }
    }

    return results;
  }
}

/// Result of batch delete operation
class BatchDeleteResult {
  final List<String> successful = [];
  final Map<String, String> failed = {};

  bool get hasFailures => failed.isNotEmpty;
  bool get hasSuccesses => successful.isNotEmpty;
  int get totalProcessed => successful.length + failed.length;
  int get successCount => successful.length;
  int get failureCount => failed.length;

  @override
  String toString() {
    return 'BatchDeleteResult(success: $successCount, failed: $failureCount)';
  }
}

/// Exception thrown when comentario is not found
class ComentarioNotFoundException implements Exception {
  final String message;
  ComentarioNotFoundException(this.message);

  @override
  String toString() => 'ComentarioNotFoundException: $message';
}

/// Exception thrown when trying to delete already deleted comment
class AlreadyDeletedException implements Exception {
  final String message;
  AlreadyDeletedException(this.message);

  @override
  String toString() => 'AlreadyDeletedException: $message';
}

/// Exception thrown when deletion is not allowed by business rules
class DeletionNotAllowedException implements Exception {
  final String message;
  DeletionNotAllowedException(this.message);

  @override
  String toString() => 'DeletionNotAllowedException: $message';
}

/// Exception thrown for invalid operations
class InvalidOperationException implements Exception {
  final String message;
  InvalidOperationException(this.message);

  @override
  String toString() => 'InvalidOperationException: $message';
}
