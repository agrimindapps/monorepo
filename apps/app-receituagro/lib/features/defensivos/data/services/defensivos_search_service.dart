

import '../../domain/entities/defensivo_entity.dart';

/// Service responsible for searching defensivos.
///
/// This service encapsulates search logic, separating it from the repository
/// to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Search defensivos by query string (nome comum, técnico, ingrediente ativo)
/// - Support custom search filters
abstract class IDefensivosSearchService {
  /// Search defensivos by query string
  /// Searches in: nomeComum, nomeTecnico, ingredienteAtivo
  List<DefensivoEntity> search(
    List<DefensivoEntity> defensivos,
    String query,
  );

  /// Search with custom predicate function
  List<DefensivoEntity> searchCustom(
    List<DefensivoEntity> defensivos,
    bool Function(DefensivoEntity) predicate,
  );

  /// Search by multiple fields with specific matching logic
  List<DefensivoEntity> searchAdvanced(
    List<DefensivoEntity> defensivos, {
    String? nomeQuery,
    String? ingredienteQuery,
    String? classeQuery,
  });
}

/// Default implementation of search service

class DefensivosSearchService implements IDefensivosSearchService {
  @override
  List<DefensivoEntity> search(
    List<DefensivoEntity> defensivos,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return defensivos;
    }

    final queryLower = query.toLowerCase();
    return defensivos.where((defensivo) {
      final nomeComumMatch =
          defensivo.nomeComum?.toLowerCase().contains(queryLower) == true;
      final nomeMatch =
          defensivo.nome.toLowerCase().contains(queryLower);
      final ingredienteAtivoMatch =
          defensivo.ingredienteAtivo.toLowerCase().contains(queryLower);

      return nomeComumMatch || nomeMatch || ingredienteAtivoMatch;
    }).toList();
  }

  @override
  List<DefensivoEntity> searchCustom(
    List<DefensivoEntity> defensivos,
    bool Function(DefensivoEntity) predicate,
  ) {
    return defensivos.where(predicate).toList();
  }

  @override
  List<DefensivoEntity> searchAdvanced(
    List<DefensivoEntity> defensivos, {
    String? nomeQuery,
    String? ingredienteQuery,
    String? classeQuery,
  }) {
    var results = defensivos;

    if (nomeQuery != null && nomeQuery.isNotEmpty) {
      final queryLower = nomeQuery.toLowerCase();
      results = results.where((d) {
        final nomeComumMatch =
            d.nomeComum?.toLowerCase().contains(queryLower) == true;
        final nomeMatch = d.nome.toLowerCase().contains(queryLower);
        return nomeComumMatch || nomeMatch;
      }).toList();
    }

    if (ingredienteQuery != null && ingredienteQuery.isNotEmpty) {
      final queryLower = ingredienteQuery.toLowerCase();
      results = results.where((d) {
        final ingredienteMatch =
            d.ingredienteAtivo.toLowerCase().contains(queryLower);
        return ingredienteMatch;
      }).toList();
    }

    if (classeQuery != null && classeQuery.isNotEmpty) {
      final queryLower = classeQuery.toLowerCase();
      results = results.where((d) {
        final classeMatch =
            d.classeAgronomica?.toLowerCase().contains(queryLower) == true;
        return classeMatch;
      }).toList();
    }

    return results;
  }
}
