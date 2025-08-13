// Dart imports:
import 'dart:async';

/// Sistema de memoization avançado para operações custosas
/// Implementa lazy evaluation, cache inteligente e invalidação automática
class MemoizationManager {
  static MemoizationManager? _instance;
  static MemoizationManager get instance =>
      _instance ??= MemoizationManager._();

  MemoizationManager._();

  // Cache de memoização com TTL específico
  final Map<String, MemoizedEntry> _memoCache = {};

  // Cache para lazy evaluation
  final Map<String, LazyValue> _lazyCache = {};

  // Índices de invalidação por categoria
  final Map<String, Set<String>> _categoryIndex = {};

  // Estatísticas de performance
  final Map<String, MemoStats> _stats = {};

  /// Configurações de TTL por tipo de operação
  static const Map<String, Duration> _ttlConfig = {
    'statistics': Duration(minutes: 10),
    'query_results': Duration(minutes: 5),
    'calculations': Duration(minutes: 15),
    'aggregations': Duration(minutes: 8),
    'transformations': Duration(minutes: 3),
  };

  /// Memoizar uma função custosa com cache inteligente
  Future<T> memoize<T>(
    String key,
    Future<T> Function() computation, {
    String category = 'default',
    Duration? customTtl,
    List<String>? dependencies,
  }) async {
    // Atualizar estatísticas
    _updateStats(key, isHit: false);

    final now = DateTime.now();
    final entry = _memoCache[key];
    final ttl = customTtl ?? _getTtlForCategory(category);

    // Verificar se há cache válido
    if (entry != null && !entry.isExpired(ttl, now)) {
      _updateStats(key, isHit: true);
      return entry.value as T;
    }

    // Executar computation e cachear resultado
    final result = await computation();

    // Armazenar no cache
    _memoCache[key] = MemoizedEntry(
      value: result,
      createdAt: now,
      category: category,
      dependencies: dependencies ?? [],
    );

    // Indexar por categoria
    _categoryIndex.putIfAbsent(category, () => <String>{}).add(key);

    return result;
  }

  /// Lazy evaluation com cache persistente
  T lazyEvaluate<T>(
    String key,
    T Function() computation, {
    String category = 'lazy',
    Duration? customTtl,
  }) {
    final now = DateTime.now();
    final cached = _lazyCache[key];
    final ttl = customTtl ?? _getTtlForCategory(category);

    // Verificar cache válido
    if (cached != null && !cached.isExpired(ttl, now)) {
      _updateStats(key, isHit: true);
      return cached.value as T;
    }

    // Executar computation e cachear
    final result = computation();
    _lazyCache[key] = LazyValue(
      value: result,
      createdAt: now,
      category: category,
    );

    _updateStats(key, isHit: false);
    return result;
  }

  /// Memoização com debounce para operações frequentes
  Future<T> memoizeWithDebounce<T>(
    String key,
    Future<T> Function() computation, {
    String category = 'debounced',
    Duration debounce = const Duration(milliseconds: 300),
    Duration? customTtl,
  }) async {
    final completerKey = '${key}_completer';

    // Se já há uma operação em andamento, aguardar
    if (_pendingOperations.containsKey(completerKey)) {
      return await _pendingOperations[completerKey]!.future as T;
    }

    // Verificar cache existente
    final cached = _memoCache[key];
    final ttl = customTtl ?? _getTtlForCategory(category);

    if (cached != null && !cached.isExpired(ttl)) {
      return cached.value as T;
    }

    // Criar debounce
    final completer = Completer<T>();
    _pendingOperations[completerKey] = completer as Completer<dynamic>;

    Timer(debounce, () async {
      try {
        final result = await computation();

        _memoCache[key] = MemoizedEntry(
          value: result,
          createdAt: DateTime.now(),
          category: category,
          dependencies: [],
        );

        _categoryIndex.putIfAbsent(category, () => <String>{}).add(key);

        completer.complete(result);
      } catch (error) {
        completer.completeError(error);
      } finally {
        _pendingOperations.remove(completerKey);
      }
    });

    return completer.future;
  }

  // Controle de operações pendentes
  final Map<String, Completer> _pendingOperations = {};

  /// Invalidar cache por categoria
  void invalidateCategory(String category) {
    final keys = _categoryIndex[category];
    if (keys != null) {
      for (final key in keys) {
        _memoCache.remove(key);
        _lazyCache.remove(key);
      }
      keys.clear();
    }
  }

