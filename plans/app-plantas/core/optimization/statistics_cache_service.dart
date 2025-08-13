// Dart imports:
import 'dart:async';

// Package imports:
import 'package:logging/logging.dart';

import '../cache/cache_manager.dart';
import 'memoization_manager.dart';

/// Serviço especializado de cache para estatísticas
/// Implementa estratégias avançadas de cache para resultados de estatísticas
class StatisticsCacheService {
  static StatisticsCacheService? _instance;
  static StatisticsCacheService get instance =>
      _instance ??= StatisticsCacheService._();

  StatisticsCacheService._();

  final MemoizationManager _memo = MemoizationManager.instance;
  final CacheManager _cache = CacheManager.instance;

  // Controle de recálculo automático
  final Map<String, Timer> _recalculationTimers = {};
  final Map<String, DateTime> _lastCalculation = {};

  // Métricas de performance
  final Map<String, StatCacheMetrics> _metrics = {};

  /// Estratégias de cache por tipo de estatística
  static const Map<StatisticType, StatCacheConfig> _cacheConfigs = {
    StatisticType.basic: StatCacheConfig(
      ttl: Duration(minutes: 10),
      recalculationInterval: Duration(minutes: 8),
      priority: CachePriority.medium,
    ),
    StatisticType.aggregated: StatCacheConfig(
      ttl: Duration(minutes: 20),
      recalculationInterval: Duration(minutes: 15),
      priority: CachePriority.high,
    ),
    StatisticType.realtime: StatCacheConfig(
      ttl: Duration(minutes: 2),
      recalculationInterval: Duration(minutes: 1),
      priority: CachePriority.low,
    ),
    StatisticType.historical: StatCacheConfig(
      ttl: Duration(hours: 2),
      recalculationInterval: Duration(hours: 1),
      priority: CachePriority.high,
    ),
    StatisticType.derived: StatCacheConfig(
      ttl: Duration(minutes: 15),
      recalculationInterval: Duration(minutes: 12),
      priority: CachePriority.medium,
    ),
  };

  /// Cache estatísticas com estratégia inteligente
  Future<Map<String, int>> cacheStatistics(
    String key,
    Future<Map<String, int>> Function() computation, {
    required StatisticType type,
    List<String>? dependencies,
    bool enableAutoRecalculation = true,
  }) async {
    final config = _cacheConfigs[type]!;
    final cacheKey = _buildCacheKey(key, type);

    // Inicializar métricas se não existir
    _metrics.putIfAbsent(cacheKey, () => StatCacheMetrics());
    final metrics = _metrics[cacheKey]!;

    // Tentar buscar do cache primeiro
    final cached = await _tryGetFromCache(cacheKey, config, metrics);
    if (cached != null) {
      return cached;
    }

    // Executar computation
    final startTime = DateTime.now();
    final result = await computation();
    final executionTime = DateTime.now().difference(startTime);

    // Atualizar métricas
    metrics.recordMiss(executionTime);
    _lastCalculation[cacheKey] = DateTime.now();

    // Armazenar no cache com memoização
    await _storeInCache(cacheKey, result, config, dependencies);

    // Setup recálculo automático se habilitado
    if (enableAutoRecalculation) {
      _setupAutoRecalculation(cacheKey, computation, config);
    }

    return result;
  }

  /// Cache estatísticas compostas (que dependem de outras estatísticas)
  Future<Map<String, dynamic>> cacheCompositeStatistics(
    String key,
    Future<Map<String, dynamic>> Function() computation, {
    required List<String> statisticsDependencies,
    StatisticType type = StatisticType.derived,
  }) async {
    final config = _cacheConfigs[type]!;
    final cacheKey = _buildCacheKey(key, type);

    return _memo.memoize(
      cacheKey,
      computation,
      category: 'composite_statistics',
      customTtl: config.ttl,
      dependencies: statisticsDependencies,
    );
  }

