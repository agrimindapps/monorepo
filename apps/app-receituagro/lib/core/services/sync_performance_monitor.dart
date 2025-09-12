import 'dart:async';
import 'dart:collection';
import 'package:core/core.dart';
import 'package:hive/hive.dart';

/// Monitor de performance de sincronização
class SyncPerformanceMonitor {
  SyncPerformanceMonitor({
    required this.analytics,
    required this.storage,
  });

  final dynamic analytics; // Using dynamic temporarily
  final HiveStorageService storage;

  final _metricsController = StreamController<PerformanceMetrics>.broadcast();
  final _performanceData = Queue<PerformanceMetric>();
  
  // Configurações de monitoramento
  static const int maxStoredMetrics = 1000;
  static const Duration aggregationInterval = Duration(minutes: 5);
  
  Timer? _aggregationTimer;
  bool _isMonitoring = false;

  /// Stream de métricas de performance
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// Inicializa o monitor de performance
  Future<void> initialize() async {
    if (_isMonitoring) return;

    try {
      // Carregar dados históricos
      await _loadHistoricalData();
      
      // Configurar agregação periódica
      _setupPeriodicAggregation();
      
      _isMonitoring = true;

      await analytics.logEvent('performance_monitor_initialized');
    } catch (e) {
      await analytics.logEvent('performance_monitor_init_failed', parameters: {'error': e.toString()});
      rethrow;
    }
  }

  /// Registra início de operação de sincronização
  PerformanceTracker startSyncOperation(String operationId, String operationType) {
    final tracker = PerformanceTracker(
      operationId: operationId,
      operationType: operationType,
      startTime: DateTime.now(),
    );

    return tracker;
  }

  /// Finaliza rastreamento de operação
  Future<void> completeSyncOperation(PerformanceTracker tracker, {
    int? operationsSent,
    int? operationsReceived,
    int? conflictsDetected,
    bool success = true,
    String? error,
  }) async {
    final endTime = DateTime.now();
    final duration = endTime.difference(tracker.startTime);

    final metric = PerformanceMetric(
      operationId: tracker.operationId,
      operationType: tracker.operationType,
      startTime: tracker.startTime,
      endTime: endTime,
      duration: duration,
      operationsSent: operationsSent ?? 0,
      operationsReceived: operationsReceived ?? 0,
      conflictsDetected: conflictsDetected ?? 0,
      success: success,
      error: error,
      memoryUsage: _getCurrentMemoryUsage(),
      networkLatency: tracker.networkLatency,
    );

    await _recordMetric(metric);
  }

  /// Registra métrica de latência de rede
  void recordNetworkLatency(String operationId, Duration latency) {
    // Encontrar tracker ativo e atualizar latência
    // Em implementação real, manteria map de trackers ativos
  }

  /// Registra métrica personalizada
  Future<void> recordCustomMetric(String name, dynamic value, {Map<String, dynamic>? tags}) async {
    await analytics.logEvent('sync_custom_metric', parameters: {
      'metric_name': name,
      'metric_value': value.toString(),
      'tags': tags?.toString() ?? 'none',
    });
  }

  /// Registra erro de performance
  Future<void> recordPerformanceError(String operationType, String error, Duration duration) async {
    final errorMetric = PerformanceMetric(
      operationId: 'error_${DateTime.now().millisecondsSinceEpoch}',
      operationType: operationType,
      startTime: DateTime.now().subtract(duration),
      endTime: DateTime.now(),
      duration: duration,
      success: false,
      error: error,
    );

    await _recordMetric(errorMetric);

    await analytics.logEvent('sync_performance_error', parameters: {
      'error': error,
      'operation_type': operationType,
      'duration_ms': duration.inMilliseconds.toString(),
    });
  }

  /// Obtém métricas atuais
  Future<PerformanceMetrics> getCurrentMetrics() async {
    final recentMetrics = _getRecentMetrics(const Duration(minutes: 30));
    
    if (recentMetrics.isEmpty) {
      return PerformanceMetrics.empty();
    }

    return _aggregateMetrics(recentMetrics);
  }

