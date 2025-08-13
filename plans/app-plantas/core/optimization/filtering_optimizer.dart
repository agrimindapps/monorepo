/// Otimizador de filtros para repositories
class FilteringOptimizer {
  /// Cache para resultados de filtros recentes
  static final Map<String, dynamic> _filterCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// TTL do cache em minutos
  static const int cacheTtlMinutes = 5;

  /// Limpar cache expirado
  static void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inMinutes > cacheTtlMinutes) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _filterCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Obter do cache ou calcular
  static T getOrCompute<T>(
    String cacheKey,
    T Function() computer,
  ) {
    cleanExpiredCache();

    if (_filterCache.containsKey(cacheKey)) {
      return _filterCache[cacheKey] as T;
    }

    final result = computer();
    _filterCache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return result;
  }

  /// Invalidar cache específico
  static void invalidateCache(String pattern) {
    final keysToRemove =
        _filterCache.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      _filterCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Limpar todo cache
  static void clearAllCache() {
    _filterCache.clear();
    _cacheTimestamps.clear();
  }
}

/// Mixin para repositories com filtering otimizado
mixin OptimizedFiltering {
  /// Cache local para filtros frequentes
  final Map<String, List<dynamic>> _localFilterCache = {};

  /// Filtrar com cache inteligente
  List<T> cachedFilter<T>(
    List<T> source,
    bool Function(T item) predicate,
    String cacheKey,
  ) {
    return FilteringOptimizer.getOrCompute(
      cacheKey,
      () => source.where(predicate).toList(),
    );
  }

  /// Filtrar e ordenar com cache combinado
  List<T> cachedFilterAndSort<T>(
    List<T> source,
    bool Function(T item) predicate,
    int Function(T a, T b) compare,
    String cacheKey,
  ) {
    return FilteringOptimizer.getOrCompute(
      cacheKey,
      () {
        final filtered = source.where(predicate).toList();
        filtered.sort(compare);
        return filtered;
      },
    );
  }

  /// Stream com debounce para evitar filtros excessivos
  Stream<List<T>> debounceFilter<T>(
    Stream<List<T>> source,
    bool Function(T item) predicate,
    Duration debounceDuration,
  ) {
    return source
        .distinct() // Evitar emissões duplicadas
        .map((items) => items.where(predicate).toList());
  }

  /// Invalidar cache quando dados mudam
  void invalidateFilterCache([String? pattern]) {
    if (pattern != null) {
      FilteringOptimizer.invalidateCache(pattern);
    } else {
      FilteringOptimizer.clearAllCache();
    }
    _localFilterCache.clear();
  }

  /// Filtro otimizado baseado no tamanho da coleção
  List<T> optimizedFilter<T>(
    List<T> source,
    bool Function(T item) predicate, {
    String? cacheKey,
    int cacheThreshold = 50,
  }) {
    // Para listas pequenas, não usar cache
    if (source.length < cacheThreshold) {
      return source.where(predicate).toList();
    }

    // Para listas grandes, usar cache se disponível
    if (cacheKey != null) {
      return cachedFilter(source, predicate, cacheKey);
    }

    return source.where(predicate).toList();
  }

  /// Combinar múltiplos filtros de forma eficiente
  List<T> multiFilter<T>(
    List<T> source,
    List<bool Function(T item)> predicates,
  ) {
    if (predicates.isEmpty) return source;
    if (predicates.length == 1) return source.where(predicates.first).toList();

    // Combinar todos os predicates em um único
    bool combinedPredicate(T item) {
      for (final predicate in predicates) {
        if (!predicate(item)) return false;
      }
      return true;
    }

    return source.where(combinedPredicate).toList();
  }

  /// Filtro com estatísticas para análise de performance
  ({List<T> results, int originalCount, int filteredCount, Duration duration})
      filterWithStats<T>(
    List<T> source,
    bool Function(T item) predicate,
  ) {
    final stopwatch = Stopwatch()..start();
    final results = source.where(predicate).toList();
    stopwatch.stop();

    return (
      results: results,
      originalCount: source.length,
      filteredCount: results.length,
      duration: stopwatch.elapsed,
    );
  }
}

/// Helper para criar chaves de cache inteligentes
class CacheKeyBuilder {
  static String buildKey(String operation, List<String> parameters) {
    return '$operation:${parameters.join(':')}';
  }

  static String buildFilterKey(String repositoryName, String filterName,
      [List<String>? params]) {
    final baseKey = '${repositoryName}_$filterName';
    if (params?.isNotEmpty ?? false) {
      return '${baseKey}_${params!.join('_')}';
    }
    return baseKey;
  }

  static String buildSortKey(String repositoryName, String sortField,
      [String? direction]) {
    return '${repositoryName}_sort_${sortField}_${direction ?? 'asc'}';
  }

  static String buildTimeBasedKey(String baseKey, [DateTime? referenceTime]) {
    final time = referenceTime ?? DateTime.now();
    // Usar chave baseada na hora para cache que expira rapidamente
    final hourKey = '${time.year}_${time.month}_${time.day}_${time.hour}';
    return '${baseKey}_$hourKey';
  }
}
