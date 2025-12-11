import 'dart:async';

import 'package:flutter/foundation.dart';

import '../entities/plant.dart';
import '../entities/plant_task.dart';
import 'plant_task_validation_service.dart';

/// Serviço de monitoramento para sistema de PlantTasks
/// Coleta métricas, detecta problemas e gera alertas
class PlantTaskMonitoringService {
  static PlantTaskMonitoringService? _instance;
  static PlantTaskMonitoringService get instance =>
      _instance ??= PlantTaskMonitoringService._();

  PlantTaskMonitoringService._();

  final _metrics = <String, dynamic>{};
  final _events = <PlantTaskEvent>[];
  final _alerts = <PlantTaskAlert>[];
  final _maxEvents = 1000; // Limitar eventos em memória
  final _maxAlerts = 100; // Limitar alertas em memória

  Timer? _periodicValidationTimer;
  bool _isMonitoringEnabled = true;

  /// Inicia monitoramento periódico
  void startMonitoring({Duration interval = const Duration(minutes: 15)}) {
    if (!_isMonitoringEnabled) return;

    _periodicValidationTimer?.cancel();
    _periodicValidationTimer = Timer.periodic(interval, (timer) {
      _recordEvent(PlantTaskEvent.systemCheck());

      if (kDebugMode) {
        print('🔍 PlantTaskMonitoring: Verificação periódica executada');
      }
    });

    _recordEvent(PlantTaskEvent.monitoringStarted());

    if (kDebugMode) {
      print(
        '🔍 PlantTaskMonitoring: Monitoramento iniciado com intervalo de ${interval.inMinutes} minutos',
      );
    }
  }

  /// Para monitoramento periódico
  void stopMonitoring() {
    _periodicValidationTimer?.cancel();
    _periodicValidationTimer = null;

    _recordEvent(PlantTaskEvent.monitoringStopped());

    if (kDebugMode) {
      print('🔍 PlantTaskMonitoring: Monitoramento parado');
    }
  }

  /// Habilita/desabilita monitoramento
  void setMonitoringEnabled(bool enabled) {
    _isMonitoringEnabled = enabled;

    if (!enabled) {
      stopMonitoring();
    }

    if (kDebugMode) {
      print(
        '🔍 PlantTaskMonitoring: Monitoramento ${enabled ? 'habilitado' : 'desabilitado'}',
      );
    }
  }

