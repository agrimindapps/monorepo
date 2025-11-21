import '../../domain/entities/comentario_entity.dart';

/// Service responsible for search and filtering logic for comments.
///
/// This service encapsulates search, filtering, and date range logic,
/// separating it from the repository to improve Single Responsibility
/// Principle (SRP) compliance.
///
/// Responsibilities:
/// - Searching comments by content
/// - Filtering by date range
/// - Future extensibility for advanced search strategies
abstract class IComentariosSearchService {
  /// Search comments by query string (checks titulo, conteudo, ferramenta)
  List<ComentarioEntity> searchByQuery(
    List<ComentarioEntity> comments,
    String query,
  );

  /// Filter comments by date range
  List<ComentarioEntity> filterByDateRange(
    List<ComentarioEntity> comments,
    DateTime start,
    DateTime end,
  );

  /// Combine search and date filtering
  List<ComentarioEntity> searchAndFilter(
    List<ComentarioEntity> comments, {
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Default implementation of search logic
class ComentariosSearchService implements IComentariosSearchService {
  @override
  List<ComentarioEntity> searchByQuery(
    List<ComentarioEntity> comments,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return comments;
    }

    final queryLower = query.toLowerCase();
    return comments.where((comentario) {
      return comentario.conteudo.toLowerCase().contains(queryLower) ||
          comentario.titulo.toLowerCase().contains(queryLower) ||
          comentario.ferramenta.toLowerCase().contains(queryLower);
    }).toList();
  }

  @override
  List<ComentarioEntity> filterByDateRange(
    List<ComentarioEntity> comments,
    DateTime start,
    DateTime end,
  ) {
    return comments.where((comentario) {
      return comentario.createdAt.isAfter(start) &&
          comentario.createdAt.isBefore(end);
    }).toList();
  }

  @override
  List<ComentarioEntity> searchAndFilter(
    List<ComentarioEntity> comments, {
    String? query,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var results = comments;

    // Apply search query if provided
    if (query != null && query.isNotEmpty) {
      results = searchByQuery(results, query);
    }

    // Apply date range filter if provided
    if (startDate != null && endDate != null) {
      results = filterByDateRange(results, startDate, endDate);
    }

    return results;
  }
}
