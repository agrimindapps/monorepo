import 'package:injectable/injectable.dart';

/// Service responsible for pragas sorting logic
/// Replaces switch statement with strategy pattern
/// Follows OCP - extensible without modification
@lazySingleton
class PragasCulturaSortService {
  PragasCulturaSortService();

  /// Sort criteria registry using strategy pattern
  /// Maps sort keys to comparison functions
  final Map<String, int Function(dynamic, dynamic)> _sortStrategies = {
    'nome': _sortByName,
    'diagnosticos': _sortByDiagnostics,
    'ameaca': _sortByThreat,
  };

  /// Default sort criteria
  static const String defaultSort = 'ameaca';

  /// Sort pragas by given criteria
  /// Returns sorted copy of the list
  List<dynamic> sortPragas(List<dynamic> pragas, String sortBy) {
    if (pragas.isEmpty) {
      return [];
    }

    final pragasCopy = List<dynamic>.from(pragas);
    final sortFunction =
        _sortStrategies[sortBy] ?? _sortStrategies[defaultSort]!;

    pragasCopy.sort(sortFunction);
    return pragasCopy;
  }

  /// Check if a sort criteria is registered
  bool hasSortCriteria(String sortBy) {
    return _sortStrategies.containsKey(sortBy);
  }

  /// Get all available sort criteria
  List<String> getAvailableSortCriteria() {
    return _sortStrategies.keys.toList();
  }

  /// Sort by name (alphabetically A-Z)
  static int _sortByName(dynamic a, dynamic b) {
    final nomeA = _extractName(a);
    final nomeB = _extractName(b);
    return nomeA.compareTo(nomeB);
  }

  /// Sort by diagnostics count (descending)
  static int _sortByDiagnostics(dynamic a, dynamic b) {
    final diagA = _extractDiagnosticsCount(a);
    final diagB = _extractDiagnosticsCount(b);
    return diagB.compareTo(diagA); // Descending
  }

  /// Sort by threat level (critical first, then by diagnostics)
  static int _sortByThreat(dynamic a, dynamic b) {
    // Compare criticality first (critical pragas come first)
    final criticaA = _extractIsCritical(a);
    final criticaB = _extractIsCritical(b);

    if (criticaA != criticaB) {
      return criticaA ? -1 : 1; // true (critical) comes first
    }

    // If criticality is equal, sort by diagnostics count
    final diagA = _extractDiagnosticsCount(a);
    final diagB = _extractDiagnosticsCount(b);
    return diagB.compareTo(diagA); // Descending
  }

  /// Extract name from praga object
  static String _extractName(dynamic praga) {
    if (praga is Map && praga['praga'] is Map) {
      return (praga['praga']['nomeComum'] as String?) ?? '';
    }
    return '';
  }

  /// Extract diagnostics count from praga object
  static int _extractDiagnosticsCount(dynamic praga) {
    if (praga is Map) {
      return (praga['quantidadeDiagnosticos'] as int?) ?? 0;
    }
    return 0;
  }

  /// Extract critical status from praga object
  static bool _extractIsCritical(dynamic praga) {
    if (praga is Map) {
      return (praga['isCritica'] as bool?) ?? false;
    }
    return false;
  }

  /// Get sort strategy description for UI
  String getSortDescription(String sortBy) {
    switch (sortBy) {
      case 'nome':
        return 'Alfabética (A-Z)';
      case 'diagnosticos':
        return 'Mais Diagnósticos';
      case 'ameaca':
        return 'Nível de Ameaça';
      default:
        return 'Padrão';
    }
  }
}