  /// Cache estatísticas em tempo real com debounce
  Future<Map<String, int>> cacheRealtimeStatistics(
    String key,
    Future<Map<String, int>> Function() computation, {
    Duration debounce = const Duration(milliseconds: 500),
  }) async {
    final cacheKey = _buildCacheKey(key, StatisticType.realtime);

    return _memo.memoizeWithDebounce(
      cacheKey,
      computation,
      category: 'realtime_statistics',
      debounce: debounce,
      customTtl: const Duration(minutes: 2),
    );
  }

  /// Pre-aquecer cache de estatísticas importantes
  Future<void> warmupStatistics(List<StatisticWarmupConfig> configs) async {
    final futures = <Future>[];

    for (final config in configs) {
      futures.add(_warmupSingleStatistic(config));
    }

    await Future.wait(futures, eagerError: false);
  }

  /// Invalidar estatísticas por dependências
  void invalidateByDependency(String dependency) {
    _memo.invalidateByDependency(dependency);

    // Cancelar timers de recálculo para estatísticas dependentes
    _cancelRecalculationTimersForDependency(dependency);
  }

  /// Invalidar estatísticas por categoria
  void invalidateByCategory(StatisticType type) {
    final category = _getCategoryForType(type);
    _memo.invalidateCategory(category);

    // Cancelar timers relacionados
    _cancelRecalculationTimersForCategory(category);
  }

  /// Forçar recálculo de uma estatística
  Future<Map<String, int>> forceRecalculate(
    String key,
    Future<Map<String, int>> Function() computation, {
    required StatisticType type,
  }) async {
    final cacheKey = _buildCacheKey(key, type);

    // Invalidar cache existente
    _memo.invalidate(cacheKey);
    _cache.invalidate(cacheKey);

    // Recalcular
    return await cacheStatistics(cacheKey, computation, type: type);
  }

  /// Obter métricas de performance
  Map<String, StatCacheMetrics> getPerformanceMetrics() {
    return Map.unmodifiable(_metrics);
  }

  /// Obter informações de debug sobre o cache
  Map<String, dynamic> getDebugInfo() {
    return {
      'active_timers': _recalculationTimers.length,
      'cached_statistics': _lastCalculation.length,
      'average_hit_ratio': _calculateAverageHitRatio(),
      'cache_configs': _cacheConfigs.map(
        (type, config) => MapEntry(type.name, config.toMap()),
      ),
      'memo_debug': _memo.getDebugInfo(),
    };
  }

  // Métodos privados
  Future<Map<String, int>?> _tryGetFromCache(
    String cacheKey,
    StatCacheConfig config,
    StatCacheMetrics metrics,
  ) async {
    try {
      final result = await _memo.memoize(
        cacheKey,
        () => throw StateError('Should not execute'),
        category: _getCategoryForType(_getTypeFromCacheKey(cacheKey)),
        customTtl: config.ttl,
      );

      metrics.recordHit();
      return result as Map<String, int>;
    } catch (_) {
      // Cache miss
      return null;
    }
  }

  Future<void> _storeInCache(
    String cacheKey,
    Map<String, int> result,
    StatCacheConfig config,
    List<String>? dependencies,
  ) async {
    await _memo.memoize(
      cacheKey,
      () async => result,
      category: _getCategoryForType(_getTypeFromCacheKey(cacheKey)),
      customTtl: config.ttl,
      dependencies: dependencies,
    );
  }

  void _setupAutoRecalculation(
    String cacheKey,
    Future<Map<String, int>> Function() computation,
    StatCacheConfig config,
  ) {
    // Cancelar timer existente se houver
    _recalculationTimers[cacheKey]?.cancel();

    _recalculationTimers[cacheKey] = Timer.periodic(
      config.recalculationInterval,
      (timer) async {
        try {
          await computation();
          _lastCalculation[cacheKey] = DateTime.now();
        } catch (error) {
          // Log error but continue
          Logger('StatisticsCacheService').warning('Error during auto-recalculation for $cacheKey', error);
        }
      },
    );
  }

  Future<void> _warmupSingleStatistic(StatisticWarmupConfig config) async {
    try {
      await cacheStatistics(
        config.key,
        config.computation,
        type: config.type,
        dependencies: config.dependencies,
        enableAutoRecalculation: config.enableAutoRecalculation,
      );
    } catch (error) {
      Logger('StatisticsCacheService').warning('Error warming up statistic ${config.key}', error);
    }
  }

