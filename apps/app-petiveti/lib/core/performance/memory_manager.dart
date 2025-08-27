import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Advanced memory management and leak detection system
class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<String, MemoryTracker> _trackers = {};
  final Map<String, WeakReference<Object>> _objectRegistry = {};
  final List<MemorySnapshot> _snapshots = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  static const int maxSnapshots = 100;
  static const Duration monitoringInterval = Duration(seconds: 30);

  /// Inicia o monitoramento automático de memória
  void startMonitoring({Duration? interval}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(
      interval ?? monitoringInterval,
      (_) => _takeSnapshot(),
    );

    log('Memory monitoring started', name: 'MemoryManager');
  }

  /// Para o monitoramento automático
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    log('Memory monitoring stopped', name: 'MemoryManager');
  }

  /// Registra um objeto para tracking de memória
  void trackObject<T extends Object>(String key, T object, {String? category}) {
    _objectRegistry[key] = WeakReference<Object>(object);
    
    final tracker = _trackers[category ?? 'default'] ??= MemoryTracker(category ?? 'default');
    tracker._registerObject(key, object.runtimeType.toString());
    
    log('Object tracked: $key (${object.runtimeType})', name: 'MemoryManager');
  }

  /// Remove tracking de um objeto
  void untrackObject(String key) {
    _objectRegistry.remove(key);
    
    for (final tracker in _trackers.values) {
      tracker._unregisterObject(key);
    }
    
    log('Object untracked: $key', name: 'MemoryManager');
  }

  /// Detecta vazamentos de memória
  MemoryLeakReport detectLeaks() {
    final leaks = <MemoryLeak>[];
    final orphanedObjects = <String>[];
    
    // Força garbage collection para limpeza
    _forceGC();
    
    // Aguarda um pouco para GC completar
    Future.delayed(const Duration(milliseconds: 100), () {
      _objectRegistry.forEach((key, weakRef) {
        final obj = weakRef.target;
        if (obj != null) {
          // Objeto ainda está vivo - possível vazamento
          leaks.add(MemoryLeak(
            objectKey: key,
            objectType: obj.runtimeType.toString(),
            severity: MemoryLeakSeverity.medium,
            description: 'Object not garbage collected after forced GC',
          ));
        } else {
          // Objeto foi coletado - remover da registry
          orphanedObjects.add(key);
        }
      });

      // Limpar objetos órfãos
      for (final key in orphanedObjects) {
        _objectRegistry.remove(key);
      }
    });

    return MemoryLeakReport(
      generatedAt: DateTime.now(),
      totalLeaks: leaks.length,
      leaks: leaks,
      memoryUsage: _getCurrentMemoryUsage(),
    );
  }

  /// Obtém snapshot atual da memória
  MemorySnapshot takeSnapshot({String? label}) {
    final snapshot = MemorySnapshot(
      timestamp: DateTime.now(),
      label: label,
      rssUsage: ProcessInfo.currentRss,
      maxRss: ProcessInfo.maxRss,
      objectCount: _objectRegistry.length,
      trackedCategories: _trackers.keys.toList(),
      categoryStats: _getCategoryStats(),
    );

    _snapshots.add(snapshot);
    
    // Manter apenas os últimos snapshots
    if (_snapshots.length > maxSnapshots) {
      _snapshots.removeAt(0);
    }

    return snapshot;
  }

  /// Análise de tendências de memória
  MemoryTrendAnalysis analyzeTrends({Duration? period}) {
    if (_snapshots.length < 2) {
      return MemoryTrendAnalysis.empty();
    }

    final now = DateTime.now();
    final startTime = period != null ? now.subtract(period) : _snapshots.first.timestamp;
    
    final relevantSnapshots = _snapshots
        .where((s) => s.timestamp.isAfter(startTime))
        .toList();

    if (relevantSnapshots.length < 2) {
      return MemoryTrendAnalysis.empty();
    }

    final firstSnapshot = relevantSnapshots.first;
    final lastSnapshot = relevantSnapshots.last;

    final memoryGrowth = lastSnapshot.rssUsage - firstSnapshot.rssUsage;
    final objectGrowth = lastSnapshot.objectCount - firstSnapshot.objectCount;
    
    // Detectar picos de memória
    final peaks = <MemoryPeak>[];
    int maxUsage = 0;
    DateTime? peakTime;

    for (final snapshot in relevantSnapshots) {
      if (snapshot.rssUsage > maxUsage) {
        maxUsage = snapshot.rssUsage;
        peakTime = snapshot.timestamp;
      }
    }

    if (peakTime != null) {
      peaks.add(MemoryPeak(
        timestamp: peakTime,
        usage: maxUsage,
        type: MemoryPeakType.rss,
      ));
    }

    return MemoryTrendAnalysis(
      period: period ?? now.difference(firstSnapshot.timestamp),
      totalSnapshots: relevantSnapshots.length,
      memoryGrowth: memoryGrowth,
      objectGrowth: objectGrowth,
      averageUsage: relevantSnapshots.map((s) => s.rssUsage).reduce((a, b) => a + b) ~/ relevantSnapshots.length,
      peaks: peaks,
      growthRate: _calculateGrowthRate(relevantSnapshots),
    );
  }

  /// Limpa recursos não utilizados
  void cleanup({bool aggressive = false}) {
    _forceGC();
    
    if (aggressive) {
      // Cleanup agressivo - remove todos os trackings orfãos
      final keysToRemove = <String>[];
      
      _objectRegistry.forEach((key, weakRef) {
        if (weakRef.target == null) {
          keysToRemove.add(key);
        }
      });

      for (final key in keysToRemove) {
        untrackObject(key);
      }

      // Limpar snapshots antigos
      if (_snapshots.length > maxSnapshots ~/ 2) {
        _snapshots.removeRange(0, _snapshots.length - (maxSnapshots ~/ 2));
      }
    }

    log('Memory cleanup completed (aggressive: $aggressive)', name: 'MemoryManager');
  }

  /// Obtém relatório completo de memória
  MemoryReport getMemoryReport() {
    return MemoryReport(
      generatedAt: DateTime.now(),
      currentUsage: _getCurrentMemoryUsage(),
      trackedObjects: _objectRegistry.length,
      trackers: Map.from(_trackers),
      recentSnapshots: _snapshots.take(10).toList(),
      isMonitoring: _isMonitoring,
    );
  }

  void _takeSnapshot() {
    takeSnapshot(label: 'auto_${DateTime.now().millisecondsSinceEpoch}');
  }

  void _forceGC() {
    if (!kReleaseMode) {
      // Em desenvolvimento, força múltiplas coletas
      for (int i = 0; i < 3; i++) {
        // Simula pressão de memória para forçar GC
        final temp = List.generate(1000, (index) => Object());
        temp.clear();
      }
    }
  }

  int _getCurrentMemoryUsage() {
    return ProcessInfo.currentRss;
  }

  Map<String, CategoryStats> _getCategoryStats() {
    final stats = <String, CategoryStats>{};
    
    for (final tracker in _trackers.values) {
      stats[tracker.category] = CategoryStats(
        objectCount: tracker._objects.length,
        types: tracker._getTypeDistribution(),
      );
    }

    return stats;
  }

  double _calculateGrowthRate(List<MemorySnapshot> snapshots) {
    if (snapshots.length < 2) return 0.0;

    final first = snapshots.first;
    final last = snapshots.last;
    final timeDiff = last.timestamp.difference(first.timestamp).inMilliseconds;
    
    if (timeDiff == 0) return 0.0;

    final memoryDiff = last.rssUsage - first.rssUsage;
    return (memoryDiff / timeDiff) * 1000; // bytes per second
  }
}

