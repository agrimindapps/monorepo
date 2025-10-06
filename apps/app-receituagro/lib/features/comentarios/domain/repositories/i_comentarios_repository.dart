import '../entities/comentario_entity.dart';

/// Repository interface for comentarios following the Repository pattern.
/// This defines the contract that data layer implementations must follow.
abstract class IComentariosRepository {
  /// Gets all comments for the current user
  Future<List<ComentarioEntity>> getAllComentarios();

  /// Gets comments by specific context identifier
  Future<List<ComentarioEntity>> getComentariosByContext(String pkIdentificador);

  /// Gets comments by tool/feature
  Future<List<ComentarioEntity>> getComentariosByTool(String ferramenta);

  /// Gets a specific comment by ID
  Future<ComentarioEntity?> getComentarioById(String id);

  /// Adds a new comment
  Future<void> addComentario(ComentarioEntity comentario);

  /// Updates an existing comment
  Future<void> updateComentario(ComentarioEntity comentario);

  /// Deletes a comment (soft delete)
  Future<void> deleteComentario(String id);

  /// Hard deletes old inactive comments for cleanup
  Future<void> cleanupOldComments();

  /// Gets user comment statistics
  Future<Map<String, int>> getUserCommentStats();

  /// Searches comments by content
  Future<List<ComentarioEntity>> searchComentarios(String query);

  /// Gets comments by context identifier (alias for getComentariosByContext)
  Future<List<ComentarioEntity>> getByContext(String pkIdentificador);

  /// Gets comments created within a date range
  Future<List<ComentarioEntity>> getCommentsByDateRange(DateTime start, DateTime end);
}