  /// Registra evento de criação de PlantTask
  void recordTaskCreation(PlantTask task, Plant? plant) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.taskCreated(task, plant));
    _updateMetric('tasks_created_total', 1, increment: true);
    _updateMetric(
      'tasks_created_by_type_${task.type.name}',
      1,
      increment: true,
    );
    final validation = PlantTaskValidationService.validatePlantTask(
      task,
      plant,
    );
    if (!validation.isValid) {
      _recordAlert(PlantTaskAlert.invalidTaskCreated(task, validation.errors));
    }

    if (kDebugMode) {
      print(
        '📝 PlantTaskMonitoring: Task criada - ${task.title} (${task.type.displayName})',
      );
    }
  }

  /// Registra evento de conclusão de PlantTask
  void recordTaskCompletion(PlantTask task, Plant? plant) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.taskCompleted(task, plant));
    _updateMetric('tasks_completed_total', 1, increment: true);
    _updateMetric(
      'tasks_completed_by_type_${task.type.name}',
      1,
      increment: true,
    );
    if (task.completedDate != null) {
      final daysToComplete = task.completedDate!
          .difference(task.scheduledDate)
          .inDays;
      _updateMetric('avg_days_to_complete', daysToComplete);

      if (daysToComplete > 0) {
        _updateMetric('overdue_completions_total', 1, increment: true);
      }
    }

    if (kDebugMode) {
      print('✅ PlantTaskMonitoring: Task completada - ${task.title}');
    }
  }

  /// Registra evento de falha/erro
  void recordError(
    String operation,
    String error, {
    Map<String, dynamic>? context,
  }) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.error(operation, error, context));
    _updateMetric('errors_total', 1, increment: true);
    _updateMetric('errors_by_operation_$operation', 1, increment: true);

    _recordAlert(PlantTaskAlert.operationError(operation, error));

    if (kDebugMode) {
      print('❌ PlantTaskMonitoring: Erro em $operation - $error');
    }
  }

  /// Registra evento de sincronização
  void recordSyncEvent(
    String syncType,
    int itemCount,
    bool success, {
    Duration? duration,
  }) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.sync(syncType, itemCount, success, duration));

    if (success) {
      _updateMetric('sync_success_total', 1, increment: true);
      _updateMetric('sync_items_total', itemCount, increment: true);
    } else {
      _updateMetric('sync_failures_total', 1, increment: true);
      _recordAlert(PlantTaskAlert.syncFailure(syncType, itemCount));
    }

    if (duration != null) {
      _updateMetric('avg_sync_duration_ms', duration.inMilliseconds);
    }

    if (kDebugMode) {
      print(
        '🔄 PlantTaskMonitoring: Sync $syncType - ${success ? 'sucesso' : 'falha'} ($itemCount items)',
      );
    }
  }

  /// Registra validação em lote
  void recordBatchValidation(PlantTaskBatchValidationResult validation) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.batchValidation(validation));

    _updateMetric('last_validation_total_tasks', validation.totalTasks);
    _updateMetric('last_validation_valid_tasks', validation.validTasks);
    _updateMetric('last_validation_invalid_tasks', validation.invalidTasks);
    _updateMetric('validation_runs_total', 1, increment: true);
    if (validation.invalidTasks > 0) {
      _recordAlert(PlantTaskAlert.validationIssues(validation));
    }

    if (validation.duplicateIds.isNotEmpty) {
      _recordAlert(PlantTaskAlert.duplicateIds(validation.duplicateIds));
    }

    if (validation.orphanTasks.isNotEmpty) {
      _recordAlert(PlantTaskAlert.orphanTasks(validation.orphanTasks));
    }

    if (kDebugMode) {
      print(
        '✅ PlantTaskMonitoring: Validação em lote - ${validation.validTasks}/${validation.totalTasks} válidas',
      );
    }
  }

  /// Registra relatório de saúde
  void recordHealthReport(PlantTaskHealthReport report) {
    if (!_isMonitoringEnabled) return;

    _recordEvent(PlantTaskEvent.healthReport(report));

    _updateMetric('last_health_score', report.healthScore);
    _updateMetric('health_reports_total', 1, increment: true);
    if (report.healthScore < 70) {
      _recordAlert(PlantTaskAlert.lowHealthScore(report.healthScore));
    }

    if (kDebugMode) {
      print(
        '🏥 PlantTaskMonitoring: Health score - ${report.healthScore.toStringAsFixed(1)}/100',
      );
    }
  }

  /// Executa diagnóstico completo do sistema
  PlantTaskSystemDiagnostic runDiagnostic(
    List<PlantTask> tasks,
    Map<String, Plant> plantsById,
  ) {
    if (kDebugMode) {
      print('🔍 PlantTaskMonitoring: Executando diagnóstico completo');
    }

    final validation = PlantTaskValidationService.validatePlantTasks(
      tasks,
      plantsById,
    );
    final healthReport = PlantTaskValidationService.generateHealthReport(
      tasks,
      plantsById,
    );

    recordBatchValidation(validation);
    recordHealthReport(healthReport);

    final recentEvents = getRecentEvents(limit: 50);
    final recentAlerts = getRecentAlerts(limit: 20);
    final systemMetrics = getCurrentMetrics();

    final diagnostic = PlantTaskSystemDiagnostic(
      timestamp: DateTime.now(),
      validation: validation,
      healthReport: healthReport,
      recentEvents: recentEvents,
      recentAlerts: recentAlerts,
      systemMetrics: systemMetrics,
      isHealthy: healthReport.isHealthy && recentAlerts.isEmpty,
    );

    _recordEvent(PlantTaskEvent.diagnosticCompleted(diagnostic));

    if (kDebugMode) {
      print(
        '🔍 PlantTaskMonitoring: Diagnóstico concluído - Sistema ${diagnostic.isHealthy ? 'saudável' : 'com problemas'}',
      );
    }

    return diagnostic;
  }

  /// Obtém eventos recentes
  List<PlantTaskEvent> getRecentEvents({int limit = 100}) {
    return _events.reversed.take(limit).toList();
  }

  /// Obtém alertas recentes
  List<PlantTaskAlert> getRecentAlerts({int limit = 50}) {
    return _alerts.reversed.take(limit).toList();
  }

  /// Obtém métricas atuais
  Map<String, dynamic> getCurrentMetrics() {
    return Map.from(_metrics)
      ..['last_updated'] = DateTime.now().toIso8601String();
  }

  /// Limpa eventos antigos
  void clearOldEvents() {
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }

    if (_alerts.length > _maxAlerts) {
      _alerts.removeRange(0, _alerts.length - _maxAlerts);
    }

    if (kDebugMode) {
      print(
        '🧹 PlantTaskMonitoring: Eventos antigos limpos (${_events.length} eventos, ${_alerts.length} alertas)',
      );
    }
  }

  /// Reseta todas as métricas
  void resetMetrics() {
    _metrics.clear();
    _events.clear();
    _alerts.clear();

    _recordEvent(PlantTaskEvent.metricsReset());

    if (kDebugMode) {
      print('🔄 PlantTaskMonitoring: Métricas resetadas');
    }
  }

  /// Registra evento interno
  void _recordEvent(PlantTaskEvent event) {
    _events.add(event);
    if (_events.length > _maxEvents * 1.2) {
      clearOldEvents();
    }
  }

  /// Registra alerta interno
  void _recordAlert(PlantTaskAlert alert) {
    _alerts.add(alert);
    if (_alerts.length > _maxAlerts * 1.2) {
      clearOldEvents();
    }
  }

  /// Atualiza métrica interna
  void _updateMetric(String key, dynamic value, {bool increment = false}) {
    if (increment && _metrics[key] != null) {
      _metrics[key] = (_metrics[key] as num) + (value as num);
    } else {
      _metrics[key] = value;
    }
    _metrics['${key}_last_updated'] = DateTime.now().millisecondsSinceEpoch;
  }

  /// Cleanup quando serviço é destruído
  void dispose() {
    stopMonitoring();
    _recordEvent(PlantTaskEvent.serviceDisposed());

    if (kDebugMode) {
      print('🔍 PlantTaskMonitoring: Serviço finalizado');
    }
  }
}

