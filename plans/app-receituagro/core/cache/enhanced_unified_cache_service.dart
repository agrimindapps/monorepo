// Enhanced unified cache service with memory size limits and WeakReference support
// Solves memory leak issues by implementing proper memory management

// Dart imports:
import 'dart:convert';
import 'dart:developer' as developer;

// Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'cache_entry.dart';
import 'enhanced_cache_config.dart';
import 'i_cache_service.dart';
import 'memory_monitor.dart';

/// Enhanced unified cache service with memory management
class EnhancedUnifiedCacheService extends GetxService implements ICacheService {
  static const String _diskPrefix = 'enhanced_cache_';
  static const String _timestampPrefix = 'cache_timestamp_';
  static const String _metadataPrefix = 'cache_metadata_';

  late SharedPreferences _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, WeakReference<CacheEntry>> _secondaryCache = {};
  final EnhancedCacheConfig _config;
  final MemoryMonitor _memoryMonitor = MemoryMonitor();
  
  // Statistics tracking with enhanced metrics
  final Map<String, int> _eventCounts = {
    'hits': 0,
    'misses': 0,
    'puts': 0,
    'removes': 0,
    'expired': 0,
    'cleanups': 0,
    'memoryEvictions': 0,
    'sizeBasedEvictions': 0,
  };
  DateTime _lastCleanup = DateTime.now();
  DateTime _lastMemoryCheck = DateTime.now();

  EnhancedUnifiedCacheService({EnhancedCacheConfig? config}) 
    : _config = config ?? const EnhancedCacheConfig();

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
    
    developer.log('🗄️ Enhanced UnifiedCacheService initialized with ${_config.strategy} strategy');
    developer.log('💾 Memory limit: ${_config.maxMemorySizeMB}MB');
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

    // Store in memory cache with memory management
    if (_config.strategy == CacheStrategy.memory || _config.strategy == CacheStrategy.hybrid) {
      _memoryCache[key] = entry;
      
      // Perform memory management
      await _manageMemoryUsage();
    }

    // Store in disk cache
    if (_config.strategy == CacheStrategy.disk || _config.strategy == CacheStrategy.hybrid) {
      await _storeToDisk(key, entry);
    }