  /// Invalidar cache por dependência
  void invalidateByDependency(String dependency) {
    final toRemove = <String>[];

    _memoCache.forEach((key, entry) {
      if (entry.dependencies.contains(dependency)) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      final entry = _memoCache.remove(key);
      if (entry != null) {
        _categoryIndex[entry.category]?.remove(key);
      }
    }
  }

  /// Invalidar chave específica
  void invalidate(String key) {
    final entry = _memoCache.remove(key);
    _lazyCache.remove(key);

    if (entry != null) {
      _categoryIndex[entry.category]?.remove(key);
    }
  }

  /// Limpeza automática de cache expirado
  void cleanupExpired() {
    final now = DateTime.now();
    final toRemove = <String>[];

    // Limpar memoized entries
    _memoCache.forEach((key, entry) {
      final ttl = _getTtlForCategory(entry.category);
      if (entry.isExpired(ttl, now)) {
        toRemove.add(key);
      }
    });

    for (final key in toRemove) {
      final entry = _memoCache.remove(key);
      if (entry != null) {
        _categoryIndex[entry.category]?.remove(key);
      }
    }

    // Limpar lazy values
    final lazyToRemove = <String>[];
    _lazyCache.forEach((key, lazyValue) {
      final ttl = _getTtlForCategory(lazyValue.category);
      if (lazyValue.isExpired(ttl, now)) {
        lazyToRemove.add(key);
      }
    });

    for (final key in lazyToRemove) {
      _lazyCache.remove(key);
    }
  }

  /// Obter estatísticas de performance
  Map<String, MemoStats> getStatistics() => Map.unmodifiable(_stats);

  /// Obter informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'memo_cache_size': _memoCache.length,
      'lazy_cache_size': _lazyCache.length,
      'categories': _categoryIndex.keys.toList(),
      'pending_operations': _pendingOperations.length,
      'hit_ratio': _calculateOverallHitRatio(),
    };
  }

  // Métodos auxiliares
  Duration _getTtlForCategory(String category) {
    return _ttlConfig[category] ?? const Duration(minutes: 5);
  }

  void _updateStats(String key, {required bool isHit}) {
    final stats = _stats.putIfAbsent(key, () => MemoStats());

    if (isHit) {
      stats.hits++;
    } else {
      stats.misses++;
    }

    stats.lastAccessed = DateTime.now();
  }

  double _calculateOverallHitRatio() {
    if (_stats.isEmpty) return 0.0;

    int totalHits = 0;
    int totalMisses = 0;

    for (final stats in _stats.values) {
      totalHits += stats.hits;
      totalMisses += stats.misses;
    }

    final total = totalHits + totalMisses;
    return total > 0 ? totalHits / total : 0.0;
  }

  /// Limpar todo o cache
  void clearAll() {
    _memoCache.clear();
    _lazyCache.clear();
    _categoryIndex.clear();
    _stats.clear();
    _pendingOperations.clear();
  }

  /// Setup de limpeza automática
  void setupAutomaticCleanup(
      {Duration interval = const Duration(minutes: 15)}) {
    Timer.periodic(interval, (_) => cleanupExpired());
  }
}

/// Entrada de memoização com metadados
class MemoizedEntry {
  final dynamic value;
  final DateTime createdAt;
  final String category;
  final List<String> dependencies;

  MemoizedEntry({
    required this.value,
    required this.createdAt,
    required this.category,
    required this.dependencies,
  });

  bool isExpired(Duration ttl, [DateTime? now]) {
    final current = now ?? DateTime.now();
    return current.difference(createdAt) > ttl;
  }
}

/// Valor lazy com TTL
class LazyValue {
  final dynamic value;
  final DateTime createdAt;
  final String category;

  LazyValue({
    required this.value,
    required this.createdAt,
    required this.category,
  });

  bool isExpired(Duration ttl, [DateTime? now]) {
    final current = now ?? DateTime.now();
    return current.difference(createdAt) > ttl;
  }
}

/// Estatísticas de memoização
class MemoStats {
  int hits = 0;
  int misses = 0;
  DateTime? lastAccessed;

  double get hitRatio {
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  Map<String, dynamic> toMap() => {
        'hits': hits,
        'misses': misses,
        'hit_ratio': hitRatio,
        'last_accessed': lastAccessed?.toIso8601String(),
      };
}