  /// Obtém métricas históricas
  Future<List<PerformanceMetrics>> getHistoricalMetrics({
    Duration? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Mock Hive box for compilation
    final historicalBox = await Hive.openBox<dynamic>('sync_performance_history');
    
    // Filtrar por período se especificado
    final keys = historicalBox.keys.cast<dynamic>().where((key) {
      if (startDate != null || endDate != null) {
        final timestamp = int.tryParse(key.toString());
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          
          if (startDate != null && date.isBefore(startDate)) return false;
          if (endDate != null && date.isAfter(endDate)) return false;
        }
      }
      return true;
    }).toList();

    final metrics = <PerformanceMetrics>[];
    
    for (final key in keys) {
      final data = historicalBox.get(key) as Map<String, dynamic>?;
      if (data != null) {
        metrics.add(PerformanceMetrics.fromMap(data));
      }
    }

    return metrics..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Obtém relatório de performance
  Future<PerformanceReport> getPerformanceReport({Duration? period}) async {
    final reportPeriod = period ?? const Duration(days: 7);
    final endDate = DateTime.now();
    final startDate = endDate.subtract(reportPeriod);

    final historicalMetrics = await getHistoricalMetrics(
      startDate: startDate,
      endDate: endDate,
    );

    if (historicalMetrics.isEmpty) {
      return PerformanceReport.empty(startDate, endDate);
    }

    // Análises
    final totalOperations = historicalMetrics.fold<int>(
      0, (sum, m) => sum + m.totalOperations,
    );

    final successfulOperations = historicalMetrics.fold<int>(
      0, (sum, m) => sum + m.successfulOperations,
    );

    final totalDuration = historicalMetrics.fold<Duration>(
      Duration.zero, (sum, m) => sum + m.averageDuration,
    );

    final avgLatency = historicalMetrics.isNotEmpty 
        ? totalDuration ~/ historicalMetrics.length 
        : Duration.zero;

    final successRate = totalOperations > 0 
        ? successfulOperations / totalOperations 
        : 0.0;

    // Identificar tendências
    final trends = _analyzeTrends(historicalMetrics);

    // Identificar problemas
    final issues = _identifyPerformanceIssues(historicalMetrics);

    return PerformanceReport(
      startDate: startDate,
      endDate: endDate,
      totalOperations: totalOperations,
      successfulOperations: successfulOperations,
      failedOperations: totalOperations - successfulOperations,
      successRate: successRate,
      averageLatency: avgLatency,
      trends: trends,
      performanceIssues: issues,
      recommendations: _generateRecommendations(historicalMetrics, trends, issues),
    );
  }

  // Métodos internos

  Future<void> _recordMetric(PerformanceMetric metric) async {
    _performanceData.add(metric);
    
    // Limitar tamanho da queue
    while (_performanceData.length > maxStoredMetrics) {
      _performanceData.removeFirst();
    }

    await analytics.logEvent('performance_metric_recorded', parameters: {
      'operation_type': metric.operationType,
      'duration_ms': metric.duration.inMilliseconds.toString(),
      'success': metric.success.toString(),
      'operations_sent': metric.operationsSent.toString(),
    });
  }

  List<PerformanceMetric> _getRecentMetrics(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    
    return _performanceData.where((metric) => 
        metric.startTime.isAfter(cutoff)
    ).toList();
  }

  PerformanceMetrics _aggregateMetrics(List<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return PerformanceMetrics.empty();

    final totalOperations = metrics.length;
    final successfulOperations = metrics.where((m) => m.success).length;
    
    final totalDuration = metrics.fold<Duration>(
      Duration.zero, (sum, m) => sum + m.duration,
    );
    
    final averageDuration = totalDuration ~/ totalOperations;
    
    final totalOperationsSent = metrics.fold<int>(
      0, (sum, m) => sum + m.operationsSent,
    );
    
    final totalOperationsReceived = metrics.fold<int>(
      0, (sum, m) => sum + m.operationsReceived,
    );
    
    final totalConflicts = metrics.fold<int>(
      0, (sum, m) => sum + m.conflictsDetected,
    );

    final operationTypes = <String, int>{};
    for (final metric in metrics) {
      operationTypes[metric.operationType] = 
          (operationTypes[metric.operationType] ?? 0) + 1;
    }

    return PerformanceMetrics(
      timestamp: DateTime.now(),
      totalOperations: totalOperations,
      successfulOperations: successfulOperations,
      failedOperations: totalOperations - successfulOperations,
      averageDuration: averageDuration,
      operationsSent: totalOperationsSent,
      operationsReceived: totalOperationsReceived,
      conflictsDetected: totalConflicts,
      operationTypes: operationTypes,
      successRate: totalOperations > 0 ? successfulOperations / totalOperations : 0.0,
    );
  }

  void _setupPeriodicAggregation() {
    _aggregationTimer?.cancel();
    _aggregationTimer = Timer.periodic(aggregationInterval, (timer) async {
      await _performAggregation();
    });
  }

  Future<void> _performAggregation() async {
    try {
      final recentMetrics = _getRecentMetrics(aggregationInterval);
      
      if (recentMetrics.isEmpty) return;

      final aggregated = _aggregateMetrics(recentMetrics);
      
      // Salvar agregação
      await _saveAggregatedMetrics(aggregated);
      
      // Enviar via stream
      _metricsController.add(aggregated);

      await analytics.logEvent('performance_aggregation_completed', parameters: {
        'metrics_count': recentMetrics.length.toString(),
        'avg_duration_ms': aggregated.averageDuration.inMilliseconds.toString(),
        'success_rate': aggregated.successRate.toString(),
      });
      
    } catch (e) {
      await analytics.logEvent('performance_aggregation_failed', parameters: {'error': e.toString()});
    }
  }

  Future<void> _saveAggregatedMetrics(PerformanceMetrics metrics) async {
    // Mock Hive box for compilation
    final historicalBox = await Hive.openBox<dynamic>('sync_performance_history');
    
    final key = metrics.timestamp.millisecondsSinceEpoch.toString();
    await historicalBox.put(key, metrics.toMap());
    
    // Limpar dados antigos (manter apenas últimos 30 dias)
    await _cleanupOldMetrics(historicalBox);
  }

  Future<void> _cleanupOldMetrics(Box<dynamic> historicalBox) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final keysToDelete = <String>[];
    
    for (final key in historicalBox.keys) {
      final timestamp = int.tryParse(key.toString());
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (date.isBefore(cutoff)) {
          keysToDelete.add(key.toString());
        }
      }
    }
    