/// Evento do sistema de PlantTasks
class PlantTaskEvent {
  final DateTime timestamp;
  final String type;
  final String description;
  final Map<String, dynamic>? data;

  PlantTaskEvent({required this.type, required this.description, this.data})
    : timestamp = DateTime.now();

  factory PlantTaskEvent.taskCreated(
    PlantTask task,
    Plant? plant,
  ) => PlantTaskEvent(
    type: 'task_created',
    description:
        'Task "${task.title}" criada para planta ${plant?.name ?? 'unknown'}',
    data: {
      'task_id': task.id,
      'plant_id': task.plantId,
      'task_type': task.type.name,
    },
  );

  factory PlantTaskEvent.taskCompleted(PlantTask task, Plant? plant) =>
      PlantTaskEvent(
        type: 'task_completed',
        description: 'Task "${task.title}" completada',
        data: {'task_id': task.id, 'plant_id': task.plantId},
      );

  factory PlantTaskEvent.error(
    String operation,
    String error,
    Map<String, dynamic>? context,
  ) => PlantTaskEvent(
    type: 'error',
    description: 'Erro em $operation: $error',
    data: {'operation': operation, 'error': error, ...?context},
  );

  factory PlantTaskEvent.sync(
    String syncType,
    int itemCount,
    bool success,
    Duration? duration,
  ) => PlantTaskEvent(
    type: 'sync',
    description:
        'Sync $syncType ${success ? 'bem-sucedido' : 'falhou'} ($itemCount items)',
    data: {
      'sync_type': syncType,
      'item_count': itemCount,
      'success': success,
      'duration_ms': duration?.inMilliseconds,
    },
  );

  factory PlantTaskEvent.batchValidation(
    PlantTaskBatchValidationResult validation,
  ) => PlantTaskEvent(
    type: 'batch_validation',
    description:
        'Validação em lote: ${validation.validTasks}/${validation.totalTasks} válidas',
    data: {
      'total_tasks': validation.totalTasks,
      'valid_tasks': validation.validTasks,
      'invalid_tasks': validation.invalidTasks,
    },
  );

  factory PlantTaskEvent.healthReport(PlantTaskHealthReport report) =>
      PlantTaskEvent(
        type: 'health_report',
        description:
            'Relatório de saúde: ${report.healthScore.toStringAsFixed(1)}/100',
        data: {
          'health_score': report.healthScore,
          'total_tasks': report.totalTasks,
        },
      );

  factory PlantTaskEvent.diagnosticCompleted(
    PlantTaskSystemDiagnostic diagnostic,
  ) => PlantTaskEvent(
    type: 'diagnostic_completed',
    description:
        'Diagnóstico concluído - Sistema ${diagnostic.isHealthy ? 'saudável' : 'com problemas'}',
    data: {'is_healthy': diagnostic.isHealthy},
  );

  factory PlantTaskEvent.systemCheck() => PlantTaskEvent(
    type: 'system_check',
    description: 'Verificação periódica do sistema',
  );

  factory PlantTaskEvent.monitoringStarted() => PlantTaskEvent(
    type: 'monitoring_started',
    description: 'Monitoramento iniciado',
  );

  factory PlantTaskEvent.monitoringStopped() => PlantTaskEvent(
    type: 'monitoring_stopped',
    description: 'Monitoramento parado',
  );

  factory PlantTaskEvent.metricsReset() =>
      PlantTaskEvent(type: 'metrics_reset', description: 'Métricas resetadas');

  factory PlantTaskEvent.serviceDisposed() => PlantTaskEvent(
    type: 'service_disposed',
    description: 'Serviço de monitoramento finalizado',
  );
}

