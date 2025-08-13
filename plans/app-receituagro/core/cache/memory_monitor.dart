// Memory monitoring service for cache optimization
// Tracks memory usage and provides cleanup triggers

import 'dart:convert';
import 'dart:developer' as developer;

import 'cache_entry.dart';

/// Memory usage statistics
class MemoryUsageStats {
  final int totalEntries;
  final int estimatedBytes;
  final double estimatedMB;
  final List<String> largestEntries;
  final DateTime lastCalculated;

  MemoryUsageStats({
    required this.totalEntries,
    required this.estimatedBytes,
    required this.estimatedMB,
    required this.largestEntries,
    required this.lastCalculated,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalEntries': totalEntries,
      'estimatedBytes': estimatedBytes,
      'estimatedMB': estimatedMB,
      'largestEntries': largestEntries,
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }
}

/// LRU entry tracking for efficient eviction
class LRUEntry {
  final String key;
  DateTime lastAccessed;
  final int estimatedSize;

  LRUEntry({
    required this.key,
    required this.lastAccessed,
    required this.estimatedSize,
  });

  void markAccessed() {
    lastAccessed = DateTime.now();
  }
}

/// Memory monitoring service for cache
class MemoryMonitor {
  final Map<String, LRUEntry> _lruTracker = {};
  MemoryUsageStats? _lastStats;

  /// Estimates memory usage of cache data
  int estimateSize(dynamic data) {
    try {
      if (data == null) return 0;
      
      // For JSON-serializable data, estimate by JSON length
      if (data is String) {
        return data.length * 2; // Unicode characters are 2 bytes
      }
      
      if (data is num) {
        return 8; // 8 bytes for numbers
      }
      
      if (data is bool) {
        return 1;
      }
      
      if (data is List) {
        int total = 24; // List overhead
        for (final item in data) {
          total += estimateSize(item);
        }
        return total;
      }
      
      if (data is Map) {
        int total = 32; // Map overhead
        for (final entry in data.entries) {
          total += estimateSize(entry.key);
          total += estimateSize(entry.value);
        }
        return total;
      }
      
      // Fallback: estimate by JSON encoding size
      try {
        final jsonString = json.encode(data);
        return jsonString.length * 2;
      } catch (e) {
        // If can't serialize, use rough estimate based on type
        return 1024; // 1KB default estimate
      }
    } catch (e) {
      developer.log('⚠️ Error estimating size for data: $e');
      return 1024; // Default to 1KB if estimation fails
    }
  }

  /// Calculates comprehensive memory usage statistics
  MemoryUsageStats calculateMemoryUsage(Map<String, CacheEntry> cache) {
    int totalBytes = 0;
    final entrySizes = <String, int>{};
    
    for (final entry in cache.entries) {
      final size = _calculateEntrySize(entry.key, entry.value);
      totalBytes += size;
      entrySizes[entry.key] = size;
      
      // Update LRU tracker
      _updateLRUTracker(entry.key, size);
    }
    
    // Find largest entries
    final sortedBySizes = entrySizes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final largestEntries = sortedBySizes
        .take(5)
        .map((e) => '${e.key} (${_formatBytes(e.value)})')
        .toList();
    
    _lastStats = MemoryUsageStats(
      totalEntries: cache.length,
      estimatedBytes: totalBytes,
      estimatedMB: totalBytes / (1024 * 1024),
      largestEntries: largestEntries,
      lastCalculated: DateTime.now(),
    );
    
    return _lastStats!;
  }

  /// Gets LRU entries for eviction (oldest first)
  List<String> getLRUEvictionCandidates(int maxCount) {
    final sortedEntries = _lruTracker.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));
    
    return sortedEntries
        .take(maxCount)
        .map((e) => e.key)
        .toList();
  }

  /// Gets entries sorted by size (largest first) for size-based eviction
  List<String> getSizeBasedEvictionCandidates(int maxCount) {
    final sortedEntries = _lruTracker.entries.toList()
      ..sort((a, b) => b.value.estimatedSize.compareTo(a.value.estimatedSize));
    
    return sortedEntries
        .take(maxCount)
        .map((e) => e.key)
        .toList();
  }

  /// Marks an entry as accessed for LRU tracking
  void markAccessed(String key) {
    _lruTracker[key]?.markAccessed();
  }

  /// Removes entry from LRU tracking
  void removeFromTracking(String key) {
    _lruTracker.remove(key);
  }

  /// Gets current memory statistics (cached)
  MemoryUsageStats? get lastStats => _lastStats;

  /// Determines if memory cleanup is needed
  bool needsCleanup(int maxBytes, double threshold) {
    if (_lastStats == null) return false;
    
    final thresholdBytes = (maxBytes * threshold).round();
    return _lastStats!.estimatedBytes >= thresholdBytes;
  }

  /// Calculates how many bytes to free to get below threshold
  int calculateBytesToFree(int maxBytes, double targetThreshold) {
    if (_lastStats == null) return 0;
    
    final targetBytes = (maxBytes * targetThreshold).round();
    final currentBytes = _lastStats!.estimatedBytes;
    
    return currentBytes > targetBytes ? currentBytes - targetBytes : 0;
  }

  /// Suggests eviction strategy based on current memory usage
  EvictionStrategy suggestEvictionStrategy() {
    if (_lastStats == null) return EvictionStrategy.lru;
    
    final avgSize = _lastStats!.estimatedBytes / _lastStats!.totalEntries;
    
    // If we have few large entries, prioritize size-based eviction
    if (avgSize > 100 * 1024) { // 100KB average
      return EvictionStrategy.sizeBased;
    }
    
    // Otherwise use LRU
    return EvictionStrategy.lru;
  }

  void _updateLRUTracker(String key, int size) {
    if (_lruTracker.containsKey(key)) {
      _lruTracker[key]!.markAccessed();
    } else {
      _lruTracker[key] = LRUEntry(
        key: key,
        lastAccessed: DateTime.now(),
        estimatedSize: size,
      );
    }
  }

  int _calculateEntrySize(String key, CacheEntry entry) {
    // Size of key
    int size = key.length * 2;
    
    // Size of entry data
    size += estimateSize(entry.data);
    
    // Size of metadata
    if (entry.metadata != null) {
      size += estimateSize(entry.metadata);
    }
    
    // Entry overhead (approximate)
    size += 64; // DateTime, Duration, String overhead
    
    return size;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Eviction strategy enumeration
enum EvictionStrategy {
  lru,        // Least Recently Used
  sizeBased,  // Remove largest entries first
  hybrid,     // Combination of LRU and size
}