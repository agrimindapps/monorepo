import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

// import 'database_optimizer.dart'; // REMOVED: DatabaseOptimizer migrated to Drift
import 'image_optimizer.dart';
import 'memory_manager.dart';
import 'navigation_optimizer.dart';
import 'performance_service.dart';
import 'widget_optimizer.dart';

/// Gerenciador central de todas as otimizações de performance
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  final PerformanceService _performanceService = PerformanceService();
  final MemoryManager _memoryManager = MemoryManager();
  // final DatabaseOptimizer _dbOptimizer = DatabaseOptimizer(); // REMOVED
  final NavigationOptimizer _navOptimizer = NavigationOptimizer();
  final ImageOptimizer _imageOptimizer = ImageOptimizer();
  final WidgetOptimizer _widgetOptimizer = WidgetOptimizer();

  bool _isInitialized = false;
  Timer? _maintenanceTimer;

  /// Inicializa todos os sistemas de performance
  Future<void> initialize() async {
    if (_isInitialized) return;

    log('Initializing Performance Manager', name: 'PerformanceManager');
    _memoryManager.startMonitoring();
    if (kDebugMode) {
      _widgetOptimizer.enableProfiling();
    }
    _startAutomaticMaintenance();

    _isInitialized = true;
    log(
      'Performance Manager initialized successfully',
      name: 'PerformanceManager',
    );
  }

  /// Para todos os sistemas de performance
  void dispose() {
    _memoryManager.stopMonitoring();
    _maintenanceTimer?.cancel();
    _isInitialized = false;
    log('Performance Manager disposed', name: 'PerformanceManager');
  }

  /// Executa otimizações automáticas
  Future<void> runAutoOptimizations() async {
    if (!_isInitialized) return;

    log('Starting auto-optimizations', name: 'PerformanceManager');

    try {
      _memoryManager.cleanup();
      _imageOptimizer.cleanupCache();
      _widgetOptimizer.clearProfilingData();

      log(
        'Auto-optimizations completed successfully',
        name: 'PerformanceManager',
      );
    } catch (e) {
      log('Error during auto-optimizations: $e', name: 'PerformanceManager');
    }
  }

  /// Obtém relatório completo de performance
  Future<ComprehensivePerformanceReport> getComprehensiveReport() async {
    final performanceReport = _performanceService.getReport();
    final memoryReport = _memoryManager.getMemoryReport();
    final navReport = _navOptimizer.getNavigationReport();
    final imageStats = _imageOptimizer.getCacheStats();
    final widgetReport = _widgetOptimizer.getRebuildReport();

    return ComprehensivePerformanceReport(
      generatedAt: DateTime.now(),
      performanceReport: performanceReport,
      memoryReport: memoryReport,
      navigationReport: navReport,
      imageStats: imageStats,
      widgetReport: widgetReport,
      overallScore: _calculateOverallScore(
        performanceReport,
        memoryReport,
        navReport,
        imageStats,
        widgetReport,
      ),
    );
  }

  /// Força limpeza agressiva de todos os sistemas
  Future<void> aggressiveCleanup() async {
    log('Starting aggressive cleanup', name: 'PerformanceManager');

    _memoryManager.cleanup(aggressive: true);
    _imageOptimizer.cleanupCache(aggressive: true);
    _navOptimizer.clearNavigationCache();
    _widgetOptimizer.clearProfilingData();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    log('Aggressive cleanup completed', name: 'PerformanceManager');
  }

  /// Detecta problemas de performance críticos
  List<PerformanceCriticalIssue> detectCriticalIssues() {
    final issues = <PerformanceCriticalIssue>[];
    final memoryLeaks = _memoryManager.detectLeaks();
    if (memoryLeaks.hasLeaks) {
      issues.add(
        PerformanceCriticalIssue(
          type: CriticalIssueType.memoryLeak,
          severity: CriticalIssueSeverity.high,
          description:
              'Memory leaks detected: ${memoryLeaks.totalLeaks} objects',
          recommendation: 'Review object disposal and weak references',
        ),
      );
    }
    final widgetReport = _widgetOptimizer.getRebuildReport();
    if (widgetReport.hasProblematicWidgets) {
      issues.add(
        PerformanceCriticalIssue(
          type: CriticalIssueType.excessiveRebuilds,
          severity: CriticalIssueSeverity.medium,
          description:
              'Widgets with excessive rebuilds: ${widgetReport.problematicWidgets.length}',
          recommendation: 'Optimize widget tree and state management',
        ),
      );
    }

    return issues;
  }

  /// Configurações de performance
  void configurePerformance(PerformanceConfig config) {
    if (config.enableMemoryMonitoring) {
      _memoryManager.startMonitoring(interval: config.memoryMonitoringInterval);
    } else {
      _memoryManager.stopMonitoring();
    }

    if (config.enableWidgetProfiling) {
      _widgetOptimizer.enableProfiling();
    } else {
      _widgetOptimizer.disableProfiling();
    }

    if (config.autoOptimizationInterval != null) {
      _startAutomaticMaintenance(interval: config.autoOptimizationInterval);
    }
  }

  /// Benchmark de performance
  Future<PerformanceBenchmark> runBenchmark() async {
    final stopwatch = Stopwatch()..start();
    final results = <String, Duration>{};
    final memStart = DateTime.now();
    _memoryManager.cleanup();
    results['memory_cleanup'] = DateTime.now().difference(memStart);
    final imgStart = DateTime.now();
    _imageOptimizer.cleanupCache();
    results['image_cleanup'] = DateTime.now().difference(imgStart);

    stopwatch.stop();

    return PerformanceBenchmark(
      totalTime: stopwatch.elapsed,
      operationTimes: results,
      timestamp: DateTime.now(),
    );
  }

  void _startAutomaticMaintenance({Duration? interval}) {
    _maintenanceTimer?.cancel();

    _maintenanceTimer = Timer.periodic(
      interval ?? const Duration(minutes: 10),
      (_) => runAutoOptimizations(),
    );
  }

  double _calculateOverallScore(
    PerformanceReport performanceReport,
    MemoryReport memoryReport,
    NavigationReport navReport,
    ImageCacheStats imageStats,
    RebuildReport widgetReport,
  ) {
    double score = 10.0;
    if (widgetReport.hasProblematicWidgets) score -= 1.0;
    if (imageStats.hitRate < 0.7) score -= 0.5;
    if (imageStats.hitRate > 0.9) score += 0.5;
    if (navReport.preloadedRoutes > 0) score += 0.5;

    return score.clamp(0.0, 10.0);
  }
}

