import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/analytics/advanced_health_monitoring_service.dart';

/// Serviço para mapear status de saúde para cores e ícones
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza mapeamento de status para elementos visuais
/// - Mantém consistência visual em toda a aplicação
/// - Facilita mudanças de tema e estilo
@lazySingleton
class MonitoringUIMapperService {
  /// Retorna cor baseada no status de saúde
  Color getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.warning:
        return Colors.orange;
      case HealthStatus.critical:
        return Colors.red;
      case HealthStatus.failed:
        return Colors.red[900]!;
    }
  }

  /// Retorna ícone baseado no status de saúde
  IconData getStatusIcon(HealthStatus status, {bool outlined = false}) {
    if (outlined) {
      switch (status) {
        case HealthStatus.healthy:
          return Icons.check_circle_outline;
        case HealthStatus.warning:
          return Icons.warning_outlined;
        case HealthStatus.critical:
          return Icons.error_outline;
        case HealthStatus.failed:
          return Icons.cancel_outlined;
      }
    }

    switch (status) {
      case HealthStatus.healthy:
        return Icons.check_circle;
      case HealthStatus.warning:
        return Icons.warning;
      case HealthStatus.critical:
        return Icons.error;
      case HealthStatus.failed:
        return Icons.cancel;
    }
  }

  /// Retorna texto descritivo do status
  String getStatusText(HealthStatus status) {
    switch (status) {
      case HealthStatus.healthy:
        return 'Sistema Saudável';
      case HealthStatus.warning:
        return 'Sistema com Avisos';
      case HealthStatus.critical:
        return 'Sistema Crítico';
      case HealthStatus.failed:
        return 'Sistema com Falhas';
    }
  }

  /// Retorna cor para nível de alerta
  Color getAlertLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Retorna ícone para nível de alerta
  IconData getAlertLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      case 'info':
        return Icons.info;
      default:
        return Icons.help;
    }
  }
}
