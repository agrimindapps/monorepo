
import '../domain/entities/comentario_entity.dart';

/// Service specialized in filtering and searching comentarios
/// Principle: Single Responsibility - Only handles filtering and search logic
class ComentariosFilterService {
  /// Filters comentarios by age category
  List<ComentarioEntity> filterByAgeCategory(
    List<ComentarioEntity> comentarios,
    String category,
  ) {
    if (category == 'all') {
      return comentarios;
    }

    return comentarios.where((c) => c.ageCategory == category).toList();
  }

  /// Filters comentarios by tool/ferramenta
  List<ComentarioEntity> filterByTool(
    List<ComentarioEntity> comentarios,
    String? tool,
  ) {
    if (tool == null || tool.isEmpty) {
      return comentarios;
    }

    return comentarios.where((c) => c.ferramenta == tool).toList();
  }

  /// Filters comentarios by context/pkIdentificador
  List<ComentarioEntity> filterByContext(
    List<ComentarioEntity> comentarios,
    String? context,
  ) {
    if (context == null || context.isEmpty) {
      return comentarios;
    }

    return comentarios.where((c) => c.pkIdentificador == context).toList();
  }

  /// Performs optimized multi-term search across comentarios
  List<ComentarioEntity> search(
    List<ComentarioEntity> comentarios,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return comentarios;
    }

    final searchTerms = query
        .toLowerCase()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    return comentarios.where((comentario) {
      final searchableText =
          '${comentario.titulo} ${comentario.conteudo} ${comentario.ferramenta}'
              .toLowerCase();

      return searchTerms.every((term) => searchableText.contains(term));
    }).toList();
  }

  /// Applies all filters at once
  List<ComentarioEntity> applyAllFilters({
    required List<ComentarioEntity> comentarios,
    String? category,
    String? tool,
    String? context,
    String? searchQuery,
  }) {
    var filtered = comentarios;

    // Apply category filter
    if (category != null && category != 'all') {
      filtered = filterByAgeCategory(filtered, category);
    }

    // Apply tool filter
    if (tool != null && tool.isNotEmpty) {
      filtered = filterByTool(filtered, tool);
    }

    // Apply context filter
    if (context != null && context.isNotEmpty) {
      filtered = filterByContext(filtered, context);
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = search(filtered, searchQuery);
    }

    return filtered;
  }

  /// Generates a hash for filter state to enable caching
  String generateFilterHash({
    required int comentariosCount,
    String? category,
    String? tool,
    String? context,
    String? searchQuery,
  }) {
    return '${category ?? 'all'}_${tool ?? 'null'}_${context ?? 'null'}_${searchQuery ?? ''}_$comentariosCount';
  }
}
