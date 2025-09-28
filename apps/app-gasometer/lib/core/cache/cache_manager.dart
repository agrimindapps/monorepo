/// Interface for cache management with TTL support
abstract class CacheManager<K, V> {
  /// Retrieves a value from cache
  V? get(K key);
  
  /// Stores a value in cache with optional TTL
  void put(K key, V value, {Duration? ttl});
  
  /// Removes a value from cache
  void remove(K key);
  
  /// Clears all cached values
  void clear();
  
  /// Returns the number of cached items
  int get size;
  
  /// Returns true if cache contains the key
  bool containsKey(K key);
}

/// Cache entry with TTL support
class CacheEntry<V> {

  CacheEntry(this.value, this.createdAt, this.ttl);
  final V value;
  final DateTime createdAt;
  final Duration? ttl;

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }
}

/// In-memory cache implementation with TTL support
class MemoryCacheManager<K, V> implements CacheManager<K, V> {

  MemoryCacheManager({
    int maxSize = 100,
    Duration defaultTtl = const Duration(minutes: 5),
  }) : _maxSize = maxSize, _defaultTtl = defaultTtl;
  final Map<K, CacheEntry<V>> _cache = {};
  final int _maxSize;
  final Duration _defaultTtl;

  @override
  V? get(K key) {
    _cleanExpired();
    
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value;
  }

  @override
  void put(K key, V value, {Duration? ttl}) {
    _cleanExpired();
    _ensureCapacity();
    
    final entry = CacheEntry(
      value, 
      DateTime.now(), 
      ttl ?? _defaultTtl,
    );
    
    _cache[key] = entry;
  }

  @override
  void remove(K key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  int get size => _cache.length;

  @override
  bool containsKey(K key) {
    _cleanExpired();
    return _cache.containsKey(key) && !_cache[key]!.isExpired;
  }

  /// Removes expired entries
  void _cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      return entry.ttl != null && 
             now.difference(entry.createdAt) > entry.ttl!;
    });
  }

  /// Ensures cache doesn't exceed max size (LRU eviction)
  void _ensureCapacity() {
    if (_cache.length >= _maxSize) {
      // Simple LRU: remove oldest entry
      DateTime oldestTime = DateTime.now();
      K? oldestKey;
      
      for (final entry in _cache.entries) {
        if (entry.value.createdAt.isBefore(oldestTime)) {
          oldestTime = entry.value.createdAt;
          oldestKey = entry.key;
        }
      }
      
      if (oldestKey != null) {
        _cache.remove(oldestKey);
      }
    }
  }

  /// Gets cache statistics
  Map<String, dynamic> getStats() {
    _cleanExpired();
    
    int expiredCount = 0;
    int validCount = 0;
    
    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return {
      'totalEntries': _cache.length,
      'validEntries': validCount,
      'expiredEntries': expiredCount,
      'maxSize': _maxSize,
      'defaultTtlMinutes': _defaultTtl.inMinutes,
    };
  }
}

/// Base cached repository mixin
mixin CachedRepository<T> {
  CacheManager<String, T>? _cache;
  CacheManager<String, List<T>>? _listCache;
  bool _isInitialized = false;
  
  /// Initialize cache (call this in repository constructor)
  void initializeCache({
    int maxSize = 100,
    Duration defaultTtl = const Duration(minutes: 5),
  }) {
    // Prevent double initialization
    if (_isInitialized) {
      return;
    }
    
    _cache = MemoryCacheManager<String, T>(
      maxSize: maxSize,
      defaultTtl: defaultTtl,
    );
    _listCache = MemoryCacheManager<String, List<T>>(
      maxSize: maxSize ~/ 2,
      defaultTtl: defaultTtl,
    );
    _isInitialized = true;
  }

  /// Get cached entity
  T? getCachedEntity(String key) {
    return _cache?.get(key);
  }

  /// Cache entity
  void cacheEntity(String key, T entity, {Duration? ttl}) {
    _cache?.put(key, entity, ttl: ttl);
  }

  /// Get cached list
  List<T>? getCachedList(String key) {
    return _listCache?.get(key);
  }

  /// Cache list
  void cacheList(String key, List<T> list, {Duration? ttl}) {
    _listCache?.put(key, list, ttl: ttl);
  }

  /// Invalidate specific cache entry
  void invalidateCache(String key) {
    _cache?.remove(key);
  }

  /// Invalidate list cache entry
  void invalidateListCache(String key) {
    _listCache?.remove(key);
  }

  /// Clear all cache
  void clearAllCache() {
    _cache?.clear();
    _listCache?.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final entityStats = _cache is MemoryCacheManager 
        ? (_cache as MemoryCacheManager).getStats() 
        : {'type': 'uninitialized'};
    
    final listStats = _listCache is MemoryCacheManager 
        ? (_listCache as MemoryCacheManager).getStats() 
        : {'type': 'uninitialized'};

    return {
      'entityCache': entityStats,
      'listCache': listStats,
      'isInitialized': _isInitialized,
    };
  }

  /// Generate cache key for entity
  String entityCacheKey(String id) => 'entity_$id';

  /// Generate cache key for vehicle-specific queries
  String vehicleCacheKey(String vehicleId, String suffix) => 'vehicle_${vehicleId}_$suffix';

  /// Generate cache key for period queries
  String periodCacheKey(DateTime start, DateTime end, String suffix) {
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    return 'period_${startMs}_${endMs}_$suffix';
  }

  /// Generate cache key for type queries
  String typeCacheKey(String type, String suffix) => 'type_${type}_$suffix';
}