import '../entities/comentario_entity.dart';
import '../repositories/i_comentarios_repository.dart';

/// Use case for deleting comentarios with business logic.
/// Handles soft delete and business rules around comment deletion.
class DeleteComentarioUseCase {
  final IComentariosRepository _repository;

  DeleteComentarioUseCase(this._repository);

  /// Soft deletes a comentario after comprehensive validation
  Future<void> call(String comentarioId) async {
    // Get the comentario first to validate
    final comentario = await _repository.getComentarioById(comentarioId);
    
    if (comentario == null) {
      throw ComentarioNotFoundException('Comentário não encontrado');
    }

    // Comprehensive business validation (async)
    await _validateDeletion(comentario);
    
    // Perform soft delete
    await _repository.deleteComentario(comentarioId);
  }

  /// Hard deletes a comentario (admin/cleanup function)
  Future<void> hardDelete(String comentarioId) async {
    // This would be used for admin purposes or cleanup
    // Implementation would depend on repository capabilities
    throw UnimplementedError('Hard delete not yet implemented');
  }

  /// Cleanup old deleted comments (maintenance operation)
  Future<int> cleanupOldDeletedComments() async {
    final statsBefore = await _repository.getUserCommentStats();
    final deletedBefore = statsBefore['deleted'] ?? 0;
    
    await _repository.cleanupOldComments();
    
    final statsAfter = await _repository.getUserCommentStats();
    final deletedAfter = statsAfter['deleted'] ?? 0;
    
    // Return number of comments cleaned up
    return deletedBefore - deletedAfter;
  }

  /// Comprehensive business validation for deletion
  Future<void> _validateDeletion(ComentarioEntity comentario) async {
    // Business rule: Only active comments can be deleted
    if (!comentario.status) {
      throw AlreadyDeletedException('Comentário já foi deletado');
    }

    // Business rule: Comments older than 1 year cannot be deleted
    // (for audit purposes)
    final daysSinceCreation = DateTime.now().difference(comentario.createdAt).inDays;
    if (daysSinceCreation > 365) {
      throw DeletionNotAllowedException(
        'Comentários com mais de 1 ano não podem ser deletados para fins de auditoria'
      );
    }

    // Business rule: Rate limiting for deletions
    await _checkDeletionRateLimit();

    // Business rule: Context-specific deletion rules
    await _validateContextualDeletion(comentario);

    // Business rule: Check for important/system comments
    _validateSystemCommentDeletion(comentario);
  }

  /// Check if user is not deleting too many comments too quickly
  Future<void> _checkDeletionRateLimit() async {
    try {
      final now = DateTime.now();
      final recentDeletions = await _getRecentDeletions(now.subtract(const Duration(minutes: 10)));
      
      const maxDeletionsIn10Minutes = 5;
      if (recentDeletions.length >= maxDeletionsIn10Minutes) {
        throw DeletionNotAllowedException(
          'Muitas exclusões recentes. Aguarde alguns minutos antes de excluir novamente.'
        );
      }
    } catch (e) {
      if (e is DeletionNotAllowedException) {
        rethrow;
      }
      // If we can't check rate limits, allow deletion
    }
  }

  /// Get recent deletions for rate limiting
  Future<List<ComentarioEntity>> _getRecentDeletions(DateTime since) async {
    // This would typically query deleted comments with timestamps
    // For now, return empty list as we don't have access to deletion history
    return [];
  }

  /// Validate contextual deletion rules
  Future<void> _validateContextualDeletion(ComentarioEntity comentario) async {
    try {
      // Business rule: Comments in certain contexts might have special rules
      // For example, comments on critical diagnostics might require admin approval
      
      // Check if this is a critical context
      if (_isCriticalContext(comentario.pkIdentificador)) {
        // In a real app, this might check user permissions
        // For now, we'll allow deletion but log it
      }

      // Check if comment has references or dependencies
      final hasReferences = await _checkCommentReferences(comentario.id);
      if (hasReferences) {
        throw DeletionNotAllowedException(
          'Este comentário não pode ser excluído pois possui referências ativas'
        );
      }
    } catch (e) {
      if (e is DeletionNotAllowedException) {
        rethrow;
      }
      // Graceful handling for context validation errors
    }
  }

  /// Check if context is considered critical
  bool _isCriticalContext(String pkIdentificador) {
    // This would implement business logic to identify critical contexts
    // For example, certain diseases or pests might be marked as critical
    return false; // Placeholder implementation
  }

  /// Check if comment has references that prevent deletion
  Future<bool> _checkCommentReferences(String comentarioId) async {
    // In a real implementation, this would check:
    // - If comment is referenced by other comments
    // - If comment is bookmarked by many users
    // - If comment is part of a knowledge base entry
    return false; // Placeholder implementation
  }

  /// Validate system comment deletion rules
  void _validateSystemCommentDeletion(ComentarioEntity comentario) {
    // Business rule: Certain comments might be marked as system-generated
    // and should not be deletable by regular users
    
    if (_isSystemGeneratedComment(comentario)) {
      throw DeletionNotAllowedException(
        'Comentários gerados pelo sistema não podem ser excluídos'
      );
    }

    // Business rule: High-value comments (with many interactions) need confirmation
    if (_isHighValueComment(comentario)) {
      // In a real app, this might require additional confirmation
      // For now, we'll allow it but could add a warning mechanism
    }
  }

  /// Check if comment is system-generated
  bool _isSystemGeneratedComment(ComentarioEntity comentario) {
    // Check for system-generated patterns
    return comentario.titulo.startsWith('[SISTEMA]') ||
           comentario.ferramenta == 'system' ||
           comentario.conteudo.contains('[AUTO-GENERATED]');
  }

  /// Check if comment is considered high-value
  bool _isHighValueComment(ComentarioEntity comentario) {
    // Business logic to identify valuable comments
    // Could be based on length, quality indicators, user engagement, etc.
    
    final isDetailed = comentario.conteudo.length > 500;
    final hasStructuredContent = comentario.conteudo.contains('\n') && 
                                comentario.conteudo.split('\n').length > 3;
    
    return isDetailed || hasStructuredContent;
  }

  /// Batch delete multiple comentarios
  Future<BatchDeleteResult> batchDelete(List<String> comentarioIds) async {
    if (comentarioIds.isEmpty) {
      throw InvalidOperationException('Lista de IDs não pode estar vazia');
    }

    if (comentarioIds.length > 50) {
      throw InvalidOperationException('Máximo de 50 comentários por operação em lote');
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