// Dart imports:
import 'dart:async';
import 'dart:math' as math;

/// Sistema de cache inteligente para otimização de queries N+1
/// Fornece invalidação automática, TTL configurável e cache baseado em timestamp
class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();

  CacheManager._();

  final Map<String, CacheEntry> _cache = {};
  final Map<String, DateTime> _lastModified = {};
  final Map<String, Timer> _timers = {};

  /// Configuração padrão do cache
  static const Duration _defaultTtl = Duration(minutes: 5);
  static const Duration _defaultDebounce = Duration(milliseconds: 300);

  /// Buscar dados do cache ou executar função se não existir/expirado
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() fetchFunction, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    final effectiveTtl = ttl ?? _defaultTtl;

    // Se forceRefresh, limpar cache
    if (forceRefresh) {
      _cache.remove(key);
    }

    // Verificar se existe cache válido
    final entry = _cache[key];
    if (entry != null && !entry.isExpired(effectiveTtl)) {
      return entry.data as T;
    }

    // Buscar dados frescos
    final data = await fetchFunction();

    // Armazenar no cache
    _cache[key] = CacheEntry(data, DateTime.now());
    _lastModified[key] = DateTime.now();

    return data;
  }

  /// Buscar dados do cache (somente leitura)
  T? get<T>(String key, {Duration? ttl}) {
    final effectiveTtl = ttl ?? _defaultTtl;
    final entry = _cache[key];

    if (entry != null && !entry.isExpired(effectiveTtl)) {
      return entry.data as T;
    }

    return null;
  }

  /// Armazenar dados no cache
  void set<T>(String key, T data) {
    _cache[key] = CacheEntry(data, DateTime.now());
    _lastModified[key] = DateTime.now();
  }

  /// Invalidar cache específico
  void invalidate(String key) {
    _cache.remove(key);
    _lastModified[key] = DateTime.now();
  }

  /// Invalidar cache por padrão (usando wildcard)
  void invalidatePattern(String pattern) {
    final keysToRemove = <String>[];

    for (final key in _cache.keys) {
      if (_matchesPattern(key, pattern)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _lastModified[key] = DateTime.now();
    }
  }

  /// Invalidar todos os caches de um tipo
  void invalidateByType(String type) {
    invalidatePattern('$type:*');
  }

  /// Cache inteligente para listas com filtros
  Future<List<T>> getOrSetList<T>(
    String baseKey,
    Map<String, dynamic> filters,
    Future<List<T>> Function() fetchFunction, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    final filterKey = _generateFilterKey(filters);
    final cacheKey = '$baseKey:$filterKey';

    return getOrSet(cacheKey, fetchFunction,
        ttl: ttl, forceRefresh: forceRefresh);
  }

  /// Cache com debouncing para evitar múltiplas execuções simultâneas
  Future<T> getOrSetDebounced<T>(
    String key,
    Future<T> Function() fetchFunction, {
    Duration? ttl,
    Duration? debounce,
  }) async {
    final effectiveDebounce = debounce ?? _defaultDebounce;

    // Cancelar timer anterior se existir
    _timers[key]?.cancel();

    // Criar completer para aguardar debounce
    final completer = Completer<T>();

    _timers[key] = Timer(effectiveDebounce, () async {
      try {
        final result = await getOrSet(key, fetchFunction, ttl: ttl);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      } finally {
        _timers.remove(key);
      }
    });

    return completer.future;
  }

  /// Cache para operações batch otimizadas
  Future<List<T>> getOrSetBatch<T, K>(
    String baseKey,
    List<K> keys,
    Future<List<T>> Function(List<K>) fetchFunction,
    String Function(T) getKeyFromItem, {
    Duration? ttl,
  }) async {
    final results = <T>[];
    final missingKeys = <K>[];

    // Verificar cache para cada key
    for (final key in keys) {
      final cacheKey = '$baseKey:$key';
      final cached = get<T>(cacheKey, ttl: ttl);

      if (cached != null) {
        results.add(cached);
      } else {
        missingKeys.add(key);
      }
    }

    // Se todas estão em cache, retornar
    if (missingKeys.isEmpty) {
      return results;
    }

    // Buscar apenas os dados faltantes
    final fetchedItems = await fetchFunction(missingKeys);

    // Armazenar novos itens no cache
    for (final item in fetchedItems) {
      final itemKey = getKeyFromItem(item);
      final cacheKey = '$baseKey:$itemKey';
      set(cacheKey, item);
      results.add(item);
    }

    return results;
  }

  /// Configurar invalidação automática baseada em streams
  void setupAutoInvalidation(
    String pattern,
    Stream<dynamic> dataStream, {
    Duration? debounce,
  }) {
    final effectiveDebounce = debounce ?? _defaultDebounce;

    Timer? debounceTimer;
    dataStream.distinct().listen((_) {
      debounceTimer?.cancel();
      debounceTimer = Timer(effectiveDebounce, () {
        invalidatePattern(pattern);
      });
    });
  }

  /// Obter estatísticas do cache
  CacheStats getStats() {
    int expired = 0;
    int valid = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired(_defaultTtl)) {
        expired++;
      } else {
        valid++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: valid,
      expiredEntries: expired,
      memoryUsageKb: _estimateMemoryUsage(),
    );
  }

  /// Limpar cache expirado
  void cleanupExpired({Duration? ttl}) {
    final effectiveTtl = ttl ?? _defaultTtl;
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired(effectiveTtl)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
      _lastModified.remove(key);
    }
  }

  /// Limpar todo o cache
  void clear() {
    _cache.clear();
    _lastModified.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Dispose do cache manager
  Future<void> dispose() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    clear();
  }

  // Métodos auxiliares

  bool _matchesPattern(String key, String pattern) {
    if (pattern.endsWith('*')) {
      return key.startsWith(pattern.substring(0, pattern.length - 1));
    }
    return key == pattern;
  }

  String _generateFilterKey(Map<String, dynamic> filters) {
    final sortedKeys = filters.keys.toList()..sort();
    final parts = <String>[];

    for (final key in sortedKeys) {
      final value = filters[key];
      parts.add('$key=${value.toString()}');
    }

    return parts.join('&');
  }

  int _estimateMemoryUsage() {
    // Estimativa simples baseada no número de entradas
    // Em produção, usar package como dart:developer para medição real
    return (_cache.length * 1024) ~/ 1024; // KB aproximado
  }
}

