import 'package:flutter/foundation.dart';

import '../../features/diagnosticos/domain/entities/diagnostico_entity.dart';

import 'diagnostico_entity_resolver_drift.dart';

/// Serviço centralizado para agrupamento de diagnósticos
///
/// Unifica toda a lógica de agrupamento de diagnósticos por diferentes critérios,
/// garantindo consistência e reutilização em toda a aplicação.
///
/// **Funcionalidades:**
/// - Agrupamento por cultura, defensivo e praga
/// - Resolução consistente de nomes através do EntityResolver
/// - Ordenação automática por relevância
/// - Filtros avançados com múltiplos critérios
/// - Estatísticas de agrupamento
/// - Cache interno para agrupamentos frequentes
class DiagnosticoGroupingService {
  static DiagnosticoGroupingService? _instance;
  static DiagnosticoGroupingService get instance =>
      _instance ??= DiagnosticoGroupingService._internal();

  DiagnosticoGroupingService._internal();

  final DiagnosticoEntityResolver _resolver =
      DiagnosticoEntityResolver.instance;
  final Map<String, Map<String, dynamic>> _groupingCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheTTL = Duration(minutes: 15);

  /// Verifica se o cache está válido
  bool get _isCacheValid {
    return _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTTL;
  }

  /// Agrupa diagnósticos por cultura (versão unificada)
  ///
  /// Funciona com qualquer tipo de lista de diagnósticos,
  /// garantindo resolução consistente de nomes de cultura
  Future<Map<String, List<T>>> groupByCultura<T>(
    List<T> items,
    String? Function(T) getIdCultura,
    String? Function(T) getNomeCultura, {
    String defaultGroupName = 'Cultura não especificada',
    bool sortGroups = true,
    bool sortItemsInGroup = false,
    int Function(T, T)? itemComparator,
  }) async {
    final cacheKey = 'cultura_${items.length}_${T.toString()}';

    if (_isCacheValid && _groupingCache.containsKey(cacheKey)) {
      final cached = _groupingCache[cacheKey]!;
      if (cached['type'] == T && cached['count'] == items.length) {
        return (cached['data'] as Map).cast<String, List<T>>();
      }
    }

    final grouped = <String, List<T>>{};

    for (final item in items) {
      final idCultura = getIdCultura(item);
      String culturaNome = defaultGroupName;
      if (idCultura != null && idCultura.isNotEmpty) {
        culturaNome = await _resolver.resolveCulturaNome(
          idCultura: idCultura,
          defaultValue: defaultGroupName,
        );
      }

      grouped.putIfAbsent(culturaNome, () => []).add(item);
    }
    if (sortGroups) {
      final sortedEntries = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      grouped.clear();
      grouped.addAll(Map.fromEntries(sortedEntries));
    }
    if (sortItemsInGroup) {
      grouped.forEach((key, list) {
        if (itemComparator != null) {
          list.sort(itemComparator);
        }
      });
    }
    _groupingCache[cacheKey] = {
      'data': grouped,
      'type': T,
      'count': items.length,
      'timestamp': DateTime.now(),
    };
    _lastCacheUpdate = DateTime.now();

    return grouped;
  }

  /// Agrupa diagnósticos por defensivo
  Future<Map<String, List<T>>> groupByDefensivo<T>(
    List<T> items,
    String? Function(T) getIdDefensivo,
    String? Function(T) getNomeDefensivo, {
    String defaultGroupName = 'Defensivo não especificado',
    bool sortGroups = true,
    bool sortItemsInGroup = false,
    int Function(T, T)? itemComparator,
  }) async {
    final grouped = <String, List<T>>{};

    for (final item in items) {
      final idDefensivo = getIdDefensivo(item);
      String defensivoNome = defaultGroupName;
      if (idDefensivo != null && idDefensivo.isNotEmpty) {
        defensivoNome = await _resolver.resolveDefensivoNome(
          idDefensivo: idDefensivo,
          defaultValue: defaultGroupName,
        );
      }

      grouped.putIfAbsent(defensivoNome, () => []).add(item);
    }

    if (sortGroups) {
      final sortedEntries = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      grouped.clear();
      grouped.addAll(Map.fromEntries(sortedEntries));
    }

    if (sortItemsInGroup && itemComparator != null) {
      grouped.forEach((key, list) => list.sort(itemComparator));
    }

    return grouped;
  }

