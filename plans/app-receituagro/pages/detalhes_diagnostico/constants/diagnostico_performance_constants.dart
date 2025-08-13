// Constants for Detalhes Diagnostico module
// This file centralizes performance optimization configurations and cache settings

/// Performance optimization constants for parallel loading and caching
class DiagnosticoPerformanceConstants {
  // Cache configuration
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const int maxCacheSize = 100;
  static const String diagnosticoCacheKey = 'diagnostico_cache';
  static const String favoriteCacheKey = 'favorite_cache';
  static const String premiumCacheKey = 'premium_cache';

  // Timeout settings
  static const Duration dataLoadingTimeout = Duration(seconds: 10);
  static const Duration favoriteTimeout = Duration(seconds: 5);
  static const Duration premiumTimeout = Duration(seconds: 8);
  static const Duration parallelLoadingTimeout = Duration(seconds: 15);

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Performance thresholds
  static const double performanceImprovement = 0.3; // 30% improvement target
  static const int concurrentOperationsLimit = 3;
}

/// Cache entry model for diagnostic data
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  bool get isValid => !isExpired;
}

/// Cache manager for diagnostic module
class DiagnosticoCacheManager {
  static final Map<String, CacheEntry> _cache = {};

  static void put<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      ttl: ttl ?? DiagnosticoPerformanceConstants.cacheExpiration,
    );

    // Cleanup expired entries if cache is full
    if (_cache.length > DiagnosticoPerformanceConstants.maxCacheSize) {
      _cleanupExpiredEntries();
    }
  }

  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }

  static bool has(String key) {
    final entry = _cache[key];
    return entry != null && entry.isValid;
  }

  static void remove(String key) {
    _cache.remove(key);
  }

  static void clear() {
    _cache.clear();
  }

  /// Clears cache entries that match a specific pattern
  static void clearByPattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Clears premium-related cache entries specifically
  static void clearPremiumCache() {
    remove(DiagnosticoPerformanceConstants.premiumCacheKey);
  }

  /// Gets cache statistics for monitoring purposes
  static Map<String, dynamic> getCacheStats() {
    final validEntries = _cache.values.where((entry) => entry.isValid).length;
    final expiredEntries = _cache.values.where((entry) => entry.isExpired).length;
    
    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'cacheHitRatio': validEntries / (_cache.isNotEmpty ? _cache.length : 1),
    };
  }

  static void _cleanupExpiredEntries() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}