/// Configuração de performance
class PerformanceConfig {
  final bool enableMemoryMonitoring;
  final bool enableWidgetProfiling;
  final Duration memoryMonitoringInterval;
  final Duration? autoOptimizationInterval;

  const PerformanceConfig({
    this.enableMemoryMonitoring = true,
    this.enableWidgetProfiling = false,
    this.memoryMonitoringInterval = const Duration(seconds: 30),
    this.autoOptimizationInterval,
  });
}

/// Relatório abrangente de performance
class ComprehensivePerformanceReport {
  final DateTime generatedAt;
  final PerformanceReport performanceReport;
  final MemoryReport memoryReport;
  final NavigationReport navigationReport;
  final ImageCacheStats imageStats;
  final RebuildReport widgetReport;
  final double overallScore;

  const ComprehensivePerformanceReport({
    required this.generatedAt,
    required this.performanceReport,
    required this.memoryReport,
    required this.navigationReport,
    required this.imageStats,
    required this.widgetReport,
    required this.overallScore,
  });
}

/// Issue crítico de performance
class PerformanceCriticalIssue {
  final CriticalIssueType type;
  final CriticalIssueSeverity severity;
  final String description;
  final String recommendation;

  const PerformanceCriticalIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

enum CriticalIssueType {
  memoryLeak,
  slowDatabase,
  excessiveRebuilds,
  poorCacheHitRate,
  slowNavigation,
}

enum CriticalIssueSeverity { low, medium, high, critical }

/// Benchmark de performance
class PerformanceBenchmark {
  final Duration totalTime;
  final Map<String, Duration> operationTimes;
  final DateTime timestamp;

  const PerformanceBenchmark({
    required this.totalTime,
    required this.operationTimes,
    required this.timestamp,
  });
}

/// Mixin para fácil acesso ao gerenciador de performance
mixin PerformanceMixin {
  PerformanceManager get performanceManager => PerformanceManager();

  /// Executa operação com monitoramento de performance
  Future<T> withPerformanceTracking<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    return performanceManager._performanceService.monitorAsync(
      operationName,
      operation,
    );
  }

  /// Obtém relatório rápido de performance
  Future<ComprehensivePerformanceReport> getPerformanceReport() {
    return performanceManager.getComprehensiveReport();
  }
}