  /// Agrupa diagnósticos por praga
  Future<Map<String, List<T>>> groupByPraga<T>(
    List<T> items,
    String? Function(T) getIdPraga,
    String? Function(T) getNomePraga, {
    String defaultGroupName = 'Praga não especificada',
    bool sortGroups = true,
    bool sortItemsInGroup = false,
    int Function(T, T)? itemComparator,
  }) async {
    final grouped = <String, List<T>>{};

    for (final item in items) {
      final idPraga = getIdPraga(item);
      String pragaNome = defaultGroupName;
      if (idPraga != null && idPraga.isNotEmpty) {
        pragaNome = await _resolver.resolvePragaNome(
          idPraga: idPraga,
          defaultValue: defaultGroupName,
        );
      }

      grouped.putIfAbsent(pragaNome, () => []).add(item);
    }

    if (sortGroups) {
      final sortedEntries = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      grouped.clear();
      grouped.addAll(Map.fromEntries(sortedEntries));
    }

    if (sortItemsInGroup && itemComparator != null) {
      grouped.forEach((key, list) => list.sort(itemComparator));
    }

    return grouped;
  }

  /// Agrupamento multi-nível (ex: por cultura e depois por defensivo)
  Map<String, Map<String, List<T>>> groupByMultiLevel<T>(
    List<T> items,
    String Function(T) primaryGrouper,
    String Function(T) secondaryGrouper, {
    bool sortPrimaryGroups = true,
    bool sortSecondaryGroups = true,
  }) {
    final result = <String, Map<String, List<T>>>{};
    final primaryGroups = <String, List<T>>{};
    for (final item in items) {
      final primaryKey = primaryGrouper(item);
      primaryGroups.putIfAbsent(primaryKey, () => []).add(item);
    }
    for (final entry in primaryGroups.entries) {
      final secondaryGroups = <String, List<T>>{};

      for (final item in entry.value) {
        final secondaryKey = secondaryGrouper(item);
        secondaryGroups.putIfAbsent(secondaryKey, () => []).add(item);
      }

      if (sortSecondaryGroups) {
        final sortedSecondary = Map.fromEntries(
          secondaryGroups.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)),
        );
        result[entry.key] = sortedSecondary;
      } else {
        result[entry.key] = secondaryGroups;
      }
    }

    if (sortPrimaryGroups) {
      final sortedResult = Map.fromEntries(
        result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
      result.clear();
      result.addAll(sortedResult);
    }

    return result;
  }

  /// Agrupamento com filtros avançados
  Map<String, List<T>> groupWithFilters<T>(
    List<T> items,
    String Function(T) grouper,
    bool Function(T)? filter, {
    int? maxGroupSize,
    int? minGroupSize,
    bool sortGroups = true,
    bool includeEmptyGroups = false,
  }) {
    final filteredItems = filter != null ? items.where(filter).toList() : items;

    final grouped = <String, List<T>>{};

    for (final item in filteredItems) {
      final groupKey = grouper(item);
      grouped.putIfAbsent(groupKey, () => []).add(item);
    }
    if (minGroupSize != null) {
      grouped.removeWhere((key, list) => list.length < minGroupSize);
    }

    if (maxGroupSize != null) {
      grouped.forEach((key, list) {
        if (list.length > maxGroupSize) {
          grouped[key] = list.take(maxGroupSize).toList();
        }
      });
    }
    if (!includeEmptyGroups) {
      grouped.removeWhere((key, list) => list.isEmpty);
    }

    if (sortGroups) {
      final sortedEntries = grouped.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      grouped.clear();
      grouped.addAll(Map.fromEntries(sortedEntries));
    }

    return grouped;
  }

  /// Métodos de conveniência para tipos específicos

  /// Agrupa DiagnosticoEntity por cultura
  Future<Map<String, List<DiagnosticoEntity>>>
  groupDiagnosticoEntitiesByCultura(
    List<DiagnosticoEntity> diagnosticos, {
    bool sortByRelevance = true,
  }) {
    return groupByCultura<DiagnosticoEntity>(
      diagnosticos,
      (d) => d.idCultura,
      (d) => d.nomeCultura,
      sortItemsInGroup: sortByRelevance,
      itemComparator: sortByRelevance ? _compareByRelevance : null,
    );
  }

  /// Agrupa Diagnostico por cultura
  Future<Map<String, List<Diagnostico>>> groupDiagnosticosByCultura(
    List<Diagnostico> diagnosticos, {
    bool sortByRelevance = true,
  }) {
    return groupByCultura<Diagnostico>(
      diagnosticos,
      (d) => d.fkIdCultura,
      (d) => d.nomeCultura,
      sortItemsInGroup: sortByRelevance,
      itemComparator: sortByRelevance ? _compareHiveByRelevance : null,
    );
  }

  /// Agrupa objetos dinâmicos (flexibilidade de tipos)
  Future<Map<String, List<dynamic>>> groupDynamicByCultura(
    List<dynamic> diagnosticos, {
    bool useResolver = true,
  }) {
    return groupByCultura<dynamic>(
      diagnosticos,
      (d) =>
          _extractProperty(d, 'idCultura') ??
          _extractProperty(d, 'fkIdCultura'),
      (d) =>
          _extractProperty(d, 'nomeCultura') ?? _extractProperty(d, 'cultura'),
    );
  }

  /// Extrai propriedade de objeto dinâmico
  String? _extractProperty(dynamic obj, String property) {
    try {
      if (obj is Map<String, dynamic>) {
        return obj[property]?.toString();
      } else {
        switch (property) {
          case 'idCultura':
            return obj.idCultura?.toString();
          case 'fkIdCultura':
            return obj.fkIdCultura?.toString();
          case 'nomeCultura':
            return obj.nomeCultura?.toString();
          case 'cultura':
            return obj.cultura?.toString();
          default:
            return null;
        }
      }
    } catch (e) {
      debugPrint('Erro ao extrair propriedade $property: $e');
      return null;
    }
  }

  /// Comparador por relevância para DiagnosticoEntity
  int _compareByRelevance(DiagnosticoEntity a, DiagnosticoEntity b) {
    final aCompletude = a.completude.index;
    final bCompletude = b.completude.index;

    if (aCompletude != bCompletude) {
      return bCompletude.compareTo(aCompletude); // Decrescente
    }
    return (a.nomeDefensivo ?? '').compareTo(b.nomeDefensivo ?? '');
  }

  /// Comparador por relevância para Diagnostico
  int _compareHiveByRelevance(Diagnostico a, Diagnostico b) {
    final aScore = _calculateHiveRelevanceScore(a);
    final bScore = _calculateHiveRelevanceScore(b);

    if (aScore != bScore) {
      return bScore.compareTo(aScore); // Decrescente
    }

    return (a.nomeDefensivo ?? '').compareTo(b.nomeDefensivo ?? '');
  }

  /// Calcula pontuação de relevância para Diagnostico
  int _calculateHiveRelevanceScore(Diagnostico diagnostico) {
    int score = 0;

    if (diagnostico.nomeDefensivo?.isNotEmpty == true) score += 2;
    if (diagnostico.nomeCultura?.isNotEmpty == true) score += 2;
    if (diagnostico.nomePraga?.isNotEmpty == true) score += 2;
    if (diagnostico.dsMax.isNotEmpty) score += 1;
    if (diagnostico.um.isNotEmpty) score += 1;

    return score;
  }

  /// Obtém estatísticas de agrupamento
  GroupingStats getGroupingStats<T>(Map<String, List<T>> grouped) {
    final groupSizes = grouped.values.map((list) => list.length).toList();

    return GroupingStats(
      totalGroups: grouped.length,
      totalItems: groupSizes.fold<int>(0, (sum, size) => sum + size),
      averageGroupSize: groupSizes.isNotEmpty
          ? groupSizes.reduce((a, b) => a + b) / groupSizes.length
          : 0.0,
      largestGroupSize: groupSizes.isNotEmpty
          ? groupSizes.reduce((a, b) => a > b ? a : b)
          : 0,
      smallestGroupSize: groupSizes.isNotEmpty
          ? groupSizes.reduce((a, b) => a < b ? a : b)
          : 0,
      emptyGroups: grouped.values.where((list) => list.isEmpty).length,
    );
  }

  /// Limpa cache de agrupamentos
  void clearCache() {
    _groupingCache.clear();
    _lastCacheUpdate = null;
    debugPrint('🗑️ DiagnosticoGroupingService: Cache limpo');
  }

  /// Obtém estatísticas do cache
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _groupingCache.length,
      'lastUpdate': _lastCacheUpdate,
      'isValid': _isCacheValid,
      'cacheKeys': _groupingCache.keys.toList(),
    };
  }
}

/// Estatísticas de agrupamento
class GroupingStats {
  final int totalGroups;
  final int totalItems;
  final double averageGroupSize;
  final int largestGroupSize;
  final int smallestGroupSize;
  final int emptyGroups;

  const GroupingStats({
    required this.totalGroups,
    required this.totalItems,
    required this.averageGroupSize,
    required this.largestGroupSize,
    required this.smallestGroupSize,
    required this.emptyGroups,
  });

  @override
  String toString() {
    return 'GroupingStats{groups: $totalGroups, items: $totalItems, '
        'avgSize: ${averageGroupSize.toStringAsFixed(1)}, '
        'largest: $largestGroupSize, smallest: $smallestGroupSize}';
  }
}
