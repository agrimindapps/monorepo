// Cache service interface for unified cache management
// Defines standard operations for memory and disk cache strategies

import 'cache_entry.dart';

/// Cache storage strategy enumeration
enum CacheStrategy {
  memory,      // Fast in-memory cache (lost on app restart)
  disk,        // Persistent disk cache (slower but persistent)
  hybrid,      // Memory + disk fallback for best performance
}

/// Cache configuration model
class CacheConfig {
  final Duration defaultTtl;
  final int maxMemoryEntries;
  final int maxDiskEntries;
  final CacheStrategy strategy;
  final bool enableStatistics;
  final bool enableCleanup;

  const CacheConfig({
    this.defaultTtl = const Duration(minutes: 15),
    this.maxMemoryEntries = 100,
    this.maxDiskEntries = 500,
    this.strategy = CacheStrategy.hybrid,
    this.enableStatistics = true,
    this.enableCleanup = true,
  });
}

/// Unified cache service interface
abstract class ICacheService {
  /// Gets cache configuration
  CacheConfig get config;

  /// Stores data in cache with optional TTL and metadata
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  });

  /// Retrieves data from cache, returns null if expired or not found
  Future<T?> get<T>(String key);

  /// Checks if key exists and is valid in cache
  Future<bool> has(String key);

  /// Removes specific cache entry
  Future<void> remove(String key);

  /// Clears all cache entries
  Future<void> clear();

  /// Clears cache entries matching pattern (contains, startsWith, etc.)
  Future<void> clearByPattern(String pattern, {bool useRegex = false});

  /// Clears cache entries by prefix
  Future<void> clearByPrefix(String prefix);

  /// Clears expired cache entries
  Future<void> clearExpired();

  /// Gets cache statistics for monitoring
  Future<Map<String, dynamic>> getStats();

  /// Gets list of all cache keys
  Future<List<String>> getKeys();

  /// Gets cache entry metadata without deserializing data
  Future<CacheEntry?> getEntry(String key);

  /// Updates TTL for existing cache entry
  Future<bool> refreshTtl(String key, Duration newTtl);

  /// Preloads cache with multiple entries (batch operation)
  Future<void> putBatch<T>(Map<String, T> entries, {Duration? ttl});

  /// Gets multiple cache entries (batch operation)
  Future<Map<String, T?>> getBatch<T>(List<String> keys);
}

/// Cache event types for monitoring
enum CacheEvent {
  hit,
  miss,
  put,
  remove,
  expired,
  cleanup,
}

/// Cache statistics model
class CacheStatistics {
  final int totalEntries;
  final int memoryEntries;
  final int diskEntries;
  final int validEntries;
  final int expiredEntries;
  final double hitRatio;
  final double memoryUsageBytes;
  final double diskUsageBytes;
  final DateTime lastCleanup;
  final Map<String, int> eventCounts;

  CacheStatistics({
    required this.totalEntries,
    required this.memoryEntries,
    required this.diskEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hitRatio,
    required this.memoryUsageBytes,
    required this.diskUsageBytes,
    required this.lastCleanup,
    required this.eventCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalEntries': totalEntries,
      'memoryEntries': memoryEntries,
      'diskEntries': diskEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'hitRatio': hitRatio,
      'memoryUsageKB': (memoryUsageBytes / 1024).round(),
      'diskUsageKB': (diskUsageBytes / 1024).round(),
      'lastCleanup': lastCleanup.toIso8601String(),
      'events': eventCounts,
    };
  }
}