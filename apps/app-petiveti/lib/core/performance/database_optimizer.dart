import 'dart:async';
import 'dart:developer';

import 'package:hive/hive.dart';

/// Sistema avançado de otimização de queries e cache de banco de dados
class DatabaseOptimizer {
  static final DatabaseOptimizer _instance = DatabaseOptimizer._internal();
  factory DatabaseOptimizer() => _instance;
  DatabaseOptimizer._internal();

  final Map<String, QueryCache> _queryCache = {};
  final Map<String, DatabaseMetrics> _metrics = {};
  final List<SlowQuery> _slowQueries = [];
  
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int slowQueryThresholdMs = 100;
  static const int maxCacheEntries = 200;

  /// Executa query com cache otimizado
  Future<T> executeWithCache<T>(
    String queryKey,
    Future<T> Function() query, {
    Duration? cacheFor,
    bool forceRefresh = false,
  }) async {
    final cacheEntry = _queryCache[queryKey];
    final now = DateTime.now();

    // Verifica cache válido
    if (!forceRefresh && 
        cacheEntry != null && 
        !_isCacheExpired(cacheEntry, cacheFor ?? cacheTimeout)) {
      
      _updateMetrics(queryKey, 0, true); // Cache hit
      return cacheEntry.data as T;
    }

    // Executa query com medição de performance
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await query();
      stopwatch.stop();
      
      final executionTime = stopwatch.elapsedMilliseconds;
      
      // Armazena no cache
      _cacheResult(queryKey, result, now);
      
      // Registra métricas
      _updateMetrics(queryKey, executionTime, false);
      
      // Detecta queries lentas
      if (executionTime > slowQueryThresholdMs) {
        _recordSlowQuery(queryKey, executionTime);
      }
      
      return result;
      
    } catch (error) {
      stopwatch.stop();
      _updateMetrics(queryKey, stopwatch.elapsedMilliseconds, false, error);
      rethrow;
    }
  }

  /// Otimização específica para Hive
  Future<List<T>> optimizedHiveQuery<T>(
    Box<T> box, {
    bool Function(T)? filter,
    int Function(T, T)? sortBy,
    int? limit,
    int? offset,
    String? cacheKey,
  }) async {
    final queryKey = cacheKey ?? 'hive_${box.name}_${filter.hashCode}_${sortBy.hashCode}';
    
    return executeWithCache(
      queryKey,
      () async {
        // Implementação otimizada para Hive
        List<T> results = [];
        
        if (filter != null) {
          // Filtragem eficiente
          results = await _efficientFilter(box, filter);
        } else {
          results = box.values.toList();
        }
        
        // Ordenação se especificada
        if (sortBy != null) {
          results.sort(sortBy);
        }
        
        // Paginação
        if (offset != null) {
          results = results.skip(offset).toList();
        }
        
        if (limit != null) {
          results = results.take(limit).toList();
        }
        
        return results;
      },
    );
  }

  /// Batch operations otimizadas para Hive
  Future<void> optimizedBatchWrite<T>(
    Box<T> box,
    Map<dynamic, T> entries, {
    int batchSize = 100,
  }) async {
    final batches = _createBatches(entries, batchSize);
    
    for (final batch in batches) {
      await box.putAll(batch);
      
      // Pequena pausa para não bloquear a UI
      if (batches.length > 1) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }
  }

  /// Indexação inteligente para queries frequentes
  void createIndex<T>(
    String indexName,
    Box<T> box,
    dynamic Function(T) keyExtractor,
  ) {
    final index = <dynamic, List<T>>{};
    
    for (final item in box.values) {
      final key = keyExtractor(item);
      index.putIfAbsent(key, () => []).add(item);
    }
    
    _queryCache['index_$indexName'] = QueryCache(
      data: index,
      createdAt: DateTime.now(),
      hits: 0,
    );
  }

  /// Query com índice
  List<T> queryWithIndex<T>(
    String indexName,
    dynamic indexKey,
  ) {
    final cacheKey = 'index_$indexName';
    final indexCache = _queryCache[cacheKey];
    
    if (indexCache != null) {
      final index = indexCache.data as Map<dynamic, List<T>>;
      _queryCache[cacheKey] = indexCache.copyWith(hits: indexCache.hits + 1);
      return index[indexKey] ?? [];
    }
    
    return [];
  }

  /// Compactação otimizada de banco
  Future<void> optimizedCompact(Box<dynamic> box) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      await box.compact();
      stopwatch.stop();
      
      log('Box ${box.name} compacted in ${stopwatch.elapsedMilliseconds}ms', 
          name: 'DatabaseOptimizer');
          
    } catch (error) {
      log('Error compacting box ${box.name}: $error', name: 'DatabaseOptimizer');
      rethrow;
    }
  }

  /// Limpeza automática de cache
  void cleanupCache({bool aggressive = false}) {
    final keysToRemove = <String>[];
    
    for (final entry in _queryCache.entries) {
      final cache = entry.value;
      
      if (aggressive || _isCacheExpired(cache, cacheTimeout)) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _queryCache.remove(key);
    }
    
    // Limitar tamanho do cache
    while (_queryCache.length > maxCacheEntries) {
      final oldestKey = _findOldestCacheKey();
      if (oldestKey != null) {
        _queryCache.remove(oldestKey);
      } else {
        break;
      }
    }
  }

  /// Análise de performance do banco
  DatabasePerformanceReport analyzePerformance({Duration? period}) {
    final now = DateTime.now();
    final startTime = period != null ? now.subtract(period) : null;
    
    final relevantQueries = startTime != null
        ? _slowQueries.where((q) => q.timestamp.isAfter(startTime)).toList()
        : _slowQueries;
    
    final cacheStats = _calculateCacheStats();
    
    return DatabasePerformanceReport(
      generatedAt: now,
      period: period,
      totalQueries: _metrics.values.fold(0, (sum, m) => sum + m.executionCount),
      slowQueries: relevantQueries,
      cacheHitRate: cacheStats.hitRate,
      cacheSize: _queryCache.length,
      recommendations: _generateRecommendations(),
    );
  }

  /// Otimizações automáticas
  Future<void> runAutoOptimizations() async {
    // Limpeza de cache
    cleanupCache();
    
    // Compactação de boxes com muitas operações
    for (final metric in _metrics.values) {
      if (metric.executionCount > 1000 && metric.boxName != null) {
        try {
          final box = await Hive.openBox<dynamic>(metric.boxName!);
          if (box.length > 500) {
            await optimizedCompact(box);
          }
        } catch (e) {
          // Ignora erros de compactação
        }
      }
    }
    
    log('Auto-optimization completed', name: 'DatabaseOptimizer');
  }

  // Métodos auxiliares privados
  
  Future<List<T>> _efficientFilter<T>(Box<T> box, bool Function(T) filter) async {
    final results = <T>[];
    const batchSize = 1000;
    
    final values = box.values.toList();
    
    for (int i = 0; i < values.length; i += batchSize) {
      final batch = values.skip(i).take(batchSize);
      
      for (final item in batch) {
        if (filter(item)) {
          results.add(item);
        }
      }
      
      // Permite outras operações rodarem
      if (i + batchSize < values.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    
    return results;
  }

  List<Map<dynamic, T>> _createBatches<T>(Map<dynamic, T> entries, int batchSize) {
    final batches = <Map<dynamic, T>>[];
    final entriesList = entries.entries.toList();
    
    for (int i = 0; i < entriesList.length; i += batchSize) {
      final batch = <dynamic, T>{};
      final batchEntries = entriesList.skip(i).take(batchSize);
      
      for (final entry in batchEntries) {
        batch[entry.key] = entry.value;
      }
      
      batches.add(batch);
    }
    
    return batches;
  }

  void _cacheResult(String key, dynamic data, DateTime createdAt) {
    _queryCache[key] = QueryCache(
      data: data,
      createdAt: createdAt,
      hits: 0,
    );
  }

  bool _isCacheExpired(QueryCache cache, Duration timeout) {
    return DateTime.now().difference(cache.createdAt) > timeout;
  }

  void _updateMetrics(String queryKey, int executionTime, bool cacheHit, [dynamic error]) {
    final metric = _metrics[queryKey] ??= DatabaseMetrics(
      queryKey: queryKey,
      executionCount: 0,
      totalExecutionTime: 0,
      cacheHits: 0,
      errors: 0,
    );

    _metrics[queryKey] = metric.copyWith(
      executionCount: metric.executionCount + 1,
      totalExecutionTime: metric.totalExecutionTime + executionTime,
      cacheHits: metric.cacheHits + (cacheHit ? 1 : 0),
      errors: metric.errors + (error != null ? 1 : 0),
    );
  }

  void _recordSlowQuery(String queryKey, int executionTime) {
    _slowQueries.add(SlowQuery(
      queryKey: queryKey,
      executionTime: executionTime,
      timestamp: DateTime.now(),
    ));
    
    // Manter apenas as 50 queries mais recentes
    if (_slowQueries.length > 50) {
      _slowQueries.removeAt(0);
    }
  }

  CacheStats _calculateCacheStats() {
    final totalHits = _queryCache.values.fold(0, (sum, cache) => sum + cache.hits);
    final totalQueries = _metrics.values.fold(0, (sum, metric) => sum + metric.executionCount);
    
    return CacheStats(
      hitRate: totalQueries > 0 ? totalHits / totalQueries : 0.0,
      totalEntries: _queryCache.length,
    );
  }

  String? _findOldestCacheKey() {
    DateTime? oldest;
    String? oldestKey;
    
    for (final entry in _queryCache.entries) {
      if (oldest == null || entry.value.createdAt.isBefore(oldest)) {
        oldest = entry.value.createdAt;
        oldestKey = entry.key;
      }
    }
    
    return oldestKey;
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    // Recomendar índices para queries frequentes
    final frequentQueries = _metrics.values
        .where((m) => m.executionCount > 10)
        .toList()
      ..sort((a, b) => b.executionCount.compareTo(a.executionCount));
    
    if (frequentQueries.isNotEmpty) {
      recommendations.add('Consider creating indices for frequent queries: ${frequentQueries.take(3).map((q) => q.queryKey).join(', ')}');
    }
    
    // Recomendar cache para queries lentas
    final slowFrequentQueries = _slowQueries
        .where((q) => (_metrics[q.queryKey]?.executionCount ?? 0) > 5)
        .toList();
    
    if (slowFrequentQueries.isNotEmpty) {
      recommendations.add('Consider implementing caching for slow frequent queries');
    }
    
    // Recomendar compactação
    if (_metrics.values.any((m) => m.executionCount > 1000)) {
      recommendations.add('Consider running database compaction for heavily used boxes');
    }
    
    return recommendations;
  }
}

/// Cache de query
class QueryCache {
  final dynamic data;
  final DateTime createdAt;
  final int hits;

  const QueryCache({
    required this.data,
    required this.createdAt,
    required this.hits,
  });

  QueryCache copyWith({
    dynamic data,
    DateTime? createdAt,
    int? hits,
  }) {
    return QueryCache(
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      hits: hits ?? this.hits,
    );
  }
}

/// Métricas de banco de dados
class DatabaseMetrics {
  final String queryKey;
  final int executionCount;
  final int totalExecutionTime;
  final int cacheHits;
  final int errors;
  final String? boxName;

  const DatabaseMetrics({
    required this.queryKey,
    required this.executionCount,
    required this.totalExecutionTime,
    required this.cacheHits,
    required this.errors,
    this.boxName,
  });

  double get averageExecutionTime => 
      executionCount > 0 ? totalExecutionTime / executionCount : 0.0;

  double get cacheHitRate => 
      executionCount > 0 ? cacheHits / executionCount : 0.0;

  DatabaseMetrics copyWith({
    String? queryKey,
    int? executionCount,
    int? totalExecutionTime,
    int? cacheHits,
    int? errors,
    String? boxName,
  }) {
    return DatabaseMetrics(
      queryKey: queryKey ?? this.queryKey,
      executionCount: executionCount ?? this.executionCount,
      totalExecutionTime: totalExecutionTime ?? this.totalExecutionTime,
      cacheHits: cacheHits ?? this.cacheHits,
      errors: errors ?? this.errors,
      boxName: boxName ?? this.boxName,
    );
  }
}

/// Query lenta detectada
class SlowQuery {
  final String queryKey;
  final int executionTime;
  final DateTime timestamp;

  const SlowQuery({
    required this.queryKey,
    required this.executionTime,
    required this.timestamp,
  });
}

/// Estatísticas de cache
class CacheStats {
  final double hitRate;
  final int totalEntries;

  const CacheStats({
    required this.hitRate,
    required this.totalEntries,
  });
}

/// Relatório de performance do banco
class DatabasePerformanceReport {
  final DateTime generatedAt;
  final Duration? period;
  final int totalQueries;
  final List<SlowQuery> slowQueries;
  final double cacheHitRate;
  final int cacheSize;
  final List<String> recommendations;

  const DatabasePerformanceReport({
    required this.generatedAt,
    this.period,
    required this.totalQueries,
    required this.slowQueries,
    required this.cacheHitRate,
    required this.cacheSize,
    required this.recommendations,
  });

  bool get hasSlowQueries => slowQueries.isNotEmpty;
  bool get hasPoorCacheHitRate => cacheHitRate < 0.5;
  bool get needsOptimization => hasSlowQueries || hasPoorCacheHitRate;
}

/// Mixin para otimização automática de repositories
mixin DatabaseOptimizationMixin {
  final DatabaseOptimizer _optimizer = DatabaseOptimizer();

  /// Executa query com otimização automática
  Future<T> optimizedQuery<T>(
    String queryKey,
    Future<T> Function() query, {
    Duration? cacheFor,
  }) {
    return _optimizer.executeWithCache(queryKey, query, cacheFor: cacheFor);
  }

  /// Query Hive otimizada
  Future<List<T>> optimizedHiveQuery<T>(
    Box<T> box, {
    bool Function(T)? filter,
    int Function(T, T)? sortBy,
    int? limit,
    int? offset,
    String? cacheKey,
  }) {
    return _optimizer.optimizedHiveQuery(
      box,
      filter: filter,
      sortBy: sortBy,
      limit: limit,
      offset: offset,
      cacheKey: cacheKey,
    );
  }

  /// Batch write otimizado
  Future<void> optimizedBatchWrite<T>(Box<T> box, Map<dynamic, T> entries) {
    return _optimizer.optimizedBatchWrite(box, entries);
  }
}

/// Extension para facilitar uso
extension HiveBoxOptimization<T> on Box<T> {
  /// Query otimizada
  Future<List<T>> optimizedQuery({
    bool Function(T)? filter,
    int Function(T, T)? sortBy,
    int? limit,
    int? offset,
    String? cacheKey,
  }) {
    return DatabaseOptimizer().optimizedHiveQuery(
      this,
      filter: filter,
      sortBy: sortBy,
      limit: limit,
      offset: offset,
      cacheKey: cacheKey,
    );
  }

  /// Batch write otimizado
  Future<void> optimizedPutAll(Map<dynamic, T> entries) {
    return DatabaseOptimizer().optimizedBatchWrite(this, entries);
  }

  /// Compactação otimizada
  Future<void> optimizedCompact() {
    return DatabaseOptimizer().optimizedCompact(this);
  }
}