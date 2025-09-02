/// Interface para gerenciamento de notificações de plantas
/// Segue o princípio ISP - Interface Segregation Principle
abstract class IPlantNotificationManager {
  /// Mostra notificação instantânea de nova planta adicionada
  Future<void> showNewPlantNotification({
    required String plantName,
    required String plantType,
  });

  /// Programa lembretes diários de cuidados para todas as plantas
  Future<void> scheduleDailyCareReminders();
}