import '../entities/notification_entity.dart';

/// Interface para repositório de notificações locais
abstract class INotificationRepository {
  /// Inicializa o sistema de notificações
  ///
  /// [defaultChannels] - Lista de canais padrão para criar na inicialização
  ///
  /// Retorna [true] se inicializado com sucesso
  Future<bool> initialize({List<NotificationChannelEntity>? defaultChannels});

  /// Verifica se as notificações estão habilitadas
  Future<NotificationPermissionEntity> getPermissionStatus();

  /// Solicita permissão para notificações
  Future<NotificationPermissionEntity> requestPermission();

  /// Abre as configurações de notificação do sistema
  Future<bool> openNotificationSettings();

  /// Cria um novo canal de notificação (Android)
  ///

  Future<bool> createNotificationChannel(NotificationChannelEntity channel);

  /// Remove um canal de notificação (Android)
  ///

  Future<bool> deleteNotificationChannel(String channelId);

  /// Lista todos os canais de notificação criados (Android)
  ///
  /// No iOS, retorna lista vazia
  Future<List<NotificationChannelEntity>> getNotificationChannels();

  /// Mostra uma notificação imediata
  Future<bool> showNotification(NotificationEntity notification);

  /// Agenda uma notificação para data/hora específica
  Future<bool> scheduleNotification(NotificationEntity notification);

  /// Agenda uma notificação recorrente
  ///
  /// [repeatInterval] - Intervalo de repetição
  Future<bool> schedulePeriodicNotification(
    NotificationEntity notification,
    Duration repeatInterval,
  );

  /// Cancela uma notificação específica
  Future<bool> cancelNotification(int notificationId);

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications();

  /// Lista todas as notificações agendadas
  Future<List<PendingNotificationEntity>> getPendingNotifications();

  /// Lista notificações ativas (mostradas na barra de notificação)
  Future<List<PendingNotificationEntity>> getActiveNotifications();

  /// Define callback para quando uma notificação for tocada
  void setNotificationTapCallback(Function(String? payload) callback);

  /// Define callback para quando uma ação de notificação for executada
  void setNotificationActionCallback(
    Function(String actionId, String? payload) callback,
  );

  /// Verifica se uma notificação específica está agendada
  Future<bool> isNotificationScheduled(int notificationId);

  /// Cria um ID único para notificação baseado em string
  int generateNotificationId(String identifier);

  /// Converte uma data/hora para timestamp Unix (usado internamente)
  int dateTimeToTimestamp(DateTime dateTime);

  /// Converte timestamp Unix para DateTime (usado internamente)
  DateTime timestampToDateTime(int timestamp);

  /// Verifica se o dispositivo suporta notificações exatas (Android 12+)
  Future<bool> canScheduleExactNotifications();

  /// Solicita permissão para agendar notificações exatas (Android 12+)
  Future<bool> requestExactNotificationPermission();
}

/// Callback executado quando uma notificação é tocada
typedef NotificationTapCallback = void Function(String? payload);

/// Callback executado quando uma ação de notificação é executada
typedef NotificationActionCallback =
    void Function(String actionId, String? payload);

/// Configurações globais para notificações
class NotificationSettings {
  const NotificationSettings({
    this.defaultIcon = '@mipmap/ic_launcher',
    this.defaultColor,
    this.enableDebugLogs = false,
    this.autoCancel = true,
    this.showBadge = true,
  });

  /// Ícone padrão das notificações
  final String defaultIcon;

  /// Cor padrão das notificações (Android)
  final int? defaultColor;

  /// Se deve mostrar logs de debug
  final bool enableDebugLogs;

  /// Se deve cancelar automaticamente ao tocar
  final bool autoCancel;

  /// Se deve mostrar badge no ícone do app
  final bool showBadge;
}
