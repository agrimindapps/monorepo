import 'package:core/core.dart';

/// Performance service específico do app Task Manager
class TaskManagerPerformanceService {
  final IPerformanceRepository _performanceRepository;

  TaskManagerPerformanceService(this._performanceRepository);

  // Traces específicos do Task Manager

  Future<void> startTaskOperationTrace(String operation) async {
    await _performanceRepository.startTrace(
      'task_$operation',
      attributes: {
        'feature': 'task_management',
        'operation_type': operation,
      },
    );
  }

  Future<TraceResult?> stopTaskOperationTrace(
    String operation, {
    int? taskCount,
    bool? success,
  }) async {
    return await _performanceRepository.stopTrace(
      'task_$operation',
      metrics: {
        if (taskCount != null) 'task_count': taskCount.toDouble(),
        'success': success == true ? 1.0 : 0.0,
      },
    );
  }

  Future<void> measureTaskListLoad() async {
    await _performanceRepository.measureOperationTime(
      'task_list_load',
      () async {
        // Esta função será chamada pelo código que carrega a lista
        await Future.delayed(Duration.zero);
      },
      attributes: {
        'feature': 'task_list',
        'operation': 'load',
      },
    );
  }

  Future<void> measureTaskSearch(String searchTerm, int resultCount) async {
    await _performanceRepository.measureOperationTime(
      'task_search',
      () async {
        await Future.delayed(Duration.zero);
      },
      attributes: {
        'feature': 'search',
        'search_term_length': searchTerm.length.toString(),
        'result_count': resultCount.toString(),
      },
    );
  }

  Future<void> measureDataSync() async {
    await _performanceRepository.measureOperationTime(
      'data_sync',
      () async {
        await Future.delayed(Duration.zero);
      },
      attributes: {
        'feature': 'sync',
        'sync_type': 'full',
      },
    );
  }

  // Métricas customizadas do Task Manager

  Future<void> recordTaskOperationMetric({
    required String operation,
    required Duration duration,
    bool success = true,
  }) async {
    await _performanceRepository.recordTiming(
      'task_operation_$operation',
      duration,
      tags: {
        'operation': operation,
        'success': success.toString(),
        'feature': 'task_management',
      },
    );
  }

  Future<void> recordTaskListMetrics({
    required int totalTasks,
    required int visibleTasks,
    required Duration loadTime,
  }) async {
    await _performanceRepository.recordTiming(
      'task_list_load_time',
      loadTime,
      tags: {
        'total_tasks': totalTasks.toString(),
        'visible_tasks': visibleTasks.toString(),
      },
    );

    await _performanceRepository.recordGauge(
      'task_list_size',
      totalTasks.toDouble(),
      tags: {'list_type': 'all_tasks'},
    );

    await _performanceRepository.recordGauge(
      'visible_task_count',
      visibleTasks.toDouble(),
      tags: {'list_type': 'filtered'},
    );
  }

  Future<void> recordSearchMetrics({
    required String searchTerm,
    required int resultCount,
    required Duration searchTime,
  }) async {
    await _performanceRepository.recordTiming(
      'search_duration',
      searchTime,
      tags: {
        'search_term_length': searchTerm.length.toString(),
        'result_count': resultCount.toString(),
      },
    );

    await _performanceRepository.incrementCounter(
      'searches_performed',
      tags: {
        'search_type': 'task_search',
        'has_results': (resultCount > 0).toString(),
      },
    );
  }

  Future<void> recordUIInteractionMetric({
    required String interaction,
    required String screen,
    Duration? responseTime,
  }) async {
    await _performanceRepository.incrementCounter(
      'ui_interaction',
      tags: {
        'interaction_type': interaction,
        'screen_name': screen,
      },
    );

    if (responseTime != null) {
      await _performanceRepository.recordTiming(
        'ui_response_time',
        responseTime,
        tags: {
          'interaction': interaction,
          'screen': screen,
        },
      );
    }
  }