    _eventCounts['puts'] = (_eventCounts['puts'] ?? 0) + 1;
  }

  @override
  Future<T?> get<T>(String key) async {
    // Mark as accessed for LRU tracking
    _memoryMonitor.markAccessed(key);

    // Try memory cache first (fastest)
    if (_config.strategy == CacheStrategy.memory || _config.strategy == CacheStrategy.hybrid) {
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null) {
        if (memoryEntry.isValid) {
          _eventCounts['hits'] = (_eventCounts['hits'] ?? 0) + 1;
          return memoryEntry.data as T?;
        } else {
          // Remove expired entry from memory and tracking
          _removeFromMemory(key);
          _eventCounts['expired'] = (_eventCounts['expired'] ?? 0) + 1;
        }
      }
      
      // Try secondary cache (WeakReference)
      if (_config.enableSecondaryCache) {
        final secondaryEntry = _secondaryCache[key]?.target;
        if (secondaryEntry != null && secondaryEntry.isValid) {
          // Promote back to primary cache if there's room
          if (_memoryCache.length < _config.maxMemoryEntries) {
            _memoryCache[key] = secondaryEntry;
            _secondaryCache.remove(key);
          }
          _eventCounts['hits'] = (_eventCounts['hits'] ?? 0) + 1;
          return secondaryEntry.data as T?;
        } else if (secondaryEntry == null) {
          // WeakReference was collected
          _secondaryCache.remove(key);
        }
      }
    }

    // Try disk cache (fallback)
    if (_config.strategy == CacheStrategy.disk || _config.strategy == CacheStrategy.hybrid) {
      final diskEntry = await _loadFromDisk<T>(key);
      if (diskEntry != null && diskEntry.isValid) {
        // Populate memory cache for next access if hybrid and there's room
        if (_config.strategy == CacheStrategy.hybrid && 
            _memoryCache.length < _config.maxMemoryEntries) {
          _memoryCache[key] = diskEntry;
          await _manageMemoryUsage();
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
      
      // Check secondary cache
      if (_config.enableSecondaryCache) {
        final secondaryEntry = _secondaryCache[key]?.target;
        if (secondaryEntry != null && secondaryEntry.isValid) {
          return true;
        }
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
    _removeFromMemory(key);
    await _removeFromDisk(key);
    
    _eventCounts['removes'] = (_eventCounts['removes'] ?? 0) + 1;
  }

  @override
  Future<void> clear() async {
    // Clear memory and secondary cache
    _memoryCache.clear();
    _secondaryCache.clear();
    
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
    developer.log('🧹 Enhanced unified cache cleared completely');
  }

  @override
  Future<void> clearByPattern(String pattern, {bool useRegex = false}) async {
    final keysToRemove = <String>[];
    
    // Find matching keys in memory
    for (final key in _memoryCache.keys) {
      if (_matchesPattern(key, pattern, useRegex)) {
        keysToRemove.add(key);
      }
    }
    
    // Find matching keys in secondary cache
    for (final key in _secondaryCache.keys) {
      if (_matchesPattern(key, pattern, useRegex)) {
        keysToRemove.add(key);
      }
    }
    
    // Find matching keys in disk
    final diskKeys = _prefs.getKeys();
    for (final diskKey in diskKeys) {
      if (diskKey.startsWith(_diskPrefix)) {
        final cleanKey = diskKey.replaceFirst(_diskPrefix, '');
        if (_matchesPattern(cleanKey, pattern, useRegex)) {
          keysToRemove.add(cleanKey);
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
      _removeFromMemory(key);
      expiredCount++;
    }
    
    // Clean secondary cache
    final secondaryKeysToRemove = <String>[];
    for (final entry in _secondaryCache.entries) {
      final cacheEntry = entry.value.target;
      if (cacheEntry == null || cacheEntry.isExpired) {
        secondaryKeysToRemove.add(entry.key);
      }
    }
    for (final key in secondaryKeysToRemove) {
      _secondaryCache.remove(key);
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
    
    // Calculate memory usage
    MemoryUsageStats? memoryStats;
    if (_config.enableMemoryMonitoring) {
      memoryStats = _memoryMonitor.calculateMemoryUsage(_memoryCache);
    }
    
    final memoryEntries = _memoryCache.length;
    final secondaryEntries = _secondaryCache.length;
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
      'totalEntries': memoryEntries + secondaryEntries + diskKeys,
      'memoryEntries': memoryEntries,
      'secondaryEntries': secondaryEntries,
      'diskEntries': diskKeys,
      'validMemoryEntries': validMemoryEntries,
      'hitRatio': hitRatio,
      'lastCleanup': _lastCleanup.toIso8601String(),
      'events': Map<String, int>.from(_eventCounts),
      'memoryUsage': memoryStats?.toMap() ?? {},
      'config': {
        'defaultTtl': _config.defaultTtl.inMinutes,
        'maxMemoryEntries': _config.maxMemoryEntries,
        'maxDiskEntries': _config.maxDiskEntries,
        'maxMemorySizeMB': _config.maxMemorySizeMB,
        'enableMemoryMonitoring': _config.enableMemoryMonitoring,
        'enableSecondaryCache': _config.enableSecondaryCache,
      },
    };
  }

  @override
  Future<List<String>> getKeys() async {
    final keys = <String>{};
    
    // Memory keys
    keys.addAll(_memoryCache.keys);
    
    // Secondary cache keys
    keys.addAll(_secondaryCache.keys);
    
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
    
    // Try secondary cache
    final secondaryEntry = _secondaryCache[key]?.target;
    if (secondaryEntry != null) {
      return secondaryEntry;
    }
    
    // Try disk
    return await _loadFromDisk(key);
  }

  @override
  Future<bool> refreshTtl(String key, Duration newTtl) async {
    bool refreshed = false;
    
    // Refresh memory entry
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null) {
      _memoryCache[key] = memoryEntry.copyWith(ttl: newTtl);
      refreshed = true;
    }
    
    // Refresh secondary cache entry
    final secondaryEntry = _secondaryCache[key]?.target;
    if (secondaryEntry != null) {
      final refreshedEntry = secondaryEntry.copyWith(ttl: newTtl);
      _secondaryCache[key] = WeakReference(refreshedEntry);
      refreshed = true;
    }
    
    // Refresh disk entry
    final diskEntry = await _loadFromDisk(key);
    if (diskEntry != null) {
      await _storeToDisk(key, diskEntry.copyWith(ttl: newTtl));
      refreshed = true;
    }
    
    return refreshed;
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

  // Enhanced private helper methods

  Future<void> _manageMemoryUsage() async {
    if (!_config.enableMemoryMonitoring) {
      _cleanupMemoryByCount();
      return;
    }

    // Skip frequent checks to avoid performance impact
    final now = DateTime.now();
    if (now.difference(_lastMemoryCheck).inMilliseconds < 1000) {
      return;
    }
    _lastMemoryCheck = now;

    final memoryStats = _memoryMonitor.calculateMemoryUsage(_memoryCache);
    
    // Check if cleanup is needed
    if (_memoryMonitor.needsCleanup(_config.maxMemoryBytes, _config.memoryCleanupThreshold)) {
      await _performMemoryCleanup(memoryStats);
    }
  }

  Future<void> _performMemoryCleanup(MemoryUsageStats stats) async {
    final bytesToFree = _memoryMonitor.calculateBytesToFree(
      _config.maxMemoryBytes, 
      0.6 // Target 60% of max memory after cleanup
    );
    
    if (bytesToFree <= 0) return;

    final strategy = _memoryMonitor.suggestEvictionStrategy();
    
    switch (strategy) {
      case EvictionStrategy.lru:
        await _performLRUEviction(bytesToFree);
        break;
      case EvictionStrategy.sizeBased:
        await _performSizeBasedEviction(bytesToFree);
        break;
      case EvictionStrategy.hybrid:
        await _performHybridEviction(bytesToFree);
        break;
    }

    developer.log('💾 Memory cleanup completed. Freed ~${bytesToFree ~/ 1024}KB');
  }

  Future<void> _performLRUEviction(int bytesToFree) async {
    int freedBytes = 0;
    final candidates = _memoryMonitor.getLRUEvictionCandidates(_memoryCache.length);
    
    for (final key in candidates) {
      if (freedBytes >= bytesToFree) break;
      
      final entry = _memoryCache[key];
      if (entry != null) {
        freedBytes += _memoryMonitor.estimateSize(entry.data);
        _moveToSecondaryCache(key, entry);
        _eventCounts['memoryEvictions'] = (_eventCounts['memoryEvictions'] ?? 0) + 1;
      }
    }
  }

  Future<void> _performSizeBasedEviction(int bytesToFree) async {
    int freedBytes = 0;
    final candidates = _memoryMonitor.getSizeBasedEvictionCandidates(_memoryCache.length);
    
    for (final key in candidates) {
      if (freedBytes >= bytesToFree) break;
      
      final entry = _memoryCache[key];
      if (entry != null) {
        freedBytes += _memoryMonitor.estimateSize(entry.data);
        _moveToSecondaryCache(key, entry);
        _eventCounts['sizeBasedEvictions'] = (_eventCounts['sizeBasedEvictions'] ?? 0) + 1;
      }
    }
  }

  Future<void> _performHybridEviction(int bytesToFree) async {
    // First remove largest entries if over memory limit severely
    final currentStats = _memoryMonitor.lastStats!;
    if (currentStats.estimatedBytes > _config.maxMemoryBytes * 1.2) {
      await _performSizeBasedEviction(bytesToFree ~/ 2);
    }
    
    // Then apply LRU for the remaining
    await _performLRUEviction(bytesToFree ~/ 2);
  }

  void _moveToSecondaryCache(String key, CacheEntry entry) {
    if (_config.enableSecondaryCache && 
        _secondaryCache.length < _config.maxSecondaryCacheEntries) {
      _secondaryCache[key] = WeakReference(entry);
    }
    
    _memoryCache.remove(key);
    _memoryMonitor.removeFromTracking(key);
  }

  void _removeFromMemory(String key) {
    _memoryCache.remove(key);
    _secondaryCache.remove(key);
    _memoryMonitor.removeFromTracking(key);
  }

  void _cleanupMemoryByCount() {
    if (_memoryCache.length > _config.maxMemoryEntries) {
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
      
      final entriesToRemove = sortedEntries.length - _config.maxMemoryEntries;
      for (int i = 0; i < entriesToRemove; i++) {
        _moveToSecondaryCache(sortedEntries[i].key, sortedEntries[i].value);
      }
    }
  }

  bool _matchesPattern(String key, String pattern, bool useRegex) {
    if (useRegex) {
      try {
        return RegExp(pattern).hasMatch(key);
      } catch (e) {
        return key.contains(pattern);
      }
    } else {
      return key.contains(pattern);
    }
  }

  // Existing disk operations (unchanged)
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

  Future<void> _performInitialCleanup() async {
    await clearExpired();
    
    // Cleanup secondary cache of collected references
    final keysToRemove = <String>[];
    for (final entry in _secondaryCache.entries) {
      if (entry.value.target == null) {
        keysToRemove.add(entry.key);
      }
    }
    for (final key in keysToRemove) {
      _secondaryCache.remove(key);
    }
    
    developer.log('🧹 Enhanced initial cache cleanup completed');
  }
}