/// Tracker de memória por categoria
class MemoryTracker {
  final String category;
  final Map<String, TrackedObject> _objects = {};

  MemoryTracker(this.category);

  void _registerObject(String key, String type) {
    _objects[key] = TrackedObject(
      key: key,
      type: type,
      registeredAt: DateTime.now(),
    );
  }

  void _unregisterObject(String key) {
    final obj = _objects[key];
    if (obj != null) {
      obj._unregisteredAt = DateTime.now();
      _objects.remove(key);
    }
  }

  Map<String, int> _getTypeDistribution() {
    final distribution = <String, int>{};
    
    for (final obj in _objects.values) {
      distribution[obj.type] = (distribution[obj.type] ?? 0) + 1;
    }

    return distribution;
  }
}

/// Objeto rastreado
class TrackedObject {
  final String key;
  final String type;
  final DateTime registeredAt;
  DateTime? _unregisteredAt;

  TrackedObject({
    required this.key,
    required this.type,
    required this.registeredAt,
  });

  DateTime? get unregisteredAt => _unregisteredAt;
  Duration get lifespan => (_unregisteredAt ?? DateTime.now()).difference(registeredAt);
}

/// Snapshot de memória
class MemorySnapshot {
  final DateTime timestamp;
  final String? label;
  final int rssUsage;
  final int maxRss;
  final int objectCount;
  final List<String> trackedCategories;
  final Map<String, CategoryStats> categoryStats;

