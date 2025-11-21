import 'package:injectable/injectable.dart';

/// Serviço para formatação de dados de monitoramento
///
/// **Responsabilidade:** Single Responsibility Principle (SOLID)
/// - Centraliza toda lógica de formatação de tempo e métricas
/// - Facilita testes unitários
/// - Reutilizável em toda a feature de monitoring
@lazySingleton
class MonitoringFormatterService {
  /// Formata timestamp relativo (ex: "2min atrás", "3h atrás")
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'agora';
    }
  }

  /// Formata chave de métrica (ex: "memory_usage" -> "Memory Usage")
  String formatMetricKey(String key) {
    return key
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  /// Formata valor de métrica com unidade apropriada
  String formatMetricValue(dynamic value, {String? unit}) {
    if (value is double) {
      return unit != null
          ? '${value.toStringAsFixed(2)} $unit'
          : value.toStringAsFixed(2);
    } else if (value is int) {
      return unit != null ? '$value $unit' : value.toString();
    }
    return value.toString();
  }

  /// Formata porcentagem
  String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  /// Formata timestamp absoluto (ex: "30/10/2025 14:30")
  String formatAbsoluteTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Formata duração (ex: "2h 30min")
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
