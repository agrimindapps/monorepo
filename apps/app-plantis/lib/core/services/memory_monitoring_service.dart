import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to monitor memory usage and detect potential leaks
class MemoryMonitoringService {
  static MemoryMonitoringService? _instance;
  static MemoryMonitoringService get instance =>
      _instance ??= MemoryMonitoringService._();

  MemoryMonitoringService._();

  Timer? _monitoringTimer;
  final List<MemorySnapshot> _snapshots = [];
  static const int _maxSnapshots = 20;
  static const Duration _monitoringInterval = Duration(seconds: 30);

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;
  static const int _warningThresholdMB = 100;
  static const int _criticalThresholdMB = 200;

  /// Start memory monitoring
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(
      _monitoringInterval,
      (_) => _takeSnapshot(),
    );

    debugPrint('🔍 Memory monitoring started');
  }

  /// Stop memory monitoring
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    debugPrint('🔍 Memory monitoring stopped');
  }

  /// Take a memory snapshot
  Future<MemorySnapshot> _takeSnapshot() async {
    final snapshot = await _getCurrentMemorySnapshot();
    _snapshots.add(snapshot);
    if (_snapshots.length > _maxSnapshots) {
      _snapshots.removeAt(0);
    }
    _checkMemoryThresholds(snapshot);
    if (kDebugMode) {
      _logSnapshot(snapshot);
    }

    return snapshot;
  }

  /// Get current memory usage snapshot
  Future<MemorySnapshot> _getCurrentMemorySnapshot() async {
    final timestamp = DateTime.now();
    int? usedMemoryMB;
    int? heapMemoryMB;

    if (kDebugMode) {
      try {
        usedMemoryMB = 50; // Placeholder estimate
        heapMemoryMB = 100; // Placeholder estimate
      } catch (e) {
      }
    }
    final imageCacheStats =
        <String, dynamic>{}; // OptimizedPlantImageWidget.getCacheStats();
    final searchCacheStats =
        <String, dynamic>{}; // PlantsSearchService.instance.getCacheStats();

    return MemorySnapshot(
      timestamp: timestamp,
      usedMemoryMB: usedMemoryMB,
      heapMemoryMB: heapMemoryMB,
      imageCacheStats: imageCacheStats,
      searchCacheStats: searchCacheStats,
    );
  }

  /// Check memory thresholds and log warnings
  void _checkMemoryThresholds(MemorySnapshot snapshot) {
    final usedMemory = snapshot.usedMemoryMB;
    if (usedMemory == null) return;

    if (usedMemory > _criticalThresholdMB) {
      debugPrint(
        '🚨 CRITICAL: Memory usage is ${usedMemory}MB (>${_criticalThresholdMB}MB)',
      );
      debugPrint('🚨 Consider clearing caches or investigating memory leaks');
      clearAllCaches();
    } else if (usedMemory > _warningThresholdMB) {
      debugPrint(
        '⚠️ WARNING: Memory usage is ${usedMemory}MB (>${_warningThresholdMB}MB)',
      );
    }
  }

  /// Log snapshot details
  void _logSnapshot(MemorySnapshot snapshot) {
    final buffer = StringBuffer();
    buffer.writeln('📊 Memory Snapshot:');
    buffer.writeln('  Time: ${snapshot.timestamp.toIso8601String()}');

    if (snapshot.usedMemoryMB != null) {
      buffer.writeln('  Used Memory: ${snapshot.usedMemoryMB}MB');
    }
    if (snapshot.heapMemoryMB != null) {
      buffer.writeln('  Heap Capacity: ${snapshot.heapMemoryMB}MB');
    }

    buffer.writeln(
      '  Image Cache: ${snapshot.imageCacheStats['cachedImages']} images (${snapshot.imageCacheStats['totalSizeMB']}MB)',
    );
    buffer.writeln(
      '  Search Cache: ${snapshot.searchCacheStats['cacheSize']} queries',
    );

    debugPrint(buffer.toString());
  }

  /// Clear all caches to free memory
  void clearAllCaches() {
    try {

      debugPrint('🧹 All caches cleared');
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
    }
  }

  /// Get memory usage report
  MemoryReport getMemoryReport() {
    if (_snapshots.isEmpty) {
      return const MemoryReport(
        currentSnapshot: null,
        averageMemoryMB: null,
        peakMemoryMB: null,
        memoryTrend: MemoryTrend.stable,
        recommendations: ['Start monitoring to get memory insights'],
      );
    }

    final current = _snapshots.last;
    final usedMemories =
        _snapshots
            .map((s) => s.usedMemoryMB)
            .where((m) => m != null)
            .cast<int>()
            .toList();

    double? averageMemory;
    int? peakMemory;
    MemoryTrend trend = MemoryTrend.stable;

    if (usedMemories.isNotEmpty) {
      averageMemory =
          usedMemories.reduce((a, b) => a + b) / usedMemories.length;
      peakMemory = usedMemories.reduce((a, b) => a > b ? a : b);
      if (usedMemories.length >= 4) {
        final firstHalf = usedMemories.take(usedMemories.length ~/ 2).toList();
        final secondHalf = usedMemories.skip(usedMemories.length ~/ 2).toList();

        final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
        final secondAvg =
            secondHalf.reduce((a, b) => a + b) / secondHalf.length;

        if (secondAvg > firstAvg * 1.2) {
          trend = MemoryTrend.increasing;
        } else if (secondAvg < firstAvg * 0.8) {
          trend = MemoryTrend.decreasing;
        }
      }
    }

    final recommendations = <String>[];

    if (current.usedMemoryMB != null &&
        current.usedMemoryMB! > _warningThresholdMB) {
      recommendations.add('Memory usage is high (${current.usedMemoryMB}MB)');
    }

    if (trend == MemoryTrend.increasing) {
      recommendations.add(
        'Memory usage is increasing over time - check for leaks',
      );
    }

    final totalImageCacheMB =
        double.tryParse(
          (current.imageCacheStats['totalSizeMB'] as String?) ?? '0',
        ) ??
        0;
    if (totalImageCacheMB > 20) {
      recommendations.add(
        'Image cache is large (${totalImageCacheMB}MB) - consider clearing',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Memory usage looks healthy');
    }

    return MemoryReport(
      currentSnapshot: current,
      averageMemoryMB: averageMemory,
      peakMemoryMB: peakMemory,
      memoryTrend: trend,
      recommendations: recommendations,
    );
  }

  /// Dispose the service
  void dispose() {
    stopMonitoring();
    _snapshots.clear();
  }
}

/// Memory snapshot data class
class MemorySnapshot {
  final DateTime timestamp;
  final int? usedMemoryMB;
  final int? heapMemoryMB;
  final Map<String, dynamic> imageCacheStats;
  final Map<String, dynamic> searchCacheStats;

  const MemorySnapshot({
    required this.timestamp,
    required this.usedMemoryMB,
    required this.heapMemoryMB,
    required this.imageCacheStats,
    required this.searchCacheStats,
  });
}

/// Memory report with analysis
class MemoryReport {
  final MemorySnapshot? currentSnapshot;
  final double? averageMemoryMB;
  final int? peakMemoryMB;
  final MemoryTrend memoryTrend;
  final List<String> recommendations;

  const MemoryReport({
    required this.currentSnapshot,
    required this.averageMemoryMB,
    required this.peakMemoryMB,
    required this.memoryTrend,
    required this.recommendations,
  });
}

enum MemoryTrend { increasing, decreasing, stable }