  Future<void> recordDataOperationMetrics({
    required String operation,
    required String entityType,
    required Duration duration,
    bool success = true,
  }) async {
    await _performanceRepository.recordTiming(
      'data_operation',
      duration,
      tags: {
        'operation': operation,
        'entity_type': entityType,
        'success': success.toString(),
      },
    );
  }

  // Monitoramento de saúde específico do app

  Future<Map<String, dynamic>> getTaskManagerHealthReport() async {
    final baseReport = await _performanceRepository.getPerformanceReport();
    final currentMetrics = await _performanceRepository.getCurrentMetrics();
    
    return {
      ...baseReport,
      'task_manager_specific': {
        'active_traces': _performanceRepository.getActiveTraces(),
        'fps_healthy': await _performanceRepository.isFpsHealthy(),
        'memory_healthy': await _performanceRepository.isMemoryHealthy(),
        'cpu_healthy': await _performanceRepository.isCpuHealthy(),
        'performance_score': _calculatePerformanceScore(currentMetrics),
      },
    };
  }

  double _calculatePerformanceScore(PerformanceMetrics metrics) {
    // Score baseado em FPS, memória e CPU
    double score = 100.0;
    
    // FPS penalty (target: 60 fps)
    if (metrics.fps < 60) {
      score -= (60 - metrics.fps) * 0.5;
    }
    
    // Memory penalty (target: < 80% usage)
    if (metrics.memoryUsage.usagePercentage > 80) {
      score -= (metrics.memoryUsage.usagePercentage - 80) * 0.8;
    }
    
    // CPU penalty (target: < 70% usage)
    if (metrics.cpuUsage > 70) {
      score -= (metrics.cpuUsage - 70) * 0.6;
    }
    
    return score.clamp(0, 100);
  }

  // Delegate methods do core
  Future<bool> startPerformanceTracking({PerformanceConfig? config}) =>
      _performanceRepository.startPerformanceTracking(config: config);

  Future<bool> stopPerformanceTracking() =>
      _performanceRepository.stopPerformanceTracking();

  Future<bool> pausePerformanceTracking() =>
      _performanceRepository.pausePerformanceTracking();

  Future<bool> resumePerformanceTracking() =>
      _performanceRepository.resumePerformanceTracking();

  PerformanceMonitoringState getMonitoringState() =>
      _performanceRepository.getMonitoringState();

  Future<void> setPerformanceThresholds(PerformanceThresholds thresholds) =>
      _performanceRepository.setPerformanceThresholds(thresholds);

  Stream<double> getFpsStream() => _performanceRepository.getFpsStream();

  Future<double> getCurrentFps() => _performanceRepository.getCurrentFps();

  Future<FpsMetrics> getFpsMetrics({Duration? period}) =>
      _performanceRepository.getFpsMetrics(period: period);

  Stream<MemoryUsage> getMemoryStream() => _performanceRepository.getMemoryStream();

  Future<MemoryUsage> getMemoryUsage() => _performanceRepository.getMemoryUsage();

  Stream<double> getCpuStream() => _performanceRepository.getCpuStream();

  Future<double> getCpuUsage() => _performanceRepository.getCpuUsage();

  Future<AppStartupMetrics> getStartupMetrics() =>
      _performanceRepository.getStartupMetrics();

  Future<PerformanceMetrics> getCurrentMetrics() =>
      _performanceRepository.getCurrentMetrics();

  Future<List<PerformanceMetrics>> getPerformanceHistory({
    DateTime? since,
    int? limit,
    Duration? period,
  }) => _performanceRepository.getPerformanceHistory(
        since: since,
        limit: limit,
        period: period,
      );

  Stream<Map<String, dynamic>> getPerformanceAlertsStream() =>
      _performanceRepository.getPerformanceAlertsStream();

  Future<List<String>> checkPerformanceIssues() =>
      _performanceRepository.checkPerformanceIssues();

  Future<void> markAppStarted() => _performanceRepository.markAppStarted();

  Future<void> markFirstFrame() => _performanceRepository.markFirstFrame();

  Future<void> markAppInteractive() => _performanceRepository.markAppInteractive();

  List<String> getActiveTraces() => _performanceRepository.getActiveTraces();
}