import '../../domain/entities/pragas_cultura_filter.dart';

/// Service para queries e filtragem de pragas por cultura
///
/// Responsabilidades:
/// - Filtrar pragas por criticidade
/// - Filtrar pragas por tipo
/// - Extrair metadata (tipos, famílias distintas)
abstract class IPragasCulturaQueryService {
  /// Filtra pragas por criticidade
  /// [pragas]: Lista de pragas a filtrar
  /// [onlyCriticas]: Se true, apenas críticas; se false, apenas normais; null = todas
  List<Map<String, dynamic>> filterByCriticidade(
    List<Map<String, dynamic>> pragas, {
    required bool? onlyCriticas,
  });

  /// Filtra pragas por tipo
  /// [pragas]: Lista de pragas a filtrar
  /// [tipoPraga]: '1' = Insetos, '2' = Doenças, '3' = Plantas Daninhas, null = todas
  List<Map<String, dynamic>> filterByTipo(
    List<Map<String, dynamic>> pragas,
    String? tipoPraga,
  );

  /// Aplica múltiplos filtros
  List<Map<String, dynamic>> applyFilters(
    List<Map<String, dynamic>> pragas,
    PragasCulturaFilter filter,
  );

  /// Extrai tipos distintos
  Set<String> extractTipos(List<Map<String, dynamic>> pragas);

  /// Extrai famílias distintas
  Set<String> extractFamilias(List<Map<String, dynamic>> pragas);
}

/// Implementação padrão do Query Service
class PragasCulturaQueryService implements IPragasCulturaQueryService {
  @override
  List<Map<String, dynamic>> filterByCriticidade(
    List<Map<String, dynamic>> pragas, {
    required bool? onlyCriticas,
  }) {
    if (onlyCriticas == null) return pragas;

    if (onlyCriticas) {
      return pragas.where((p) => (p['isCritica'] as bool?) ?? false).toList();
    } else {
      return pragas
          .where((p) => !((p['isCritica'] as bool?) ?? false))
          .toList();
    }
  }

  @override
  List<Map<String, dynamic>> filterByTipo(
    List<Map<String, dynamic>> pragas,
    String? tipoPraga,
  ) {
    if (tipoPraga == null) return pragas;
    return pragas.where((p) => (p['tipo'] as String?) == tipoPraga).toList();
  }

  @override
  List<Map<String, dynamic>> applyFilters(
    List<Map<String, dynamic>> pragas,
    PragasCulturaFilter filter,
  ) {
    var filtered = pragas;

    // Apply criticidade filter
    if (filter.onlyCriticas) {
      filtered = filterByCriticidade(filtered, onlyCriticas: true);
    } else if (filter.onlyNormais) {
      filtered = filterByCriticidade(filtered, onlyCriticas: false);
    }

    // Apply tipo filter
    if (filter.tipoPraga != null) {
      filtered = filterByTipo(filtered, filter.tipoPraga);
    }

    return filtered;
  }

  @override
  Set<String> extractTipos(List<Map<String, dynamic>> pragas) {
    final tipos = <String>{};
    for (final praga in pragas) {
      final tipo = praga['tipo'] as String?;
      if (tipo != null) {
        tipos.add(tipo);
      }
    }
    return tipos;
  }

  @override
  Set<String> extractFamilias(List<Map<String, dynamic>> pragas) {
    final familias = <String>{};
    for (final praga in pragas) {
      final familia = praga['familia'] as String?;
      if (familia != null) {
        familias.add(familia);
      }
    }
    return familias;
  }
}
