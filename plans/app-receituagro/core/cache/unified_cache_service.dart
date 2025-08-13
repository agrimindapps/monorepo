// Unified cache service implementation for app-receituagro module
// Centralizes all cache operations with memory + disk hybrid strategy

// Dart imports:
import 'dart:convert';
import 'dart:developer' as developer;

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'cache_entry.dart';
import 'i_cache_service.dart';

/// Unified cache service with hybrid memory+disk strategy
class UnifiedCacheService extends GetxService implements ICacheService {
  static const String _diskPrefix = 'unified_cache_';
  static const String _timestampPrefix = 'cache_timestamp_';
  static const String _metadataPrefix = 'cache_metadata_';

  late SharedPreferences _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  final CacheConfig _config;
  
  // Statistics tracking
  final Map<String, int> _eventCounts = {
    'hits': 0,
    'misses': 0,
    'puts': 0,
    'removes': 0,
    'expired': 0,
    'cleanups': 0,
  };
  DateTime _lastCleanup = DateTime.now();

  UnifiedCacheService({CacheConfig? config}) 
    : _config = config ?? const CacheConfig();

  @override
  CacheConfig get config => _config;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    
    // Initial cleanup if enabled
    if (_config.enableCleanup) {
      await _performInitialCleanup();
    }
    
