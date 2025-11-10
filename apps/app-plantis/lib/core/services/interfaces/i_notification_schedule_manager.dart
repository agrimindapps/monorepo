import 'package:core/core.dart' hide Column;

/// Interface para gerenciamento de agendamento de notificações
/// Segue o princípio ISP - Interface Segregation Principle
abstract class INotificationScheduleManager {
  /// Cancela todas as notificações agendadas
  Future<bool> cancelAllNotifications();

  /// Lista todas as notificações pendentes no sistema
  Future<List<PendingNotificationEntity>> getPendingNotifications();

  /// Verifica se uma notificação específica está agendada
  Future<bool> isNotificationScheduled(String identifier);
}
