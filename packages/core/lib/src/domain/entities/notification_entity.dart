import 'package:equatable/equatable.dart';

/// Entidade que representa uma notificação local
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.channelId,
    this.channelName,
    this.channelDescription,
    this.scheduledDate,
    this.type = NotificationTypeEntity.instant,
    this.priority = NotificationPriorityEntity.defaultPriority,
    this.importance = NotificationImportanceEntity.defaultImportance,
    this.autoCancel = true,
    this.ongoing = false,
    this.silent = false,
    this.showBadge = true,
    this.color,
    this.icon,
    this.largeIcon,
    this.actions,
  });

  /// ID único da notificação
  final int id;
  
  /// Título da notificação
  final String title;
  
  /// Corpo/conteúdo da notificação
  final String body;
  
  /// Dados extras (JSON) enviados com a notificação
  final String? payload;
  
  /// ID do canal de notificação (Android)
  final String? channelId;
  
  /// Nome do canal de notificação (Android)
  final String? channelName;
  
  /// Descrição do canal de notificação (Android)
  final String? channelDescription;
  
  /// Data/hora para agendar a notificação (null = imediata)
  final DateTime? scheduledDate;
  
  /// Tipo da notificação
  final NotificationTypeEntity type;
  
  /// Prioridade da notificação
  final NotificationPriorityEntity priority;
  
  /// Importância da notificação (Android)
  final NotificationImportanceEntity importance;
  
  /// Se deve cancelar automaticamente ao ser tocada
  final bool autoCancel;
  
  /// Se é uma notificação contínua (não pode ser removida pelo usuário)
  final bool ongoing;
  
  /// Se deve ser silenciosa (sem som/vibração)
  final bool silent;
  
  /// Se deve mostrar badge no ícone do app
  final bool showBadge;
  
  /// Cor da notificação (Android)
  final int? color;
  
  /// Ícone pequeno da notificação
  final String? icon;
  
  /// Ícone grande da notificação
  final String? largeIcon;
  
  /// Ações disponíveis na notificação
  final List<NotificationActionEntity>? actions;

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        payload,
        channelId,
        channelName,
        channelDescription,
        scheduledDate,
        type,
        priority,
        importance,
        autoCancel,
        ongoing,
        silent,
        showBadge,
        color,
        icon,
        largeIcon,
        actions,
      ];

  /// Cria uma cópia da notificação com alguns campos alterados
  NotificationEntity copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    DateTime? scheduledDate,
    NotificationTypeEntity? type,
    NotificationPriorityEntity? priority,
    NotificationImportanceEntity? importance,
    bool? autoCancel,
    bool? ongoing,
    bool? silent,
    bool? showBadge,
    int? color,
    String? icon,
    String? largeIcon,
    List<NotificationActionEntity>? actions,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      importance: importance ?? this.importance,
      autoCancel: autoCancel ?? this.autoCancel,
      ongoing: ongoing ?? this.ongoing,
      silent: silent ?? this.silent,
      showBadge: showBadge ?? this.showBadge,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      largeIcon: largeIcon ?? this.largeIcon,
      actions: actions ?? this.actions,
    );
  }
}

/// Ação disponível em uma notificação
class NotificationActionEntity extends Equatable {
  const NotificationActionEntity({
    required this.id,
    required this.title,
    this.icon,
    this.contextual = false,
    this.destructive = false,
  });

  /// ID único da ação
  final String id;
  
  /// Título da ação
  final String title;
  
  /// Ícone da ação (Android)
  final String? icon;
  
  /// Se é uma ação contextual (iOS)
  final bool contextual;
  
  /// Se é uma ação destrutiva (iOS)
  final bool destructive;

  @override
  List<Object?> get props => [id, title, icon, contextual, destructive];
}

/// Canal de notificação
class NotificationChannelEntity extends Equatable {
  const NotificationChannelEntity({
    required this.id,
    required this.name,
    this.description,
    this.importance = NotificationImportanceEntity.defaultImportance,
    this.showBadge = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableLights = true,
    this.groupId,
  });

  /// ID único do canal
  final String id;
  
  /// Nome do canal
  final String name;
  
  /// Descrição do canal
  final String? description;
  
  /// Importância do canal
  final NotificationImportanceEntity importance;
  
  /// Se deve mostrar badge
  final bool showBadge;
  
  /// Se deve reproduzir som
  final bool enableSound;
  
  /// Se deve vibrar
  final bool enableVibration;
  
  /// Se deve acender LED (Android)
  final bool enableLights;
  
  /// ID do grupo do canal (Android)
  final String? groupId;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        importance,
        showBadge,
        enableSound,
        enableVibration,
        enableLights,
        groupId,
      ];
}

/// Tipos de notificação
enum NotificationTypeEntity {
  /// Notificação imediata
  instant,
  
  /// Notificação agendada para data/hora específica
  scheduled,
  
  /// Notificação recorrente
  recurring,
  
  /// Notificação baseada em localização
  location,
}

/// Prioridades de notificação
enum NotificationPriorityEntity {
  /// Prioridade mínima
  min,
  
  /// Prioridade baixa
  low,
  
  /// Prioridade padrão
  defaultPriority,
  
  /// Prioridade alta
  high,
  
  /// Prioridade máxima
  max,
}

/// Importância da notificação (Android)
enum NotificationImportanceEntity {
  /// Sem importância
  none,
  
  /// Importância mínima
  min,
  
  /// Importância baixa
  low,
  
  /// Importância padrão
  defaultImportance,
  
  /// Importância alta
  high,
  
  /// Importância máxima
  max,
}

/// Configurações de permissão de notificação
class NotificationPermissionEntity extends Equatable {
  const NotificationPermissionEntity({
    required this.isGranted,
    required this.canShowAlerts,
    required this.canShowBadges,
    required this.canPlaySounds,
    required this.canScheduleExactAlarms,
    this.shouldShowRationale = false,
    this.isPermanentlyDenied = false,
  });

  /// Se a permissão foi concedida
  final bool isGranted;
  
  /// Se pode mostrar alertas
  final bool canShowAlerts;
  
  /// Se pode mostrar badges
  final bool canShowBadges;
  
  /// Se pode reproduzir sons
  final bool canPlaySounds;
  
  /// Se pode agendar alarmes exatos (Android 12+)
  final bool canScheduleExactAlarms;
  
  /// Se deve mostrar explicação sobre a permissão
  final bool shouldShowRationale;
  
  /// Se a permissão foi permanentemente negada
  final bool isPermanentlyDenied;

  @override
  List<Object?> get props => [
        isGranted,
        canShowAlerts,
        canShowBadges,
        canPlaySounds,
        canScheduleExactAlarms,
        shouldShowRationale,
        isPermanentlyDenied,
      ];
}

/// Estado da notificação agendada
class PendingNotificationEntity extends Equatable {
  const PendingNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  /// ID da notificação
  final int id;
  
  /// Título da notificação
  final String title;
  
  /// Corpo da notificação
  final String body;
  
  /// Payload da notificação
  final String? payload;

  @override
  List<Object?> get props => [id, title, body, payload];
}
