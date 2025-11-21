import 'package:injectable/injectable.dart';

import '../../domain/entities/defensivo_entity.dart';

/// Service responsible for filtering and sorting defensivos.
///
/// This service encapsulates complex filtering and sorting logic, separating it
/// from the repository to improve Single Responsibility Principle (SRP) compliance.
///
/// Responsibilities:
/// - Filter by toxicidade (baixa, média, alta, extrema)
/// - Filter by tipo/classe
/// - Filter by status (comercializados, elegiveis)
/// - Sort by various criteria (nome, fabricante, usos, prioridade)
/// - Apply multiple filters simultaneously
abstract class IDefensivosFilterService {
  /// Filter defensivos by toxicity level
  List<DefensivoEntity> filterByToxicidade(
    List<DefensivoEntity> defensivos,
    String filtroToxicidade,
  );

  /// Filter defensivos by tipo/classe
  List<DefensivoEntity> filterByTipo(
    List<DefensivoEntity> defensivos,
    String filtroTipo,
  );

  /// Filter to show only comercializados defensivos
  List<DefensivoEntity> filterComercializados(
    List<DefensivoEntity> defensivos,
  );

  /// Filter to show only elegiveis defensivos
  List<DefensivoEntity> filterElegiveis(
    List<DefensivoEntity> defensivos,
  );

  /// Sort defensivos by given criterion
  List<DefensivoEntity> sort(
    List<DefensivoEntity> defensivos,
    String? ordenacao,
  );

  /// Apply all filters and sorting in one pass
  List<DefensivoEntity> filterAndSort({
    required List<DefensivoEntity> defensivos,
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  });
}

/// Default implementation of filter service
@LazySingleton(as: IDefensivosFilterService)
class DefensivosFilterService implements IDefensivosFilterService {
  @override
  List<DefensivoEntity> filterByToxicidade(
    List<DefensivoEntity> defensivos,
    String filtroToxicidade,
  ) {
    if (filtroToxicidade == 'todos') {
      return defensivos;
    }

    return defensivos.where((d) {
      final toxico = d.displayToxico.toLowerCase();
      switch (filtroToxicidade) {
        case 'baixa':
          return toxico.contains('iv') || toxico.contains('4');
        case 'media':
          return toxico.contains('iii') || toxico.contains('3');
        case 'alta':
          return toxico.contains('ii') || toxico.contains('2');
        case 'extrema':
          return toxico.contains('i') &&
              !toxico.contains('ii') &&
              !toxico.contains('iii') &&
              !toxico.contains('iv');
        default:
          return true;
      }
    }).toList();
  }

  @override
  List<DefensivoEntity> filterByTipo(
    List<DefensivoEntity> defensivos,
    String filtroTipo,
  ) {
    if (filtroTipo == 'todos') {
      return defensivos;
    }

    final classeFilter = filtroTipo.toLowerCase();
    return defensivos.where((d) {
      final classe = d.displayClass.toLowerCase();
      return classe.contains(classeFilter);
    }).toList();
  }

  @override
  List<DefensivoEntity> filterComercializados(
    List<DefensivoEntity> defensivos,
  ) {
    return defensivos.where((d) => d.isComercializado).toList();
  }

  @override
  List<DefensivoEntity> filterElegiveis(
    List<DefensivoEntity> defensivos,
  ) {
    return defensivos.where((d) => d.isElegivel).toList();
  }

  @override
  List<DefensivoEntity> sort(
    List<DefensivoEntity> defensivos,
    String? ordenacao,
  ) {
    final resultado = defensivos.toList(); // Create a copy to sort

    switch (ordenacao) {
      case 'nome':
        resultado.sort(
          (a, b) => a.displayName.compareTo(b.displayName),
        );
        break;
      case 'fabricante':
        resultado.sort(
          (a, b) => a.displayFabricante.compareTo(b.displayFabricante),
        );
        break;
      case 'usos':
        resultado.sort(
          (a, b) => (b.quantidadeDiagnosticos ?? 0).compareTo(
            a.quantidadeDiagnosticos ?? 0,
          ),
        );
        break;
      case 'prioridade':
      default:
        resultado.sort(
          (a, b) =>
              (b.nivelPrioridade ?? 0).compareTo(a.nivelPrioridade ?? 0),
        );
    }

    return resultado;
  }

  @override
  List<DefensivoEntity> filterAndSort({
    required List<DefensivoEntity> defensivos,
    String? ordenacao,
    String? filtroToxicidade,
    String? filtroTipo,
    bool apenasComercializados = false,
    bool apenasElegiveis = false,
  }) {
    var results = defensivos.toList();

    // Apply status filters first
    if (apenasComercializados) {
      results = filterComercializados(results);
    }

    if (apenasElegiveis) {
      results = filterElegiveis(results);
    }

    // Apply toxicity filter
    if (filtroToxicidade != null && filtroToxicidade.isNotEmpty) {
      results = filterByToxicidade(results, filtroToxicidade);
    }

    // Apply type filter
    if (filtroTipo != null && filtroTipo.isNotEmpty) {
      results = filterByTipo(results, filtroTipo);
    }

    // Apply sorting
    results = sort(results, ordenacao);

    return results;
  }
}
