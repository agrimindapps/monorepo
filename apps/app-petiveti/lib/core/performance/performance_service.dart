import 'dart:async';
import 'dart:io';

/// Serviço de otimização e monitoramento de performance
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, PerformanceMetric> _metrics = {};
  final List<PerformanceEvent> _events = [];
  
  static const int maxEventsToKeep = 100;

  /// Inicia medição de performance para uma operação
  PerformanceTracker startTracking(String operationName, {Map<String, dynamic>? metadata}) {
    final tracker = PerformanceTracker._(operationName, metadata);
    return tracker;
  }

  /// Registra uma métrica de performance
  void recordMetric(String name, double value, {String? unit, Map<String, dynamic>? metadata}) {
    final metric = PerformanceMetric(
      name: name,
      value: value,
      unit: unit,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _metrics[name] = metric;
    _addEvent(PerformanceEvent(
      type: PerformanceEventType.metric,
      name: name,
      timestamp: DateTime.now(),
      data: {'value': value, 'unit': unit},
    ));
  }

  /// Registra tempo de execução de uma operação
  void recordExecutionTime(String operationName, Duration duration, {Map<String, dynamic>? metadata}) {
    recordMetric(
      '${operationName}_execution_time',
      duration.inMilliseconds.toDouble(),
      unit: 'ms',
      metadata: metadata,
    );
  }

  /// Monitora uso de memória
  Future<MemoryUsage> getMemoryUsage() async {
    final info = ProcessInfo.currentRss;
    final maxRss = ProcessInfo.maxRss;
    
    return MemoryUsage(
      currentRss: info,
      maxRss: maxRss,
      timestamp: DateTime.now(),
    );
  }

  /// Monitora execução de Future com métricas automáticas
  Future<T> monitorAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final tracker = startTracking(operationName, metadata: metadata);
    
    try {
      final result = await operation();
      tracker.finish(success: true);
      return result;
    } catch (error) {
      tracker.finish(success: false, error: error);
      rethrow;
    }
  }

  /// Monitora execução síncrona com métricas automáticas
  T monitor<T>(
    String operationName,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final tracker = startTracking(operationName, metadata: metadata);
    
    try {
      final result = operation();
      tracker.finish(success: true);
      return result;
    } catch (error) {
      tracker.finish(success: false, error: error);
      rethrow;
    }
  }

  /// Obtém relatório de performance
  PerformanceReport getReport({Duration? period}) {
    final now = DateTime.now();
    final startTime = period != null ? now.subtract(period) : null;

    final relevantEvents = startTime != null 
        ? _events.where((event) => event.timestamp.isAfter(startTime)).toList()
        : _events;

    final operationStats = <String, OperationStatistics>{};
    final operationTimes = <String, List<double>>{};

    for (final event in relevantEvents) {
      if (event.type == PerformanceEventType.operationComplete) {
        final operationName = event.name;
        final duration = event.data!['duration'] as double;
        final success = event.data!['success'] as bool;

        operationTimes.putIfAbsent(operationName, () => []).add(duration);

        final currentStats = operationStats[operationName];
        if (currentStats == null) {
          operationStats[operationName] = OperationStatistics(
            name: operationName,
            totalExecutions: 1,
            successfulExecutions: success ? 1 : 0,
            totalTime: duration,
            minTime: duration,
            maxTime: duration,
            avgTime: duration,
          );
        } else {
          final totalExec = currentStats.totalExecutions + 1;
          final successExec = currentStats.successfulExecutions + (success ? 1 : 0);
          final totalTime = currentStats.totalTime + duration;
          final minTime = duration < currentStats.minTime ? duration : currentStats.minTime;
          final maxTime = duration > currentStats.maxTime ? duration : currentStats.maxTime;
          final avgTime = totalTime / totalExec;

          operationStats[operationName] = OperationStatistics(
            name: operationName,
            totalExecutions: totalExec,
            successfulExecutions: successExec,
            totalTime: totalTime,
            minTime: minTime,
            maxTime: maxTime,
            avgTime: avgTime,
          );
        }
      }
    }

    return PerformanceReport(
      generatedAt: now,
      period: period,
      operationStatistics: operationStats,
      totalEvents: relevantEvents.length,
      memoryUsage: ProcessInfo.currentRss,
    );
  }

  /// Limpa métricas antigas
  void cleanup({Duration? olderThan}) {
    final cutoff = DateTime.now().subtract(olderThan ?? const Duration(hours: 24));
    
    _events.removeWhere((event) => event.timestamp.isBefore(cutoff));
    
    final expiredMetrics = _metrics.entries
        .where((entry) => entry.value.timestamp.isBefore(cutoff))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredMetrics) {
      _metrics.remove(key);
    }
  }

  /// Obtém estatísticas de uma operação específica
  OperationStatistics? getOperationStatistics(String operationName, {Duration? period}) {
    final report = getReport(period: period);
    return report.operationStatistics[operationName];
  }

  /// Detecta operações lentas
  List<SlowOperation> getSlowOperations({double thresholdMs = 1000, Duration? period}) {
    final report = getReport(period: period);
    final slowOps = <SlowOperation>[];

    for (final stat in report.operationStatistics.values) {
      if (stat.avgTime > thresholdMs) {
        slowOps.add(SlowOperation(
          name: stat.name,
          avgTime: stat.avgTime,
          maxTime: stat.maxTime,
          executions: stat.totalExecutions,
          successRate: stat.successRate,
        ));
      }
    }

    slowOps.sort((a, b) => b.avgTime.compareTo(a.avgTime));
    return slowOps;
  }

  /// Exporta métricas para análise externa
  Map<String, dynamic> exportMetrics() {
    return {
      'metrics': _metrics.map((key, metric) => MapEntry(key, metric.toJson())),
      'events': _events.map((event) => event.toJson()).toList(),
      'report': getReport().toJson(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  void _addEvent(PerformanceEvent event) {
    _events.add(event);
    if (_events.length > maxEventsToKeep) {
      _events.removeAt(0);
    }
  }
}

/// Tracker para medir performance de operações individuais
class PerformanceTracker {
  final String operationName;
  final Map<String, dynamic>? metadata;
  final DateTime _startTime;
  
  PerformanceTracker._(this.operationName, this.metadata) : _startTime = DateTime.now();

  /// Finaliza o tracking e registra as métricas
  void finish({bool success = true, dynamic error}) {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);

    final performanceService = PerformanceService();
    performanceService.recordExecutionTime(operationName, duration, metadata: metadata);
    
    performanceService._addEvent(PerformanceEvent(
      type: PerformanceEventType.operationComplete,
      name: operationName,
      timestamp: endTime,
      data: {
        'duration': duration.inMilliseconds.toDouble(),
        'success': success,
        'error': error?.toString(),
        'metadata': metadata,
      },
    ));
  }
}

/// Métrica de performance
class PerformanceMetric {
  final String name;
  final double value;
  final String? unit;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PerformanceMetric({
    required this.name,
    required this.value,
    this.unit,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

/// Evento de performance
class PerformanceEvent {
  final PerformanceEventType type;
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const PerformanceEvent({
    required this.type,
    required this.name,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };
}

enum PerformanceEventType {
  metric,
  operationStart,
  operationComplete,
  error,
}

/// Uso de memória
class MemoryUsage {
  final int currentRss;
  final int maxRss;
  final DateTime timestamp;

  const MemoryUsage({
    required this.currentRss,
    required this.maxRss,
    required this.timestamp,
  });

  /// RSS atual formatado
  String get formattedCurrentRss => _formatBytes(currentRss);
  
  /// RSS máximo formatado
  String get formattedMaxRss => _formatBytes(maxRss);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Estatísticas de operação
class OperationStatistics {
  final String name;
  final int totalExecutions;
  final int successfulExecutions;
  final double totalTime;
  final double minTime;
  final double maxTime;
  final double avgTime;

  const OperationStatistics({
    required this.name,
    required this.totalExecutions,
    required this.successfulExecutions,
    required this.totalTime,
    required this.minTime,
    required this.maxTime,
    required this.avgTime,
  });

  /// Taxa de sucesso
  double get successRate => totalExecutions > 0 ? successfulExecutions / totalExecutions : 0.0;
  
  /// Taxa de erro
  double get errorRate => 1.0 - successRate;

  /// Taxa de sucesso formatada
  String get formattedSuccessRate => '${(successRate * 100).toStringAsFixed(1)}%';
}

/// Relatório de performance
class PerformanceReport {
  final DateTime generatedAt;
  final Duration? period;
  final Map<String, OperationStatistics> operationStatistics;
  final int totalEvents;
  final int memoryUsage;

  const PerformanceReport({
    required this.generatedAt,
    this.period,
    required this.operationStatistics,
    required this.totalEvents,
    required this.memoryUsage,
  });

  Map<String, dynamic> toJson() => {
    'generated_at': generatedAt.toIso8601String(),
    'period_hours': period?.inHours,
    'operation_statistics': operationStatistics.map((key, stats) => MapEntry(key, {
      'name': stats.name,
      'total_executions': stats.totalExecutions,
      'successful_executions': stats.successfulExecutions,
      'success_rate': stats.successRate,
      'total_time_ms': stats.totalTime,
      'min_time_ms': stats.minTime,
      'max_time_ms': stats.maxTime,
      'avg_time_ms': stats.avgTime,
    })),
    'total_events': totalEvents,
    'memory_usage_bytes': memoryUsage,
  };
}

/// Operação lenta detectada
class SlowOperation {
  final String name;
  final double avgTime;
  final double maxTime;
  final int executions;
  final double successRate;

  const SlowOperation({
    required this.name,
    required this.avgTime,
    required this.maxTime,
    required this.executions,
    required this.successRate,
  });
}

/// Extension para facilitar uso do PerformanceService
extension PerformanceExtensions on Future<dynamic> {
  /// Monitora esta Future automaticamente
  Future<T> withPerformanceTracking<T>(String operationName, {Map<String, dynamic>? metadata}) {
    return PerformanceService().monitorAsync(operationName, () => this as Future<T>, metadata: metadata);
  }
}

/// Mixin para classes que querem monitoramento de performance automático
mixin PerformanceMonitoring {
  final PerformanceService _performanceService = PerformanceService();

  /// Monitora execução de método
  Future<T> trackAsync<T>(String methodName, Future<T> Function() operation) {
    return _performanceService.monitorAsync('${runtimeType}_$methodName', operation);
  }

  /// Monitora execução síncrona de método
  T track<T>(String methodName, T Function() operation) {
    return _performanceService.monitor('${runtimeType}_$methodName', operation);
  }
}