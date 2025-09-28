/// Interface para gerenciamento de permissões de notificação
/// Segue o princípio ISP - Interface Segregation Principle
abstract class INotificationPermissionManager {
  /// Verifica se as notificações estão habilitadas no sistema
  Future<bool> areNotificationsEnabled();

  /// Solicita permissão ao usuário para enviar notificações
  Future<bool> requestPermissions();

  /// Abre as configurações de notificação do sistema
  Future<bool> openNotificationSettings();
}
