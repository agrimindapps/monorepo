import 'dart:typed_data';

/// Gerenciador de cache em memória com LRU e TTL
///
/// Responsabilidades:
/// - Cache LRU (Least Recently Used)
/// - TTL (Time To Live) por item
/// - Gerenciamento de tamanho máximo
/// - Eviction policies
/// - Hit/Miss tracking
class StorageCacheManager {
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB

  final Map<String, _CacheItem> _memoryCache = {};
  int _memoryCacheSize = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Adiciona item ao cache
  void add(String key, dynamic value, Duration? ttl) {
    final item = _CacheItem(value: value, timestamp: DateTime.now(), ttl: ttl);
    final existing = _memoryCache[key];
    if (existing != null) {
      _memoryCacheSize -= existing.size;
    }

    _memoryCache[key] = item;
    _memoryCacheSize += item.size;
    _cleanupMemoryCache();
  }

  /// Obtém item do cache (null se expirado ou não existe)
  T? get<T>(String key) {
    final item = _memoryCache[key];
    if (item == null) {
      _cacheMisses++;
      return null;
    }

    if (item.isExpired) {
      remove(key);
      _cacheMisses++;
      return null;
    }

    _cacheHits++;
    return item.value as T?;
  }

  /// Remove item do cache
  void remove(String key) {
    final item = _memoryCache.remove(key);
    if (item != null) {
      _memoryCacheSize -= item.size;
    }
  }

  /// Verifica se chave existe no cache (e não está expirada)
  bool contains(String key) {
    final item = _memoryCache[key];
    if (item == null) return false;

    if (item.isExpired) {
      remove(key);
      return false;
    }

    return true;
  }

  /// Limpa todo o cache
  void clear() {
    _memoryCache.clear();
    _memoryCacheSize = 0;
  }

  /// Retorna todas as chaves do cache
  Iterable<String> get keys => _memoryCache.keys;

  /// Verifica se deve cachear em memória baseado no tamanho
  bool shouldCache(dynamic value) {
    if (_memoryCacheSize >= _maxMemoryCacheSize) return false;
    if (value == null) return false;

    int valueSize = 0;
    if (value is String) {
      valueSize = value.length * 2; // Aproximação para UTF-16
    } else if (value is Uint8List) {
      valueSize = value.length;
    } else {
      valueSize = value.toString().length * 2;
    }

    return valueSize < 1024 * 1024; // Máximo 1MB por item
  }

  /// Limpa itens expirados e faz eviction se necessário
  void _cleanupMemoryCache() {
    // Remove expired items
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      final item = _memoryCache.remove(key);
      if (item != null) {
        _memoryCacheSize -= item.size;
      }
    }

    // Evict oldest items if cache is full (LRU)
    while (_memoryCacheSize > _maxMemoryCacheSize && _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;

      final item = _memoryCache.remove(oldestKey);
      if (item != null) {
        _memoryCacheSize -= item.size;
      }
    }
  }

  /// Estatísticas do cache
  CacheStats getStats() {
    return CacheStats(
      size: _memoryCache.length,
      sizeBytes: _memoryCacheSize,
      hits: _cacheHits,
      misses: _cacheMisses,
      hitRatio: _cacheHits / (_cacheHits + _cacheMisses),
    );
  }
}

/// Item do cache em memória
class _CacheItem {
  final dynamic value;
  final DateTime timestamp;
  final Duration? ttl;

  _CacheItem({required this.value, required this.timestamp, this.ttl});

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }

  int get size {
    if (value is String) {
      return (value as String).length * 2;
    } else if (value is Uint8List) {
      return (value as Uint8List).length;
    } else {
      return value.toString().length * 2;
    }
  }
}

/// Estatísticas do cache
class CacheStats {
  final int size;
  final int sizeBytes;
  final int hits;
  final int misses;
  final double hitRatio;

  /// Alias para size (número de itens)
  int get items => size;

  /// Alias para sizeBytes
  int get sizeInBytes => sizeBytes;

  CacheStats({
    required this.size,
    required this.sizeBytes,
    required this.hits,
    required this.misses,
    required this.hitRatio,
  });

  @override
  String toString() {
    return 'CacheStats(size: $size items, ${_formatBytes(sizeBytes)}, '
        'hits: $hits, misses: $misses, hit ratio: ${(hitRatio * 100).toStringAsFixed(1)}%)';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
