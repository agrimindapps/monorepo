/// Service para ordenação de pragas por cultura
///
/// Responsabilidades:
/// - Ordenar pragas por ameaça
/// - Ordenar pragas por nome
/// - Ordenar pragas por quantidade de diagnósticos
abstract class IPragasCulturaSortService {
  /// Ordena pragas por nível de ameaça/criticidade
  List<Map<String, dynamic>> sortByAmeaca(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  });

  /// Ordena pragas por nome
  List<Map<String, dynamic>> sortByNome(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  });

  /// Ordena pragas por quantidade de diagnósticos
  List<Map<String, dynamic>> sortByDiagnosticos(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  });

  /// Aplica ordenação baseada em campo
  List<Map<String, dynamic>> sortBy(
    List<Map<String, dynamic>> pragas,
    String sortBy, {
    bool ascending = true,
  });
}

/// Implementação padrão do Sort Service
class PragasCulturaSortService implements IPragasCulturaSortService {
  @override
  List<Map<String, dynamic>> sortByAmeaca(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  }) {
    final sorted = List<Map<String, dynamic>>.from(pragas);
    sorted.sort((a, b) {
      final ameacaA = _extractAmeacaLevel(a);
      final ameacaB = _extractAmeacaLevel(b);
      return ascending
          ? ameacaA.compareTo(ameacaB)
          : ameacaB.compareTo(ameacaA);
    });
    return sorted;
  }

  @override
  List<Map<String, dynamic>> sortByNome(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  }) {
    final sorted = List<Map<String, dynamic>>.from(pragas);
    sorted.sort((a, b) {
      final nomeA = (a['nome'] as String?) ?? '';
      final nomeB = (b['nome'] as String?) ?? '';
      return ascending ? nomeA.compareTo(nomeB) : nomeB.compareTo(nomeA);
    });
    return sorted;
  }

  @override
  List<Map<String, dynamic>> sortByDiagnosticos(
    List<Map<String, dynamic>> pragas, {
    required bool ascending,
  }) {
    final sorted = List<Map<String, dynamic>>.from(pragas);
    sorted.sort((a, b) {
      final countA = _extractDiagnosticCount(a);
      final countB = _extractDiagnosticCount(b);
      return ascending ? countA.compareTo(countB) : countB.compareTo(countA);
    });
    return sorted;
  }

  @override
  List<Map<String, dynamic>> sortBy(
    List<Map<String, dynamic>> pragas,
    String sortBy, {
    bool ascending = true,
  }) {
    switch (sortBy) {
      case 'ameaca':
        return sortByAmeaca(pragas, ascending: ascending);
      case 'nome':
        return sortByNome(pragas, ascending: ascending);
      case 'diagnosticos':
        return sortByDiagnosticos(pragas, ascending: ascending);
      default:
        return pragas;
    }
  }

  /// Extrai o nível de ameaça de uma praga
  int _extractAmeacaLevel(Map<String, dynamic> praga) {
    // Se é crítica, tem prioridade (nível 1 = crítica)
    if ((praga['isCritica'] as bool?) ?? false) return 1;

    // Caso contrário, nível 2 = normal
    return 2;
  }

  /// Extrai a quantidade de diagnósticos
  int _extractDiagnosticCount(Map<String, dynamic> praga) {
    final diagnosticos = praga['diagnosticos'] as List?;
    return diagnosticos?.length ?? 0;
  }
}
