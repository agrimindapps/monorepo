// Enhanced cache configuration with memory size limits
// Prevents memory leaks by controlling total memory usage

import 'i_cache_service.dart';

/// Enhanced cache configuration with memory size control
class EnhancedCacheConfig extends CacheConfig {
  /// Maximum memory usage in megabytes
  final double maxMemorySizeMB;
  
  /// Enable memory usage monitoring
  final bool enableMemoryMonitoring;
  
  /// Memory cleanup threshold (trigger cleanup when this % is reached)
  final double memoryCleanupThreshold;
  
  /// Enable secondary cache with weak references
  final bool enableSecondaryCache;
  
  /// Secondary cache max entries (uses WeakReference)
  final int maxSecondaryCacheEntries;

  const EnhancedCacheConfig({
    super.defaultTtl = const Duration(minutes: 15),
    super.maxMemoryEntries = 100,
    super.maxDiskEntries = 500,
    super.strategy = CacheStrategy.hybrid,
    super.enableStatistics = true,
    super.enableCleanup = true,
    this.maxMemorySizeMB = 50.0, // 50 MB default limit
    this.enableMemoryMonitoring = true,
    this.memoryCleanupThreshold = 0.8, // Cleanup when 80% full
    this.enableSecondaryCache = true,
    this.maxSecondaryCacheEntries = 500,
  }) : assert(maxMemorySizeMB > 0, 'maxMemorySizeMB must be positive'),
       assert(memoryCleanupThreshold > 0 && memoryCleanupThreshold <= 1.0, 
              'memoryCleanupThreshold must be between 0 and 1'),
       assert(maxSecondaryCacheEntries >= 0, 'maxSecondaryCacheEntries must be non-negative');

  /// Memory limit in bytes
  int get maxMemoryBytes => (maxMemorySizeMB * 1024 * 1024).round();
  
  /// Threshold in bytes for cleanup
  int get cleanupThresholdBytes => (maxMemoryBytes * memoryCleanupThreshold).round();
  
  @override
  String toString() {
    return 'EnhancedCacheConfig{'
           'maxMemorySizeMB: $maxMemorySizeMB, '
           'maxMemoryEntries: $maxMemoryEntries, '
           'strategy: $strategy, '
           'enableMemoryMonitoring: $enableMemoryMonitoring'
           '}';
  }
}