    for (final key in keysToDelete) {
      await historicalBox.delete(key);
    }
  }

  Future<void> _loadHistoricalData() async {
    // Carregar métricas históricas se necessário
    // Mock Hive box for compilation
    final historicalBox = await Hive.openBox<dynamic>('sync_performance_history');
    
    await analytics.logEvent('performance_historical_data_loaded', parameters: {
      'historical_entries': historicalBox.length.toString(),
    });
  }

  int _getCurrentMemoryUsage() {
    // Implementação simplificada - em produção usaria dart:io ProcessInfo
    return 0;
  }

  List<PerformanceTrend> _analyzeTrends(List<PerformanceMetrics> metrics) {
    final trends = <PerformanceTrend>[];
    
    if (metrics.length < 2) return trends;

    // Analisar tendência de duração média
    final durations = metrics.map((m) => m.averageDuration.inMilliseconds).toList();
    final durationTrend = _calculateTrend(durations);
    
    if (durationTrend.abs() > 10) { // Mudança de mais de 10ms
      trends.add(PerformanceTrend(
        metric: 'average_duration',
        direction: durationTrend > 0 ? TrendDirection.increasing : TrendDirection.decreasing,
        magnitude: durationTrend.abs(),
        description: durationTrend > 0 
            ? 'Sync operations are getting slower'
            : 'Sync operations are getting faster',
      ));
    }

    // Analisar tendência de success rate
    final successRates = metrics.map((m) => m.successRate * 100).toList();
    final successTrend = _calculateTrend(successRates);
    
    if (successTrend.abs() > 5) { // Mudança de mais de 5%
      trends.add(PerformanceTrend(
        metric: 'success_rate',
        direction: successTrend > 0 ? TrendDirection.increasing : TrendDirection.decreasing,
        magnitude: successTrend.abs(),
        description: successTrend > 0 
            ? 'Success rate is improving'
            : 'Success rate is declining',
      ));
    }

    return trends;
  }

  double _calculateTrend(List<num> values) {
    if (values.length < 2) return 0.0;
    
    // Cálculo de tendência simples (diferença entre primeiro e último)
    final first = values.first.toDouble();
    final last = values.last.toDouble();
    
    return last - first;
  }

  List<PerformanceIssue> _identifyPerformanceIssues(List<PerformanceMetrics> metrics) {
    final issues = <PerformanceIssue>[];
    
    for (final metric in metrics) {
      // Issue: Success rate baixa
      if (metric.successRate < 0.9) {
        issues.add(PerformanceIssue(
          type: PerformanceIssueType.lowSuccessRate,
          severity: metric.successRate < 0.7 ? IssueSeverity.high : IssueSeverity.medium,
          description: 'Success rate is ${(metric.successRate * 100).toStringAsFixed(1)}%',
          detectedAt: metric.timestamp,
          affectedMetric: 'success_rate',
          value: metric.successRate,
        ));
      }
      
      // Issue: Latência alta
      if (metric.averageDuration.inMilliseconds > 5000) {
        issues.add(PerformanceIssue(
          type: PerformanceIssueType.highLatency,
          severity: metric.averageDuration.inMilliseconds > 10000 ? IssueSeverity.high : IssueSeverity.medium,
          description: 'Average sync duration is ${metric.averageDuration.inMilliseconds}ms',
          detectedAt: metric.timestamp,
          affectedMetric: 'average_duration',
          value: metric.averageDuration.inMilliseconds,
        ));
      }
      
      // Issue: Muitos conflitos
      if (metric.totalOperations > 0 && (metric.conflictsDetected / metric.totalOperations) > 0.1) {
        issues.add(PerformanceIssue(
          type: PerformanceIssueType.highConflictRate,
          severity: IssueSeverity.medium,
          description: 'High conflict rate: ${((metric.conflictsDetected / metric.totalOperations) * 100).toStringAsFixed(1)}%',
          detectedAt: metric.timestamp,
          affectedMetric: 'conflict_rate',
          value: metric.conflictsDetected / metric.totalOperations,
        ));
      }
    }
    
    return issues;
  }

  List<PerformanceRecommendation> _generateRecommendations(
    List<PerformanceMetrics> metrics,
    List<PerformanceTrend> trends,
    List<PerformanceIssue> issues,
  ) {
    final recommendations = <PerformanceRecommendation>[];
    
    // Recomendações baseadas em issues
    for (final issue in issues) {
      switch (issue.type) {
        case PerformanceIssueType.lowSuccessRate:
          recommendations.add(PerformanceRecommendation(
            type: RecommendationType.optimization,
            priority: issue.severity == IssueSeverity.high ? RecommendationPriority.high : RecommendationPriority.medium,
            title: 'Improve sync reliability',
            description: 'Consider implementing better error handling and retry mechanisms',
            estimatedImpact: 'Could improve success rate by 10-20%',
          ));
          break;
          
        case PerformanceIssueType.highLatency:
          recommendations.add(PerformanceRecommendation(
            type: RecommendationType.optimization,
            priority: RecommendationPriority.high,
            title: 'Optimize sync performance',
            description: 'Consider implementing batch operations and reducing payload size',
            estimatedImpact: 'Could reduce sync time by 30-50%',
          ));
          break;
          
        case PerformanceIssueType.highConflictRate:
          recommendations.add(PerformanceRecommendation(
            type: RecommendationType.architecture,
            priority: RecommendationPriority.medium,
            title: 'Improve conflict resolution',
            description: 'Review data models and sync patterns to reduce conflicts',
            estimatedImpact: 'Could reduce conflicts by 50-70%',
          ));
          break;
        case PerformanceIssueType.memoryLeak:
          recommendations.add(PerformanceRecommendation(
            type: RecommendationType.optimization,
            priority: RecommendationPriority.high,
            title: 'Fix memory leak',
            description: 'Investigate and fix memory leaks in sync operations',
            estimatedImpact: 'Could improve app stability',
          ));
          break;
      }
    }
    
    return recommendations;
  }

  /// Dispose dos recursos
  void dispose() {
    _aggregationTimer?.cancel();
    _metricsController.close();
  }
}