  String _buildCacheKey(String key, StatisticType type) {
    return '${type.name}_$key';
  }

  String _getCategoryForType(StatisticType type) {
    return '${type.name}_statistics';
  }

  StatisticType _getTypeFromCacheKey(String cacheKey) {
    for (final type in StatisticType.values) {
      if (cacheKey.startsWith('${type.name}_')) {
        return type;
      }
    }
    return StatisticType.basic;
  }

  void _cancelRecalculationTimersForDependency(String dependency) {
    // Implementar lógica para cancelar timers baseado em dependências
    // Por simplicidade, cancelar todos os timers ativos
    for (final timer in _recalculationTimers.values) {
      timer.cancel();
    }
    _recalculationTimers.clear();
  }

  void _cancelRecalculationTimersForCategory(String category) {
    final toCancel = <String>[];

    for (final key in _recalculationTimers.keys) {
      if (key.contains(category.split('_')[0])) {
        toCancel.add(key);
      }
    }

    for (final key in toCancel) {
      _recalculationTimers[key]?.cancel();
      _recalculationTimers.remove(key);
    }
  }

  double _calculateAverageHitRatio() {
    if (_metrics.isEmpty) return 0.0;

    double totalRatio = 0.0;
    for (final metrics in _metrics.values) {
      totalRatio += metrics.hitRatio;
    }

    return totalRatio / _metrics.length;
  }

  /// Limpar recursos
  void dispose() {
    for (final timer in _recalculationTimers.values) {
      timer.cancel();
    }
    _recalculationTimers.clear();
    _lastCalculation.clear();
    _metrics.clear();
  }
}

/// Tipos de estatística para diferentes estratégias de cache
enum StatisticType {
  basic, // Estatísticas básicas (contagens simples)
  aggregated, // Estatísticas agregadas (somas, médias)
  realtime, // Estatísticas em tempo real
  historical, // Estatísticas históricas
  derived, // Estatísticas derivadas de outras
}

/// Configuração de cache por tipo de estatística
class StatCacheConfig {
  final Duration ttl;
  final Duration recalculationInterval;
  final CachePriority priority;

  const StatCacheConfig({
    required this.ttl,
    required this.recalculationInterval,
    required this.priority,
  });

  Map<String, dynamic> toMap() => {
        'ttl_minutes': ttl.inMinutes,
        'recalculation_interval_minutes': recalculationInterval.inMinutes,
        'priority': priority.name,
      };
}

/// Prioridades de cache
enum CachePriority { low, medium, high }

/// Configuração para warm-up de estatísticas
class StatisticWarmupConfig {
  final String key;
  final Future<Map<String, int>> Function() computation;
  final StatisticType type;
  final List<String>? dependencies;
  final bool enableAutoRecalculation;

  StatisticWarmupConfig({
    required this.key,
    required this.computation,
    required this.type,
    this.dependencies,
    this.enableAutoRecalculation = true,
  });
}

/// Métricas de performance para cache de estatísticas
class StatCacheMetrics {
  int _hits = 0;
  int _misses = 0;
  Duration _totalExecutionTime = Duration.zero;
  int _executionCount = 0;
  DateTime? _lastAccessed;

  void recordHit() {
    _hits++;
    _lastAccessed = DateTime.now();
  }

  void recordMiss(Duration executionTime) {
    _misses++;
    _totalExecutionTime += executionTime;
    _executionCount++;
    _lastAccessed = DateTime.now();
  }

  double get hitRatio {
    final total = _hits + _misses;
    return total > 0 ? _hits / total : 0.0;
  }

  Duration get averageExecutionTime {
    return _executionCount > 0
        ? Duration(
            microseconds: _totalExecutionTime.inMicroseconds ~/ _executionCount)
        : Duration.zero;
  }

  Map<String, dynamic> toMap() => {
        'hits': _hits,
        'misses': _misses,
        'hit_ratio': hitRatio,
        'average_execution_time_ms': averageExecutionTime.inMilliseconds,
        'total_executions': _executionCount,
        'last_accessed': _lastAccessed?.toIso8601String(),
      };
}