  const MemorySnapshot({
    required this.timestamp,
    this.label,
    required this.rssUsage,
    required this.maxRss,
    required this.objectCount,
    required this.trackedCategories,
    required this.categoryStats,
  });

  String get formattedRssUsage => _formatBytes(rssUsage);
  String get formattedMaxRss => _formatBytes(maxRss);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Estatísticas por categoria
class CategoryStats {
  final int objectCount;
  final Map<String, int> types;

  const CategoryStats({
    required this.objectCount,
    required this.types,
  });
}

/// Vazamento de memória detectado
class MemoryLeak {
  final String objectKey;
  final String objectType;
  final MemoryLeakSeverity severity;
  final String description;

  const MemoryLeak({
    required this.objectKey,
    required this.objectType,
    required this.severity,
    required this.description,
  });
}

enum MemoryLeakSeverity {
  low,
  medium,
  high,
  critical,
}

/// Relatório de vazamentos
class MemoryLeakReport {
  final DateTime generatedAt;
  final int totalLeaks;
  final List<MemoryLeak> leaks;
  final int memoryUsage;

  const MemoryLeakReport({
    required this.generatedAt,
    required this.totalLeaks,
    required this.leaks,
    required this.memoryUsage,
  });

  bool get hasLeaks => totalLeaks > 0;
  
  List<MemoryLeak> get criticalLeaks =>
      leaks.where((leak) => leak.severity == MemoryLeakSeverity.critical).toList();
  
  List<MemoryLeak> get highSeverityLeaks =>
      leaks.where((leak) => leak.severity == MemoryLeakSeverity.high).toList();
}

/// Pico de memória
class MemoryPeak {
  final DateTime timestamp;
  final int usage;
  final MemoryPeakType type;

  const MemoryPeak({
    required this.timestamp,
    required this.usage,
    required this.type,
  });
}

enum MemoryPeakType {
  rss,
  heap,
  objects,
}

/// Análise de tendências
class MemoryTrendAnalysis {
  final Duration period;
  final int totalSnapshots;
  final int memoryGrowth;
  final int objectGrowth;
  final int averageUsage;
  final List<MemoryPeak> peaks;
  final double growthRate;

  const MemoryTrendAnalysis({
    required this.period,
    required this.totalSnapshots,
    required this.memoryGrowth,
    required this.objectGrowth,
    required this.averageUsage,
    required this.peaks,
    required this.growthRate,
  });

  factory MemoryTrendAnalysis.empty() {
    return const MemoryTrendAnalysis(
      period: Duration.zero,
      totalSnapshots: 0,
      memoryGrowth: 0,
      objectGrowth: 0,
      averageUsage: 0,
      peaks: [],
      growthRate: 0.0,
    );
  }

  bool get hasGrowth => memoryGrowth > 0;
  bool get hasSignificantGrowth => memoryGrowth > (1024 * 1024); // 1MB
  bool get hasMemoryLeakIndicators => growthRate > 1000; // >1KB/s
}

/// Relatório completo de memória
class MemoryReport {
  final DateTime generatedAt;
  final int currentUsage;
  final int trackedObjects;
  final Map<String, MemoryTracker> trackers;
  final List<MemorySnapshot> recentSnapshots;
  final bool isMonitoring;

  const MemoryReport({
    required this.generatedAt,
    required this.currentUsage,
    required this.trackedObjects,
    required this.trackers,
    required this.recentSnapshots,
    required this.isMonitoring,
  });
}

/// Mixin para tracking automático de memória
mixin MemoryTrackingMixin<T extends StatefulWidget> on State<T> {
  final MemoryManager _memoryManager = MemoryManager();
  late String _widgetKey;

  @override
  void initState() {
    super.initState();
    _widgetKey = '${widget.runtimeType}_${widget.hashCode}';
    _memoryManager.trackObject(_widgetKey, this, category: 'widgets');
  }

  @override
  void dispose() {
    _memoryManager.untrackObject(_widgetKey);
    super.dispose();
  }
}

/// Extension para facilitar uso
extension MemoryTrackingExtensions on Object {
  /// Registra este objeto para tracking de memória
  void trackMemory(String key, {String? category}) {
    MemoryManager().trackObject(key, this, category: category);
  }

  /// Remove tracking deste objeto
  void untrackMemory(String key) {
    MemoryManager().untrackObject(key);
  }
}