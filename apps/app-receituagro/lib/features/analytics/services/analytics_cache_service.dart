

/// Service responsible for caching analytics metrics
///
/// Following Single Responsibility Principle (SRP):
/// - Separates caching logic from business logic
/// - Provides consistent cache key generation
/// - Manages cache lifecycle and expiration

class AnalyticsCacheService {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Cache duration in minutes
  static const int cacheDurationMinutes = 15;

  /// Generate cache key for date range
  String generateCacheKey(
    String metricType,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    return '${metricType}_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
  }

  /// Check if cache entry exists and is valid
  bool hasValidCache(String key) {
    if (!_cache.containsKey(key)) return false;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age.inMinutes < cacheDurationMinutes;
  }

  /// Get cached value
  T? get<T>(String key) {
    if (!hasValidCache(key)) return null;
    return _cache[key] as T?;
  }

  /// Set cached value
  void set<T>(String key, T value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// Clear specific cache entry
  void clear(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'total_entries': _cache.length,
      'oldest_entry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b),
      'newest_entry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }
}