/// Entry do cache com timestamp
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry(this.data, this.timestamp);

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(timestamp) > ttl;
  }
}

/// Estatísticas do cache
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int memoryUsageKb;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.memoryUsageKb,
  });

  double get hitRatio => totalEntries > 0 ? validEntries / totalEntries : 0.0;

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, '
        'expired: $expiredEntries, memory: ${memoryUsageKb}KB, '
        'hit ratio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
  }
}

/// Mixin para adicionar funcionalidades de cache aos repositories
mixin CacheableRepository {
  CacheManager get cacheManager => CacheManager.instance;

  /// Gerar chave de cache baseada no tipo do repository
  String getCacheKey(String operation, [String? identifier]) {
    final typeName =
        runtimeType.toString().replaceAll('Repository', '').toLowerCase();
    return identifier != null
        ? '$typeName:$operation:$identifier'
        : '$typeName:$operation';
  }

  /// Cache para findAll otimizado
  Future<List<T>> cachedFindAll<T>(
    Future<List<T>> Function() fetchFunction,
    String typeName, {
    Duration? ttl,
  }) {
    return cacheManager.getOrSet(
      getCacheKey('findAll'),
      fetchFunction,
      ttl: ttl,
    );
  }

  /// Cache para findById otimizado
  Future<T?> cachedFindById<T>(
    String id,
    Future<T?> Function(String) fetchFunction,
    String typeName, {
    Duration? ttl,
  }) {
    return cacheManager.getOrSet(
      getCacheKey('findById', id),
      () => fetchFunction(id),
      ttl: ttl,
    );
  }

  /// Cache para queries com filtros
  Future<List<T>> cachedQuery<T>(
    Map<String, dynamic> filters,
    Future<List<T>> Function() fetchFunction,
    String operationName, {
    Duration? ttl,
  }) {
    return cacheManager.getOrSetList(
      getCacheKey(operationName),
      filters,
      fetchFunction,
      ttl: ttl,
    );
  }

  /// Invalidar cache após operações de write
  void invalidateCache([String? pattern]) {
    if (pattern != null) {
      cacheManager.invalidatePattern(pattern);
    } else {
      final typeName =
          runtimeType.toString().replaceAll('Repository', '').toLowerCase();
      cacheManager.invalidateByType(typeName);
    }
  }

  /// Configurar invalidação automática baseada em stream
  void setupCacheInvalidation(Stream<dynamic> dataStream) {
    final typeName =
        runtimeType.toString().replaceAll('Repository', '').toLowerCase();
    cacheManager.setupAutoInvalidation('$typeName:*', dataStream);
  }
}

/// Utilitário para operações batch otimizadas
class BatchOperationHelper {
  /// Executar operações em lote com tamanho de chunk configurável
  static Future<List<T>> executeBatch<T, K>(
    List<K> items,
    Future<T> Function(K) operation, {
    int chunkSize = 50,
    Duration delay = const Duration(milliseconds: 10),
  }) async {
    final results = <T>[];

    for (int i = 0; i < items.length; i += chunkSize) {
      final chunk = items.sublist(
        i,
        math.min(i + chunkSize, items.length),
      );

      final chunkResults = await Future.wait(
        chunk.map(operation),
      );

      results.addAll(chunkResults);

      // Pequeno delay para não sobrecarregar
      if (i + chunkSize < items.length) {
        await Future.delayed(delay);
      }
    }

    return results;
  }

  /// Combinar múltiplas listas sem duplicatas
  static List<T> combineUnique<T>(
    List<List<T>> lists,
    bool Function(T, T) isEqual,
  ) {
    final result = <T>[];
    final seen = <T>[];

    for (final list in lists) {
      for (final item in list) {
        final alreadyExists = seen.any((existing) => isEqual(existing, item));
        if (!alreadyExists) {
          result.add(item);
          seen.add(item);
        }
      }
    }

    return result;
  }
}