// Modelos de dados para performance monitoring

class PerformanceTracker {
  const PerformanceTracker({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    this.networkLatency,
  });

  final String operationId;
  final String operationType;
  final DateTime startTime;
  final Duration? networkLatency;
}

class PerformanceMetric {
  const PerformanceMetric({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    this.operationsSent = 0,
    this.operationsReceived = 0,
    this.conflictsDetected = 0,
    this.success = true,
    this.error,
    this.memoryUsage = 0,
    this.networkLatency,
  });

  final String operationId;
  final String operationType;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final int operationsSent;
  final int operationsReceived;
  final int conflictsDetected;
  final bool success;
  final String? error;
  final int memoryUsage;
  final Duration? networkLatency;
}

class PerformanceMetrics {
  const PerformanceMetrics({
    required this.timestamp,
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.averageDuration,
    required this.operationsSent,
    required this.operationsReceived,
    required this.conflictsDetected,
    required this.operationTypes,
    required this.successRate,
  });

  final DateTime timestamp;
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Duration averageDuration;
  final int operationsSent;
  final int operationsReceived;
  final int conflictsDetected;
  final Map<String, int> operationTypes;
  final double successRate;

  factory PerformanceMetrics.empty() => PerformanceMetrics(
    timestamp: DateTime.now(),
    totalOperations: 0,
    successfulOperations: 0,
    failedOperations: 0,
    averageDuration: Duration.zero,
    operationsSent: 0,
    operationsReceived: 0,
    conflictsDetected: 0,
    operationTypes: {},
    successRate: 0.0,
  );

