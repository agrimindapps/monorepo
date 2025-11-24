

import '../../../../core/analytics/advanced_health_monitoring_service.dart';

/// Modelo de alerta de monitoramento
class MonitoringAlert {
  final String name;
  final String level;
  final DateTime timestamp;
  final String message;

  const MonitoringAlert({
    required this.name,
    required this.level,
    required this.timestamp,
    required this.message,
  });
}

/// Serviço para gerenciar alertas de monitoramento
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Gerencia lógica de alertas do sistema
/// - Analisa relatórios e gera alertas
/// - Mantém histórico de alertas

class MonitoringAlertService {
  // Usa singleton instance ao invés de injeção para evitar problemas de DI
  AdvancedHealthMonitoringService get _healthService =>
      AdvancedHealthMonitoringService.instance;

  /// Gera alertas baseados no relatório de saúde atual
  List<MonitoringAlert> generateAlertsFromReport(SystemHealthReport report) {
    final alerts = <MonitoringAlert>[];

    // Verifica componentes críticos
    for (final component in report.componentResults) {
      if (component.status == HealthStatus.critical) {
        alerts.add(
          MonitoringAlert(
            name: 'Componente Crítico: ${component.component}',
            level: 'critical',
            timestamp: component.timestamp,
            message: component.message,
          ),
        );
      } else if (component.status == HealthStatus.warning) {
        alerts.add(
          MonitoringAlert(
            name: 'Aviso: ${component.component}',
            level: 'warning',
            timestamp: component.timestamp,
            message: component.message,
          ),
        );
      }
    }

    // Verifica métricas do sistema
    final metrics = report.systemMetrics;

    // Exemplo: Verifica uso de memória (se disponível)
    if (metrics.containsKey('memory_usage')) {
      final memoryUsage = metrics['memory_usage'];
      if (memoryUsage is num && memoryUsage > 0.85) {
        alerts.add(
          MonitoringAlert(
            name: 'Alto uso de memória',
            level: 'warning',
            timestamp: DateTime.now(),
            message:
                'Uso de memória em ${(memoryUsage * 100).toStringAsFixed(0)}%',
          ),
        );
      }
    }

    return alerts;
  }

  /// Obtém alertas recentes do histórico
  List<MonitoringAlert> getRecentAlerts({int limit = 10}) {
    final history = _healthService.getHealthHistory(limit: limit);
    final alerts = <MonitoringAlert>[];

    for (final report in history) {
      alerts.addAll(generateAlertsFromReport(report));
    }

    // Ordena por timestamp decrescente e limita
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts.take(limit).toList();
  }

  /// Conta alertas por nível
  Map<String, int> countAlertsByLevel(List<MonitoringAlert> alerts) {
    final counts = <String, int>{'critical': 0, 'warning': 0, 'info': 0};

    for (final alert in alerts) {
      counts[alert.level] = (counts[alert.level] ?? 0) + 1;
    }

    return counts;
  }

  /// Filtra alertas por nível
  List<MonitoringAlert> filterAlertsByLevel(
    List<MonitoringAlert> alerts,
    String level,
  ) {
    return alerts.where((alert) => alert.level == level).toList();
  }
}
