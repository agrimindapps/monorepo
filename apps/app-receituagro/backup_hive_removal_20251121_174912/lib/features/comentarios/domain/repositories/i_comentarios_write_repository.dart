import '../entities/comentario_entity.dart';

/// Write-only repository interface for comentarios.
/// Segregated from read operations following Interface Segregation Principle.
/// 
/// Use this interface when you only need to modify comments (add, update, delete).
/// This makes it clear that the client has write permissions and responsibilities.
abstract class IComentariosWriteRepository {
  /// Adds a new comment
  Future<void> addComentario(ComentarioEntity comentario);

  /// Updates an existing comment
  Future<void> updateComentario(ComentarioEntity comentario);

  /// Deletes a comment (soft delete)
  Future<void> deleteComentario(String id);

  /// Hard deletes old inactive comments for cleanup
  Future<void> cleanupOldComments();
}