  Map<String, dynamic> toMap() => {
    'timestamp': timestamp.millisecondsSinceEpoch,
    'totalOperations': totalOperations,
    'successfulOperations': successfulOperations,
    'failedOperations': failedOperations,
    'averageDurationMs': averageDuration.inMilliseconds,
    'operationsSent': operationsSent,
    'operationsReceived': operationsReceived,
    'conflictsDetected': conflictsDetected,
    'operationTypes': operationTypes,
    'successRate': successRate,
  };

  static PerformanceMetrics fromMap(Map<String, dynamic> map) => PerformanceMetrics(
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    totalOperations: map['totalOperations'] as int,
    successfulOperations: map['successfulOperations'] as int,
    failedOperations: map['failedOperations'] as int,
    averageDuration: Duration(milliseconds: map['averageDurationMs'] as int),
    operationsSent: map['operationsSent'] as int,
    operationsReceived: map['operationsReceived'] as int,
    conflictsDetected: map['conflictsDetected'] as int,
    operationTypes: Map<String, int>.from(map['operationTypes'] as Map),
    successRate: map['successRate'] as double,
  );
}

enum TrendDirection { increasing, decreasing, stable }

class PerformanceTrend {
  const PerformanceTrend({
    required this.metric,
    required this.direction,
    required this.magnitude,
    required this.description,
  });

  final String metric;
  final TrendDirection direction;
  final double magnitude;
  final String description;
}

enum PerformanceIssueType { lowSuccessRate, highLatency, highConflictRate, memoryLeak }
enum IssueSeverity { low, medium, high, critical }

class PerformanceIssue {
  const PerformanceIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.detectedAt,
    required this.affectedMetric,
    required this.value,
  });

  final PerformanceIssueType type;
  final IssueSeverity severity;
  final String description;
  final DateTime detectedAt;
  final String affectedMetric;
  final num value;
}

enum RecommendationType { optimization, configuration, architecture, monitoring }
enum RecommendationPriority { low, medium, high, critical }

class PerformanceRecommendation {
  const PerformanceRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.estimatedImpact,
  });

  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final String estimatedImpact;
}

class PerformanceReport {
  const PerformanceReport({
    required this.startDate,
    required this.endDate,
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.successRate,
    required this.averageLatency,
    required this.trends,
    required this.performanceIssues,
    required this.recommendations,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final double successRate;
  final Duration averageLatency;
  final List<PerformanceTrend> trends;
  final List<PerformanceIssue> performanceIssues;
  final List<PerformanceRecommendation> recommendations;

  factory PerformanceReport.empty(DateTime startDate, DateTime endDate) => 
      PerformanceReport(
        startDate: startDate,
        endDate: endDate,
        totalOperations: 0,
        successfulOperations: 0,
        failedOperations: 0,
        successRate: 0.0,
        averageLatency: Duration.zero,
        trends: [],
        performanceIssues: [],
        recommendations: [],
      );
}