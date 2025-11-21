import '../entities/comentario_entity.dart';

/// Read-only repository interface for comentarios.
/// Segregated from write operations following Interface Segregation Principle.
/// 
/// Use this interface when you only need to read comments (queries, searches, stats).
/// This makes it clear that the client doesn't need write permissions.
abstract class IComentariosReadRepository {
  /// Gets all comments for the current user
  Future<List<ComentarioEntity>> getAllComentarios();

  /// Gets comments by specific context identifier
  Future<List<ComentarioEntity>> getComentariosByContext(String pkIdentificador);

  /// Gets comments by tool/feature
  Future<List<ComentarioEntity>> getComentariosByTool(String ferramenta);

  /// Gets a specific comment by ID
  Future<ComentarioEntity?> getComentarioById(String id);

  /// Gets user comment statistics
  Future<Map<String, int>> getUserCommentStats();

  /// Searches comments by content
  Future<List<ComentarioEntity>> searchComentarios(String query);

  /// Gets comments by context identifier (alias for getComentariosByContext)
  Future<List<ComentarioEntity>> getByContext(String pkIdentificador);

  /// Gets comments created within a date range
  Future<List<ComentarioEntity>> getCommentsByDateRange(DateTime start, DateTime end);
}
