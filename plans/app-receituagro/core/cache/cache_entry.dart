// Core cache entry model for unified cache management
// Supports TTL validation and data integrity

/// Generic cache entry with TTL validation
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;
  final String cacheType;
  final Map<String, dynamic>? metadata;

  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
    this.cacheType = 'memory',
    this.metadata,
  });

  /// Checks if cache entry has expired
  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  /// Checks if cache entry is still valid
  bool get isValid => !isExpired;

  /// Gets age of cache entry in milliseconds
  int get ageInMilliseconds => DateTime.now().difference(createdAt).inMilliseconds;

  /// Gets age of cache entry as human readable string
  String get ageFormatted {
    final age = DateTime.now().difference(createdAt);
    if (age.inDays > 0) return '${age.inDays}d ${age.inHours % 24}h';
    if (age.inHours > 0) return '${age.inHours}h ${age.inMinutes % 60}m';
    if (age.inMinutes > 0) return '${age.inMinutes}m ${age.inSeconds % 60}s';
    return '${age.inSeconds}s';
  }

  /// Creates a copy of cache entry with new data
  CacheEntry<T> copyWith({
    T? data,
    DateTime? createdAt,
    Duration? ttl,
    String? cacheType,
    Map<String, dynamic>? metadata,
  }) {
    return CacheEntry<T>(
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      ttl: ttl ?? this.ttl,
      cacheType: cacheType ?? this.cacheType,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts cache entry to map for persistence
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'ttl': ttl.inMilliseconds,
      'cacheType': cacheType,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'CacheEntry(type: $cacheType, valid: $isValid, age: $ageFormatted, ttl: ${ttl.inMinutes}m)';
  }
}