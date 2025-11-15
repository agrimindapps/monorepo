import '../notification_permission_status.dart';

/// Interface for notification permission management operations
/// Responsibility: Solicitar e gerenciar permissões multiplataforma
abstract class IPermissionManager {
  /// Request notification permissions from the user
  Future<bool> requestNotificationPermissions();

  /// Get current permission status
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Open system notification settings
  Future<bool> openNotificationSettings();
}