/// Alerta do sistema
class PlantTaskAlert {
  final DateTime timestamp;
  final String type;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String message;
  final Map<String, dynamic>? data;

  PlantTaskAlert({
    required this.type,
    required this.severity,
    required this.message,
    this.data,
  }) : timestamp = DateTime.now();

  factory PlantTaskAlert.invalidTaskCreated(
    PlantTask task,
    List<String> errors,
  ) => PlantTaskAlert(
    type: 'invalid_task_created',
    severity: 'high',
    message: 'Task inválida criada: ${task.title}',
    data: {'task_id': task.id, 'errors': errors},
  );

  factory PlantTaskAlert.operationError(String operation, String error) =>
      PlantTaskAlert(
        type: 'operation_error',
        severity: 'high',
        message: 'Erro em $operation: $error',
        data: {'operation': operation, 'error': error},
      );

  factory PlantTaskAlert.syncFailure(String syncType, int itemCount) =>
      PlantTaskAlert(
        type: 'sync_failure',
        severity: 'medium',
        message: 'Falha na sincronização $syncType ($itemCount items)',
        data: {'sync_type': syncType, 'item_count': itemCount},
      );

  factory PlantTaskAlert.validationIssues(
    PlantTaskBatchValidationResult validation,
  ) => PlantTaskAlert(
    type: 'validation_issues',
    severity: 'medium',
    message: '${validation.invalidTasks} tasks inválidas encontradas',
    data: {
      'invalid_count': validation.invalidTasks,
      'total_count': validation.totalTasks,
    },
  );

  factory PlantTaskAlert.duplicateIds(List<String> duplicateIds) =>
      PlantTaskAlert(
        type: 'duplicate_ids',
        severity: 'high',
        message: 'IDs duplicados encontrados: ${duplicateIds.length}',
        data: {'duplicate_ids': duplicateIds},
      );

  factory PlantTaskAlert.orphanTasks(List<PlantTask> orphanTasks) =>
      PlantTaskAlert(
        type: 'orphan_tasks',
        severity: 'medium',
        message: '${orphanTasks.length} tasks órfãs (sem planta)',
        data: {'orphan_count': orphanTasks.length},
      );

  factory PlantTaskAlert.lowHealthScore(double healthScore) => PlantTaskAlert(
    type: 'low_health_score',
    severity: healthScore < 50 ? 'critical' : 'high',
    message: 'Score de saúde baixo: ${healthScore.toStringAsFixed(1)}/100',
    data: {'health_score': healthScore},
  );
}

/// Diagnóstico completo do sistema
class PlantTaskSystemDiagnostic {
  final DateTime timestamp;
  final PlantTaskBatchValidationResult validation;
  final PlantTaskHealthReport healthReport;
  final List<PlantTaskEvent> recentEvents;
  final List<PlantTaskAlert> recentAlerts;
  final Map<String, dynamic> systemMetrics;
  final bool isHealthy;

  const PlantTaskSystemDiagnostic({
    required this.timestamp,
    required this.validation,
    required this.healthReport,
    required this.recentEvents,
    required this.recentAlerts,
    required this.systemMetrics,
    required this.isHealthy,
  });

  String generateReport() {
    final criticalAlerts = recentAlerts
        .where((a) => a.severity == 'critical')
        .length;
    final highAlerts = recentAlerts.where((a) => a.severity == 'high').length;

    return '''
🔍 Plant Task System Diagnostic Report
Generated: ${timestamp.toIso8601String()}

🎯 Overall Status: ${isHealthy ? '✅ HEALTHY' : '⚠️ NEEDS ATTENTION'}

${healthReport.generateSummary()}

🚨 Recent Alerts (${recentAlerts.length} total):
- Critical: $criticalAlerts
- High: $highAlerts
- Medium: ${recentAlerts.where((a) => a.severity == 'medium').length}
- Low: ${recentAlerts.where((a) => a.severity == 'low').length}

📊 System Metrics:
- Tasks created: ${systemMetrics['tasks_created_total'] ?? 0}
- Tasks completed: ${systemMetrics['tasks_completed_total'] ?? 0}
- Sync operations: ${systemMetrics['sync_success_total'] ?? 0} success, ${systemMetrics['sync_failures_total'] ?? 0} failures
- Validation runs: ${systemMetrics['validation_runs_total'] ?? 0}

🔍 Validation Details:
- Duplicate IDs: ${validation.duplicateIds.length}
- Orphan tasks: ${validation.orphanTasks.length}
- Inconsistent intervals: ${validation.inconsistentIntervals.length}

${isHealthy ? '✅ No action required' : '⚠️ Review alerts and validation issues'}
''';
  }
}
