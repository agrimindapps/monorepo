import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../interfaces/i_cache_manager.dart';

/// Implementação do gerenciador de cache para sincronização
/// Separada do UnifiedSyncManager seguindo Single Responsibility Principle
class CacheManagerImpl implements ICacheManager {
  // Cache interno usando Map para simplicidade
  final Map<String, _CacheEntry> _cache = {};
  final StreamController<CacheEvent> _eventController =
      StreamController<CacheEvent>.broadcast();

  // Configurações
  CacheCleanupStrategy _cleanupStrategy = const CacheCleanupStrategy();
  Timer? _cleanupTimer;
  bool _isDisposed = false;

  // Estatísticas
  int _hitCount = 0;
  int _missCount = 0;
  DateTime _lastCleanup = DateTime.now();

  @override
  Future<Either<Failure, void>> initialize() async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    try {
      // Configurar limpeza automática
      if (_cleanupStrategy.enableAutoCleanup) {
        _setupAutoCleanup();
      }

      developer.log(
        'Cache manager initialized with auto cleanup: ${_cleanupStrategy.enableAutoCleanup}',
        name: 'CacheManager',
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to initialize cache manager: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> put(
    String key,
    dynamic data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    try {
      final expiresAt =
          ttl != null
              ? DateTime.now().add(ttl)
              : DateTime.now().add(_cleanupStrategy.defaultTtl);

      final serializedData = _serializeData(data);
      final sizeBytes = utf8.encode(serializedData).length;

      final entry = _CacheEntry(
        key: key,
        data: serializedData,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        sizeBytes: sizeBytes,
        metadata: metadata ?? {},
      );

      _cache[key] = entry;

      _emitEvent(
        CacheEvent(
          type:
              _cache.containsKey(key)
                  ? CacheEventType.entryUpdated
                  : CacheEventType.entryAdded,
          key: key,
          metadata: {'size': sizeBytes},
        ),
      );

      // Verificar limites
      await _checkLimits();

      developer.log(
        'Cache entry added: $key (${sizeBytes}b, expires: ${expiresAt.toLocal()})',
        name: 'CacheManager',
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache data for key $key: $e'));
    }
  }

  @override
  Future<Either<Failure, T?>> get<T>(String key) async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    try {
      final entry = _cache[key];

      if (entry == null) {
        _missCount++;
        developer.log('Cache miss: $key', name: 'CacheManager');
        return const Right(null);
      }

      if (entry.isExpired) {
        _cache.remove(key);
        _missCount++;

        _emitEvent(CacheEvent(type: CacheEventType.entryExpired, key: key));

        developer.log('Cache entry expired: $key', name: 'CacheManager');
        return const Right(null);
      }

      _hitCount++;

      final data = _deserializeData<T>(entry.data);

      developer.log('Cache hit: $key', name: 'CacheManager');
      return Right(data);
    } catch (e) {
      _missCount++;
      return Left(CacheFailure('Failed to get cache data for key $key: $e'));
    }
  }

  @override
  Future<bool> exists(String key) async {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  @override
  Future<Either<Failure, void>> remove(String key) async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    if (_cache.remove(key) != null) {
      _emitEvent(CacheEvent(type: CacheEventType.entryRemoved, key: key));

      developer.log('Cache entry removed: $key', name: 'CacheManager');
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeMany(List<String> keys) async {
    for (final key in keys) {
      final result = await remove(key);
      if (result.isLeft()) {
        return result;
      }
    }

    developer.log('Removed ${keys.length} cache entries', name: 'CacheManager');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clear() async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    final count = _cache.length;
    _cache.clear();

    _emitEvent(
      CacheEvent(
        type: CacheEventType.cacheCleared,
        key: 'all',
        metadata: {'cleared_count': count},
      ),
    );

    developer.log(
      'Cache cleared: $count entries removed',
      name: 'CacheManager',
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearExpired() async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    final expiredKeys =
        _cache.entries
            .where((entry) => entry.value.isExpired)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    _lastCleanup = DateTime.now();

    developer.log(
      'Expired cache cleanup: ${expiredKeys.length} entries removed',
      name: 'CacheManager',
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> warmup({
    List<String>? essentialKeys,
    Map<String, dynamic>? preloadData,
  }) async {
    if (_isDisposed) {
      return const Left(CacheFailure('Cache manager has been disposed'));
    }

    try {
      // Preload data if provided
      if (preloadData != null) {
        for (final entry in preloadData.entries) {
          await put(entry.key, entry.value);
        }
      }

      developer.log(
        'Cache warmup completed: ${preloadData?.length ?? 0} entries preloaded',
        name: 'CacheManager',
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Cache warmup failed: $e'));
    }
  }

  @override
  Future<CacheStatistics> getStatistics() async {
    final totalEntries = _cache.length;
    final expiredEntries = _cache.values.where((e) => e.isExpired).length;
    final memoryUsageBytes = _cache.values.fold<int>(
      0,
      (sum, entry) => sum + entry.sizeBytes,
    );

    final entriesByType = <String, int>{};
    for (final entry in _cache.values) {
      final type = entry.metadata['type']?.toString() ?? 'unknown';
      entriesByType[type] = (entriesByType[type] ?? 0) + 1;
    }

    return CacheStatistics(
      totalEntries: totalEntries,
      expiredEntries: expiredEntries,
      memoryUsageBytes: memoryUsageBytes,
      hitCount: _hitCount,
      missCount: _missCount,
      lastCleanup: _lastCleanup,
      entriesByType: entriesByType,
    );
  }

  @override
  Future<CacheEntryInfo?> getEntryInfo(String key) async {
    final entry = _cache[key];
    if (entry == null) return null;

    return CacheEntryInfo(
      key: key,
      createdAt: entry.createdAt,
      expiresAt: entry.expiresAt,
      sizeBytes: entry.sizeBytes,
      metadata: entry.metadata,
      isExpired: entry.isExpired,
    );
  }

  @override
  Future<List<String>> getAllKeys() async {
    return _cache.keys.toList();
  }

  @override
  void setCleanupStrategy(CacheCleanupStrategy strategy) {
    _cleanupStrategy = strategy;

    // Reconfigurar timer de limpeza
    _cleanupTimer?.cancel();
    if (strategy.enableAutoCleanup) {
      _setupAutoCleanup();
    }

    developer.log(
      'Cache cleanup strategy updated: cleanup interval ${strategy.cleanupInterval}',
      name: 'CacheManager',
    );
  }

  @override
  Stream<CacheEvent> get eventStream => _eventController.stream;

  @override
  Future<CacheHealthCheck> checkHealth() async {
    final issues = <String>[];
    final metrics = <String, dynamic>{};

    // Verificar entradas expiradas
    final expiredCount = _cache.values.where((e) => e.isExpired).length;
    if (expiredCount > _cache.length * 0.3) {
      issues.add('High number of expired entries: $expiredCount');
    }

    // Verificar uso de memória
    final memoryUsage = _cache.values.fold<int>(
      0,
      (sum, e) => sum + e.sizeBytes,
    );
    if (memoryUsage > _cleanupStrategy.maxMemoryBytes) {
      issues.add(
        'Memory usage exceeds limit: ${memoryUsage / (1024 * 1024)}MB',
      );
    }

    // Verificar número de entradas
    if (_cache.length > _cleanupStrategy.maxEntries) {
      issues.add('Entry count exceeds limit: ${_cache.length}');
    }

    metrics['total_entries'] = _cache.length;
    metrics['expired_entries'] = expiredCount;
    metrics['memory_usage_mb'] = memoryUsage / (1024 * 1024);
    metrics['hit_rate'] =
        (_hitCount + _missCount) > 0
            ? (_hitCount / (_hitCount + _missCount)) * 100
            : 0;

    return CacheHealthCheck(
      isHealthy: issues.isEmpty,
      issues: issues,
      metrics: metrics,
    );
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;

    _cleanupTimer?.cancel();
    _cache.clear();
    await _eventController.close();

    developer.log('Cache manager disposed', name: 'CacheManager');
  }

  // Métodos privados

  void _setupAutoCleanup() {
    _cleanupTimer = Timer.periodic(_cleanupStrategy.cleanupInterval, (timer) {
      clearExpired();
    });
  }

  Future<void> _checkLimits() async {
    // Verificar limite de entradas
    if (_cache.length > _cleanupStrategy.maxEntries) {
      await _evictOldestEntries(_cache.length - _cleanupStrategy.maxEntries);
    }

    // Verificar limite de memória
    final memoryUsage = _cache.values.fold<int>(
      0,
      (sum, e) => sum + e.sizeBytes,
    );
    if (memoryUsage > _cleanupStrategy.maxMemoryBytes) {
      await _evictByMemory(memoryUsage - _cleanupStrategy.maxMemoryBytes);
    }
  }

  Future<void> _evictOldestEntries(int count) async {
    final sortedEntries =
        _cache.entries.toList()
          ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    for (int i = 0; i < count && i < sortedEntries.length; i++) {
      _cache.remove(sortedEntries[i].key);
    }

    developer.log('Evicted $count oldest cache entries', name: 'CacheManager');
  }

  Future<void> _evictByMemory(int bytesToEvict) async {
    final sortedEntries =
        _cache.entries.toList()
          ..sort((a, b) => a.value.sizeBytes.compareTo(b.value.sizeBytes));

    int evictedBytes = 0;
    int evictedCount = 0;

    for (final entry in sortedEntries.reversed) {
      if (evictedBytes >= bytesToEvict) break;

      evictedBytes += entry.value.sizeBytes;
      evictedCount++;
      _cache.remove(entry.key);
    }

    developer.log(
      'Evicted $evictedCount entries (${evictedBytes}b) by memory',
      name: 'CacheManager',
    );
  }

  String _serializeData(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      // Fallback para dados não serializáveis
      return data.toString();
    }
  }

  T? _deserializeData<T>(String serializedData) {
    try {
      final decoded = jsonDecode(serializedData);
      return decoded as T?;
    } catch (e) {
      // Fallback: retornar string se não conseguir deserializar
      return serializedData as T?;
    }
  }

  void _emitEvent(CacheEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}

/// Entrada do cache interno
class _CacheEntry {
  final String key;
  final String data;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int sizeBytes;
  final Map<String, dynamic> metadata;

  const _CacheEntry({
    required this.key,
    required this.data,
    required this.createdAt,
    required this.expiresAt,
    required this.sizeBytes,
    required this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
