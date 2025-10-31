import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../domain/entities/subscription_entity.dart';

/// In-memory cache service for subscription data
///
/// Provides fast access to recently fetched subscriptions:
/// - Reduces redundant API calls
/// - Improves offline experience
/// - Supports TTL (time-to-live) expiration
///
/// Configuration via [AdvancedSyncConfiguration.enableOfflineCache]
///
/// Example:
/// ```dart
/// // Cache subscription
/// await cacheService.set(
///   key: 'user_123',
///   value: subscription,
///   ttl: Duration(minutes: 30),
/// );
///
/// // Retrieve from cache
/// final cached = cacheService.get('user_123');
/// if (cached != null && !cacheService.isExpired('user_123')) {
///   // Use cached value
/// }
/// ```
@lazySingleton
class SubscriptionCacheService {
  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  static const Duration _defaultTtl = Duration(minutes: 30);
  static const Duration _cleanupInterval = Duration(minutes: 5);

  SubscriptionCacheService() {
    _startCleanupTimer();
  }

  /// Store a subscription in cache with TTL
  void set({
    required String key,
    required SubscriptionEntity? value,
    Duration ttl = _defaultTtl,
  }) {
    final expiration = DateTime.now().add(ttl);
    _cache[key] = _CacheEntry(
      value: value,
      expiration: expiration,
      createdAt: DateTime.now(),
    );
  }

  /// Retrieve a subscription from cache
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Entry has expired (and removes it)
  SubscriptionEntity? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (isExpired(key)) {
      delete(key);
      return null;
    }

    return entry.value;
  }

  /// Check if a cache entry has expired
  bool isExpired(String key) {
    final entry = _cache[key];
    if (entry == null) return true;

    return DateTime.now().isAfter(entry.expiration);
  }

  /// Check if a key exists in cache (regardless of expiration)
  bool contains(String key) {
    return _cache.containsKey(key);
  }

  /// Get cache entry age
  Duration? getAge(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    return DateTime.now().difference(entry.createdAt);
  }

  /// Get time until expiration
  Duration? getTimeToExpiration(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    final remaining = entry.expiration.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Delete a specific cache entry
  void delete(String key) {
    _cache.remove(key);
  }

  /// Refresh TTL for an existing entry
  ///
  /// Returns false if key doesn't exist or is expired.
  bool refresh(String key, {Duration ttl = _defaultTtl}) {
    final entry = _cache[key];
    if (entry == null || isExpired(key)) {
      return false;
    }

    _cache[key] = _CacheEntry(
      value: entry.value,
      expiration: DateTime.now().add(ttl),
      createdAt: entry.createdAt,
    );

    return true;
  }

  /// Clear all cache entries
  void clear() {
    _cache.clear();
  }

  /// Remove expired entries
  ///
  /// Returns count of removed entries.
  int cleanExpired() {
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (isExpired(entry.key)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      delete(key);
    }

    return keysToRemove.length;
  }

  /// Get cache statistics
  CacheStatistics getStatistics() {
    var validCount = 0;
    var expiredCount = 0;

    for (final entry in _cache.entries) {
      if (isExpired(entry.key)) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return CacheStatistics(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
    );
  }

  /// Get all valid (non-expired) cache keys
  List<String> getValidKeys() {
    return _cache.entries
        .where((entry) => !isExpired(entry.key))
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all expired cache keys
  List<String> getExpiredKeys() {
    return _cache.entries
        .where((entry) => isExpired(entry.key))
        .map((entry) => entry.key)
        .toList();
  }

  /// Start automatic cleanup of expired entries
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      cleanExpired();
    });
  }

  /// Stop automatic cleanup
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    clear();
  }
}

/// Internal cache entry structure
class _CacheEntry {
  final SubscriptionEntity? value;
  final DateTime expiration;
  final DateTime createdAt;

  _CacheEntry({
    required this.value,
    required this.expiration,
    required this.createdAt,
  });
}

/// Cache statistics model
class CacheStatistics {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;

  CacheStatistics({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  double get hitRate {
    if (totalEntries == 0) return 0.0;
    return validEntries / totalEntries;
  }

  @override
  String toString() =>
      'CacheStatistics('
      'total: $totalEntries, '
      'valid: $validEntries, '
      'expired: $expiredEntries, '
      'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%'
      ')';
}
