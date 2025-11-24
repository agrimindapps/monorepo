

/// Service specialized in validating search filters
/// Principle: Single Responsibility - Only handles validation logic

class BuscaValidationService {
  /// Checks if at least one filter is active
  bool hasActiveFilters({
    required String? culturaId,
    required String? pragaId,
    required String? defensivoId,
  }) {
    return culturaId != null || pragaId != null || defensivoId != null;
  }

  /// Validates search parameters before executing search
  /// Returns error message if validation fails, null if valid
  String? validateSearchParams({
    required String? culturaId,
    required String? pragaId,
    required String? defensivoId,
  }) {
    if (!hasActiveFilters(
      culturaId: culturaId,
      pragaId: pragaId,
      defensivoId: defensivoId,
    )) {
      return 'Selecione pelo menos um filtro para realizar a busca';
    }

    return null; // Valid
  }

  /// Builds a text description of active filters
  String buildFiltrosAtivosTexto({
    required String? culturaId,
    required String? pragaId,
    required String? defensivoId,
  }) {
    final filtros = <String>[];

    if (culturaId != null) filtros.add('Cultura');
    if (pragaId != null) filtros.add('Praga');
    if (defensivoId != null) filtros.add('Defensivo');

    return filtros.join(', ');
  }

  /// Counts active filters
  int countActiveFilters({
    required String? culturaId,
    required String? pragaId,
    required String? defensivoId,
  }) {
    int count = 0;

    if (culturaId != null) count++;
    if (pragaId != null) count++;
    if (defensivoId != null) count++;

    return count;
  }
}
