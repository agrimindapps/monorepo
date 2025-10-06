import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Cache entry with metadata
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;

  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiresAt,
    this.metadata = const {},
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get age => DateTime.now().difference(createdAt);

  Map<String, dynamic> toJson() => {
    'data': data,
    'created_at': createdAt.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'metadata': metadata,
  };

  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return CacheEntry<T>(
      data: dataParser(json['data']),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Cache strategy configuration
enum CacheStrategy {
  /// Cache never expires
  permanent,

  /// Cache expires after TTL
  ttl,

  /// Cache expires when app restarts
  session,

  /// Cache expires when memory pressure is high
  memory,

  /// Cache uses LRU eviction
  lru,
}

/// Cache configuration
class CacheConfig {
  final Duration? ttl;
  final int? maxSize;
  final CacheStrategy strategy;
  final bool persistToDisk;
  final String? storageKey;

  const CacheConfig({
    this.ttl,
    this.maxSize,
    this.strategy = CacheStrategy.ttl,
    this.persistToDisk = false,
    this.storageKey,
  });
}

/// Cache statistics
class CacheStats {
  final String cacheKey;
  final int hitCount;
  final int missCount;
  final int evictionCount;
  final int currentSize;
  final Duration avgHitTime;
  final double hitRatio;

  CacheStats({
    required this.cacheKey,
    required this.hitCount,
    required this.missCount,
    required this.evictionCount,
    required this.currentSize,
    required this.avgHitTime,
    required this.hitRatio,
  });

  Map<String, dynamic> toJson() => {
    'cache_key': cacheKey,
    'hit_count': hitCount,
    'miss_count': missCount,
    'eviction_count': evictionCount,
    'current_size': currentSize,
    'avg_hit_time_ms': avgHitTime.inMilliseconds,
    'hit_ratio': hitRatio,
  };
}

/// Advanced Cache Management Service for ReceitauAgro
/// Provides intelligent caching with multiple strategies and persistence
class CacheManagementService {
  static CacheManagementService? _instance;
  static CacheManagementService get instance =>
      _instance ??= CacheManagementService._();

  CacheManagementService._();

  late ILocalStorageRepository _localStorage;
  bool _isInitialized = false;
  final Map<String, Map<String, CacheEntry<dynamic>>> _memoryCaches = {};
  final Map<String, CacheConfig> _cacheConfigs = {};
  final Map<String, List<String>> _lruOrders = {};
  final Map<String, int> _hitCounts = {};
  final Map<String, int> _missCounts = {};
  final Map<String, int> _evictionCounts = {};
  final Map<String, List<Duration>> _hitTimes = {};

  Timer? _cleanupTimer;
  Timer? _statsTimer;

  /// Initialize cache management
  Future<void> initialize({
    required ILocalStorageRepository localStorage,
  }) async {
    if (_isInitialized) return;

    _localStorage = localStorage;
    await _setupDefaultCaches();
    _startCleanupTimer();
    _startStatsCollection();

    _isInitialized = true;

    if (kDebugMode) {
      print('📦 Cache Management Service initialized');
    }
  }

  /// Setup default cache configurations for ReceitauAgro
  Future<void> _setupDefaultCaches() async {
    await createCache(
      'images',
      const CacheConfig(
        ttl: Duration(days: 7),
        maxSize: 500,
        strategy: CacheStrategy.lru,
        persistToDisk: true,
        storageKey: 'receituagro_image_cache',
      ),
    );
    await createCache(
      'api_responses',
      const CacheConfig(
        ttl: Duration(minutes: 30),
        maxSize: 200,
        strategy: CacheStrategy.ttl,
        persistToDisk: false,
      ),
    );
    await createCache(
      'search_results',
      const CacheConfig(
        ttl: Duration(minutes: 15),
        maxSize: 50,
        strategy: CacheStrategy.session,
        persistToDisk: false,
      ),
    );
    await createCache(
      'static_data',
      const CacheConfig(
        strategy: CacheStrategy.permanent,
        maxSize: 100,
        persistToDisk: true,
        storageKey: 'receituagro_static_cache',
      ),
    );
    await createCache(
      'user_prefs',
      const CacheConfig(
        strategy: CacheStrategy.permanent,
        maxSize: 20,
        persistToDisk: true,
        storageKey: 'receituagro_user_prefs',
      ),
    );
    await createCache(
      'diagnostics',
      const CacheConfig(
        ttl: Duration(hours: 2),
        maxSize: 100,
        strategy: CacheStrategy.ttl,
        persistToDisk: false,
      ),
    );
  }

  /// Create a new cache with configuration
  Future<void> createCache(String cacheKey, CacheConfig config) async {
    _memoryCaches[cacheKey] = <String, CacheEntry<dynamic>>{};
    _cacheConfigs[cacheKey] = config;
    _lruOrders[cacheKey] = [];
    _hitCounts[cacheKey] = 0;
    _missCounts[cacheKey] = 0;
    _evictionCounts[cacheKey] = 0;
    _hitTimes[cacheKey] = [];
    if (config.persistToDisk && config.storageKey != null) {
      await _loadCacheFromDisk(cacheKey, config.storageKey!);
    }

    if (kDebugMode) {
      print('📦 Created cache: $cacheKey with strategy: ${config.strategy}');
    }
  }

  /// Get data from cache
  Future<T?> get<T>(
    String cacheKey,
    String itemKey, {
    T Function(dynamic)? parser,
  }) async {
    final startTime = DateTime.now();

    try {
      final cache = _memoryCaches[cacheKey];
      if (cache == null) {
        _recordMiss(cacheKey, startTime);
        return null;
      }

      final entry = cache[itemKey];
      if (entry == null) {
        _recordMiss(cacheKey, startTime);
        return null;
      }
      if (entry.isExpired) {
        await _removeFromCache(cacheKey, itemKey);
        _recordMiss(cacheKey, startTime);
        return null;
      }
      await _updateLRU(cacheKey, itemKey);
      _recordHit(cacheKey, startTime);
      if (parser != null && entry.data is! T) {
        return parser(entry.data);
      }

      return entry.data as T;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache get error for $cacheKey:$itemKey - $e');
      }
      _recordMiss(cacheKey, startTime);
      return null;
    }
  }

  /// Put data into cache
  Future<void> put<T>(
    String cacheKey,
    String itemKey,
    T data, {
    Duration? customTTL,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final cache = _memoryCaches[cacheKey];
      final config = _cacheConfigs[cacheKey];

      if (cache == null || config == null) {
        throw Exception('Cache $cacheKey not found');
      }
      DateTime? expiresAt;
      switch (config.strategy) {
        case CacheStrategy.ttl:
          final ttl = customTTL ?? config.ttl;
          if (ttl != null) {
            expiresAt = DateTime.now().add(ttl);
          }
          break;
        case CacheStrategy.session:
          break;
        case CacheStrategy.permanent:
        case CacheStrategy.memory:
        case CacheStrategy.lru:
          break;
      }
      final entry = CacheEntry<T>(
        data: data,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        metadata: metadata ?? {},
      );
      await _ensureCacheSize(cacheKey);
      cache[itemKey] = entry;
      await _updateLRU(cacheKey, itemKey);
      if (config.persistToDisk && config.storageKey != null) {
        await _persistCacheToDisk(cacheKey, config.storageKey!);
      }

      if (kDebugMode) {
        print('📦 Cached $cacheKey:$itemKey (expires: $expiresAt)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache put error for $cacheKey:$itemKey - $e');
      }
    }
  }

  /// Remove specific item from cache
  Future<void> remove(String cacheKey, String itemKey) async {
    await _removeFromCache(cacheKey, itemKey);
  }

  /// Clear entire cache
  Future<void> clear(String cacheKey) async {
    final cache = _memoryCaches[cacheKey];
    if (cache != null) {
      cache.clear();
      _lruOrders[cacheKey]?.clear();

      final config = _cacheConfigs[cacheKey];
      if (config?.persistToDisk == true && config?.storageKey != null) {
        await _localStorage.remove(key: config!.storageKey!);
      }

      if (kDebugMode) {
        print('📦 Cleared cache: $cacheKey');
      }
    }
  }

  /// Clear all caches
  Future<void> clearAll() async {
    for (final cacheKey in _memoryCaches.keys.toList()) {
      await clear(cacheKey);
    }

    if (kDebugMode) {
      print('📦 Cleared all caches');
    }
  }

  /// Get cache statistics
  CacheStats getStats(String cacheKey) {
    final hitCount = _hitCounts[cacheKey] ?? 0;
    final missCount = _missCounts[cacheKey] ?? 0;
    final evictionCount = _evictionCounts[cacheKey] ?? 0;
    final currentSize = _memoryCaches[cacheKey]?.length ?? 0;

    final totalRequests = hitCount + missCount;
    final hitRatio = totalRequests > 0 ? hitCount / totalRequests : 0.0;

    final hitTimes = _hitTimes[cacheKey] ?? [];
    final avgHitTime =
        hitTimes.isEmpty
            ? Duration.zero
            : Duration(
              microseconds:
                  hitTimes
                      .map((d) => d.inMicroseconds)
                      .reduce((a, b) => a + b) ~/
                  hitTimes.length,
            );

    return CacheStats(
      cacheKey: cacheKey,
      hitCount: hitCount,
      missCount: missCount,
      evictionCount: evictionCount,
      currentSize: currentSize,
      avgHitTime: avgHitTime,
      hitRatio: hitRatio,
    );
  }

  /// Get all cache statistics
  Map<String, CacheStats> getAllStats() {
    return Map.fromEntries(
      _memoryCaches.keys.map((key) => MapEntry(key, getStats(key))),
    );
  }

  /// Preload cache with frequently used data
  Future<void> preloadCache() async {
    try {
      if (kDebugMode) {
        print('📦 Starting cache preload...');
      }
      await _preloadStaticData();
      await _preloadUserPreferences();
      await _preloadFrequentImages();

      if (kDebugMode) {
        print('📦 Cache preload completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache preload failed: $e');
      }
    }
  }

  /// Optimize caches based on usage patterns
  Future<void> optimizeCaches() async {
    try {
      if (kDebugMode) {
        print('📦 Starting cache optimization...');
      }

      for (final cacheKey in _memoryCaches.keys) {
        final stats = getStats(cacheKey);
        if (stats.hitRatio > 0.8 && stats.currentSize > 0) {
          await _optimizeCacheSize(cacheKey, increase: true);
        } else if (stats.hitRatio < 0.3 && stats.currentSize > 10) {
          await _optimizeCacheSize(cacheKey, increase: false);
        }
        await _cleanExpiredEntries(cacheKey);
      }

      if (kDebugMode) {
        print('📦 Cache optimization completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cache optimization failed: $e');
      }
    }
  }

  Future<void> _removeFromCache(String cacheKey, String itemKey) async {
    final cache = _memoryCaches[cacheKey];
    if (cache != null) {
      cache.remove(itemKey);
      _lruOrders[cacheKey]?.remove(itemKey);

      final config = _cacheConfigs[cacheKey];
      if (config?.persistToDisk == true && config?.storageKey != null) {
        await _persistCacheToDisk(cacheKey, config!.storageKey!);
      }
    }
  }

  Future<void> _ensureCacheSize(String cacheKey) async {
    final config = _cacheConfigs[cacheKey];
    final cache = _memoryCaches[cacheKey];

    if (config?.maxSize == null || cache == null) return;

    while (cache.length >= config!.maxSize!) {
      await _evictLRU(cacheKey);
    }
  }

  Future<void> _evictLRU(String cacheKey) async {
    final lruOrder = _lruOrders[cacheKey];
    if (lruOrder != null && lruOrder.isNotEmpty) {
      final oldestKey = lruOrder.removeAt(0);
      await _removeFromCache(cacheKey, oldestKey);

      final count = _evictionCounts[cacheKey] ?? 0;
      _evictionCounts[cacheKey] = count + 1;
    }
  }

  Future<void> _updateLRU(String cacheKey, String itemKey) async {
    final lruOrder = _lruOrders[cacheKey];
    if (lruOrder != null) {
      lruOrder.remove(itemKey);
      lruOrder.add(itemKey);
    }
  }

  void _recordHit(String cacheKey, DateTime startTime) {
    final count = _hitCounts[cacheKey] ?? 0;
    _hitCounts[cacheKey] = count + 1;

    final duration = DateTime.now().difference(startTime);
    final hitTimes = _hitTimes[cacheKey] ?? [];
    hitTimes.add(duration);
    if (hitTimes.length > 100) {
      hitTimes.removeAt(0);
    }
  }

  void _recordMiss(String cacheKey, DateTime startTime) {
    final count = _missCounts[cacheKey] ?? 0;
    _missCounts[cacheKey] = count + 1;
  }

  Future<void> _loadCacheFromDisk(String cacheKey, String storageKey) async {
    try {
      final result = await _localStorage.get<String>(key: storageKey);
      await result.fold(
        (failure) async {
          if (kDebugMode) {
            print('📦 No cached data found for $cacheKey');
          }
        },
        (data) async {
          if (data != null) {
            final cacheData = json.decode(data) as Map<String, dynamic>;
            final cache = _memoryCaches[cacheKey]!;

            for (final entry in cacheData.entries) {
              final cacheEntry = CacheEntry.fromJson(
                entry.value as Map<String, dynamic>,
                (data) => data,
              );

              if (!cacheEntry.isExpired) {
                cache[entry.key] = cacheEntry;
                _lruOrders[cacheKey]?.add(entry.key);
              }
            }

            if (kDebugMode) {
              print('📦 Loaded ${cache.length} items from disk for $cacheKey');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load cache from disk for $cacheKey: $e');
      }
    }
  }

  Future<void> _persistCacheToDisk(String cacheKey, String storageKey) async {
    try {
      final cache = _memoryCaches[cacheKey];
      if (cache == null || cache.isEmpty) return;

      final cacheData = Map<String, dynamic>.fromEntries(
        cache.entries.map((entry) => MapEntry(entry.key, entry.value.toJson())),
      );

      await _localStorage.save<String>(
        key: storageKey,
        data: json.encode(cacheData),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to persist cache to disk for $cacheKey: $e');
      }
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await _performCleanup();
    });
  }

  void _startStatsCollection() {
    _statsTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _collectAndLogStats();
    });
  }

  Future<void> _performCleanup() async {
    for (final cacheKey in _memoryCaches.keys) {
      await _cleanExpiredEntries(cacheKey);
    }
  }

  Future<void> _cleanExpiredEntries(String cacheKey) async {
    final cache = _memoryCaches[cacheKey];
    if (cache == null) return;

    final expiredKeys = <String>[];

    for (final entry in cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await _removeFromCache(cacheKey, key);
    }

    if (kDebugMode && expiredKeys.isNotEmpty) {
      print('📦 Cleaned ${expiredKeys.length} expired entries from $cacheKey');
    }
  }

  void _collectAndLogStats() {
    if (kDebugMode) {
      final stats = getAllStats();
      print('📦 Cache Statistics:');

      for (final entry in stats.entries) {
        final stat = entry.value;
        print(
          '  ${entry.key}: ${stat.currentSize} items, '
          '${(stat.hitRatio * 100).toStringAsFixed(1)}% hit ratio, '
          '${stat.avgHitTime.inMicroseconds}μs avg',
        );
      }
    }
  }

  Future<void> _preloadStaticData() async {
    await put('static_data', 'app_config', {'version': '1.0.0'});
    await put('static_data', 'feature_flags', {'new_ui': true});
  }

  Future<void> _preloadUserPreferences() async {
    await put('user_prefs', 'theme', 'light');
    await put('user_prefs', 'language', 'pt-BR');
  }

  Future<void> _preloadFrequentImages() async {
    final commonImages = ['logo.png', 'placeholder.png', 'default_avatar.png'];

    for (final image in commonImages) {
      await put(
        'images',
        image,
        Uint8List.fromList([1, 2, 3]),
      ); // Mock image data
    }
  }

  Future<void> _optimizeCacheSize(
    String cacheKey, {
    required bool increase,
  }) async {
    final config = _cacheConfigs[cacheKey];
    if (config?.maxSize == null) return;

    final currentSize = config!.maxSize!;
    final newSize =
        increase ? (currentSize * 1.2).round() : (currentSize * 0.8).round();
    _cacheConfigs[cacheKey] = CacheConfig(
      ttl: config.ttl,
      maxSize: newSize,
      strategy: config.strategy,
      persistToDisk: config.persistToDisk,
      storageKey: config.storageKey,
    );

    if (kDebugMode) {
      print('📦 Optimized $cacheKey size: $currentSize → $newSize');
    }
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _statsTimer?.cancel();
    _memoryCaches.clear();
    _cacheConfigs.clear();
    _lruOrders.clear();
    _hitCounts.clear();
    _missCounts.clear();
    _evictionCounts.clear();
    _hitTimes.clear();
    _isInitialized = false;
  }
}