    developer.log('🗄️ UnifiedCacheService initialized with ${_config.strategy} strategy');
  }

  @override
  Future<void> put<T>(
    String key,
    T data, {
    Duration? ttl,
    Map<String, dynamic>? metadata,
  }) async {
    final effectiveTtl = ttl ?? _config.defaultTtl;
    final entry = CacheEntry<T>(
      data: data,
      createdAt: DateTime.now(),
      ttl: effectiveTtl,
      cacheType: _config.strategy.name,
      metadata: metadata,
    );

    // Store in memory cache
    if (_config.strategy == CacheStrategy.memory || _config.strategy == CacheStrategy.hybrid) {
      _memoryCache[key] = entry;
      _cleanupMemoryIfNeeded();
    }

    // Store in disk cache
    if (_config.strategy == CacheStrategy.disk || _config.strategy == CacheStrategy.hybrid) {
      await _storeToDisk(key, entry);
    }

    _eventCounts['puts'] = (_eventCounts['puts'] ?? 0) + 1;
  }

  @override
  Future<T?> get<T>(String key) async {
    // Try memory cache first (fastest)
    if (_config.strategy == CacheStrategy.memory || _config.strategy == CacheStrategy.hybrid) {
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null) {
        if (memoryEntry.isValid) {
          _eventCounts['hits'] = (_eventCounts['hits'] ?? 0) + 1;
          return memoryEntry.data as T?;
        } else {
          // Remove expired entry from memory
          _memoryCache.remove(key);
          _eventCounts['expired'] = (_eventCounts['expired'] ?? 0) + 1;
        }
      }
    }

    // Try disk cache (fallback)
    if (_config.strategy == CacheStrategy.disk || _config.strategy == CacheStrategy.hybrid) {
      final diskEntry = await _loadFromDisk<T>(key);
      if (diskEntry != null && diskEntry.isValid) {
        // Populate memory cache for next access if hybrid
        if (_config.strategy == CacheStrategy.hybrid) {
          _memoryCache[key] = diskEntry;
          _cleanupMemoryIfNeeded();
        }
        _eventCounts['hits'] = (_eventCounts['hits'] ?? 0) + 1;
        return diskEntry.data as T?;
      } else if (diskEntry != null && diskEntry.isExpired) {
        // Remove expired entry from disk
        await _removeFromDisk(key);
        _eventCounts['expired'] = (_eventCounts['expired'] ?? 0) + 1;
      }
    }

    _eventCounts['misses'] = (_eventCounts['misses'] ?? 0) + 1;
    return null;
  }

  @override
  Future<bool> has(String key) async {
    // Check memory first
    if (_config.strategy == CacheStrategy.memory || _config.strategy == CacheStrategy.hybrid) {
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null && memoryEntry.isValid) {
        return true;
      }
    }

    // Check disk
    if (_config.strategy == CacheStrategy.disk || _config.strategy == CacheStrategy.hybrid) {
      final diskEntry = await _loadFromDisk(key);
      return diskEntry != null && diskEntry.isValid;
    }

    return false;
  }

  @override
  Future<void> remove(String key) async {
    // Remove from memory
    _memoryCache.remove(key);
    
    // Remove from disk
    await _removeFromDisk(key);
    
    _eventCounts['removes'] = (_eventCounts['removes'] ?? 0) + 1;
  }

  @override
  Future<void> clear() async {
    // Clear memory
    _memoryCache.clear();
    
    // Clear disk
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_diskPrefix) || 
          key.startsWith(_timestampPrefix) ||
          key.startsWith(_metadataPrefix)) {
        await _prefs.remove(key);
      }
    }
    
    _eventCounts['cleanups'] = (_eventCounts['cleanups'] ?? 0) + 1;
    developer.log('🧹 Unified cache cleared completely');
  }

  @override
  Future<void> clearByPattern(String pattern, {bool useRegex = false}) async {
    final keysToRemove = <String>[];
    
    // Find matching keys in memory
    for (final key in _memoryCache.keys) {
      if (useRegex) {
        if (RegExp(pattern).hasMatch(key)) {
          keysToRemove.add(key);
        }
      } else {
        if (key.contains(pattern)) {
          keysToRemove.add(key);
        }
      }
    }
    
    // Find matching keys in disk
    final diskKeys = _prefs.getKeys();
    for (final diskKey in diskKeys) {
      if (diskKey.startsWith(_diskPrefix)) {
        final cleanKey = diskKey.replaceFirst(_diskPrefix, '');
        if (useRegex) {
          if (RegExp(pattern).hasMatch(cleanKey)) {
            keysToRemove.add(cleanKey);
          }
        } else {
          if (cleanKey.contains(pattern)) {
            keysToRemove.add(cleanKey);
          }
        }
      }
    }
    
    // Remove all matching keys
    for (final key in keysToRemove.toSet()) {
      await remove(key);
    }
    
    developer.log('🗑️ Cleared ${keysToRemove.length} entries matching pattern: $pattern');
  }

  @override
  Future<void> clearByPrefix(String prefix) async {
    await clearByPattern('^$prefix', useRegex: true);
  }

  @override
  Future<void> clearExpired() async {
    int expiredCount = 0;
    
    // Clean memory cache
    final memoryKeysToRemove = <String>[];
    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        memoryKeysToRemove.add(entry.key);
      }
    }
    for (final key in memoryKeysToRemove) {
      _memoryCache.remove(key);
      expiredCount++;
    }
    
    // Clean disk cache
    final diskKeys = _prefs.getKeys();
    for (final diskKey in diskKeys) {
      if (diskKey.startsWith(_timestampPrefix)) {
        final timestamp = _prefs.getInt(diskKey);
        if (timestamp != null) {
          final key = diskKey.replaceFirst(_timestampPrefix, '');
          final entry = await _loadFromDisk(key);
          if (entry != null && entry.isExpired) {
            await _removeFromDisk(key);
            expiredCount++;
          }
        }
      }
    }
    
    _lastCleanup = DateTime.now();
    _eventCounts['cleanups'] = (_eventCounts['cleanups'] ?? 0) + 1;
    
    if (expiredCount > 0) {
      developer.log('🧹 Cleaned $expiredCount expired cache entries');
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    await clearExpired(); // Update expired count
    
    final memoryEntries = _memoryCache.length;
    final diskKeys = _prefs.getKeys()
        .where((key) => key.startsWith(_diskPrefix))
        .length;
    
    final validMemoryEntries = _memoryCache.values
        .where((entry) => entry.isValid)
        .length;
    
    final totalHits = (_eventCounts['hits'] ?? 0);
    final totalMisses = (_eventCounts['misses'] ?? 0);
    final hitRatio = (totalHits + totalMisses > 0) 
        ? totalHits / (totalHits + totalMisses) 
        : 0.0;
    
    return {
      'strategy': _config.strategy.name,
      'totalEntries': memoryEntries + diskKeys,
      'memoryEntries': memoryEntries,
      'diskEntries': diskKeys,
      'validMemoryEntries': validMemoryEntries,
      'hitRatio': hitRatio,
      'lastCleanup': _lastCleanup.toIso8601String(),
      'events': Map<String, int>.from(_eventCounts),
      'config': {
        'defaultTtl': _config.defaultTtl.inMinutes,
        'maxMemoryEntries': _config.maxMemoryEntries,
        'maxDiskEntries': _config.maxDiskEntries,
      },
    };
  }

  @override
  Future<List<String>> getKeys() async {
    final keys = <String>{};
    
    // Memory keys
    keys.addAll(_memoryCache.keys);
    
    // Disk keys
    final diskKeys = _prefs.getKeys();
    for (final diskKey in diskKeys) {
      if (diskKey.startsWith(_diskPrefix)) {
        keys.add(diskKey.replaceFirst(_diskPrefix, ''));
      }
    }
    
    return keys.toList();
  }

  @override
  Future<CacheEntry?> getEntry(String key) async {
    // Try memory first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      return memoryEntry;
    }
    
    // Try disk
    return await _loadFromDisk(key);
  }

  @override
  Future<bool> refreshTtl(String key, Duration newTtl) async {
    // Refresh memory entry
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      _memoryCache[key] = memoryEntry.copyWith(ttl: newTtl);
    }
    
    // Refresh disk entry
    final diskEntry = await _loadFromDisk(key);
    if (diskEntry != null) {
      await _storeToDisk(key, diskEntry.copyWith(ttl: newTtl));
      return true;
    }
    
    return memoryEntry != null;
  }

  @override
  Future<void> putBatch<T>(Map<String, T> entries, {Duration? ttl}) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value, ttl: ttl);
    }
  }

  @override
  Future<Map<String, T?>> getBatch<T>(List<String> keys) async {
    final result = <String, T?>{};
    for (final key in keys) {
      result[key] = await get<T>(key);
    }
    return result;
  }

  // Private helper methods

  Future<void> _storeToDisk<T>(String key, CacheEntry<T> entry) async {
    try {
      final jsonData = json.encode(entry.data);
      await _prefs.setString('$_diskPrefix$key', jsonData);
      await _prefs.setInt('$_timestampPrefix$key', entry.createdAt.millisecondsSinceEpoch);
      await _prefs.setInt('${_timestampPrefix}ttl_$key', entry.ttl.inMilliseconds);
      
      if (entry.metadata != null) {
        await _prefs.setString('$_metadataPrefix$key', json.encode(entry.metadata));
      }
    } catch (e) {
      developer.log('⚠️ Failed to store cache entry to disk: $e');
    }
  }

  Future<CacheEntry<T>?> _loadFromDisk<T>(String key) async {
    try {
      final jsonData = _prefs.getString('$_diskPrefix$key');
      final timestamp = _prefs.getInt('$_timestampPrefix$key');
      final ttlMs = _prefs.getInt('${_timestampPrefix}ttl_$key');
      
      if (jsonData == null || timestamp == null || ttlMs == null) {
        return null;
      }
      
      final data = json.decode(jsonData);
      final createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final ttl = Duration(milliseconds: ttlMs);
      
      Map<String, dynamic>? metadata;
      final metadataJson = _prefs.getString('$_metadataPrefix$key');
      if (metadataJson != null) {
        metadata = json.decode(metadataJson) as Map<String, dynamic>;
      }
      
      return CacheEntry<T>(
        data: data as T,
        createdAt: createdAt,
        ttl: ttl,
        cacheType: 'disk',
        metadata: metadata,
      );
    } catch (e) {
      developer.log('⚠️ Failed to load cache entry from disk: $e');
      return null;
    }
  }

  Future<void> _removeFromDisk(String key) async {
    await _prefs.remove('$_diskPrefix$key');
    await _prefs.remove('$_timestampPrefix$key');
    await _prefs.remove('${_timestampPrefix}ttl_$key');
    await _prefs.remove('$_metadataPrefix$key');
  }

  void _cleanupMemoryIfNeeded() {
    if (_memoryCache.length > _config.maxMemoryEntries) {
      // Remove oldest entries first (LRU-like behavior)
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final entriesToRemove = sortedEntries.length - _config.maxMemoryEntries;
      for (int i = 0; i < entriesToRemove; i++) {
        _memoryCache.remove(sortedEntries[i].key);
      }
    }
  }

  Future<void> _performInitialCleanup() async {
    await clearExpired();
    developer.log('🧹 Initial cache cleanup completed');
  }
}