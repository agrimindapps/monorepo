import 'package:firebase_messaging/firebase_messaging.dart';

/// Tipos de notificações promocionais do ReceitaAgro
enum NotificationType {
  promotional('promotional'),
  premium('premium'),
  newFeature('new_feature'),
  general('general');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

/// Modelo para notificações promocionais estruturadas
class PromotionalNotification {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String? imageUrl;
  final String? targetScreen;
  final String? deepLink;
  final Map<String, dynamic> data;
  final DateTime? scheduledTime;
  final bool isScheduled;

  const PromotionalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.channelId,
    required this.channelName,
    required this.channelDescription,
    this.imageUrl,
    this.targetScreen,
    this.deepLink,
    this.data = const {},
    this.scheduledTime,
    this.isScheduled = false,
  });

  /// Cria uma notificação promocional a partir de RemoteMessage do Firebase
  factory PromotionalNotification.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    
    return PromotionalNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: notification?.title ?? (data['title'] as String?) ?? 'ReceitaAgro',
      body: notification?.body ?? (data['body'] as String?) ?? '',
      type: NotificationType.fromString((data['type'] as String?) ?? 'general'),
      channelId: (data['channel_id'] as String?) ?? 'receituagro_promotional',
      channelName: (data['channel_name'] as String?) ?? 'Ofertas e Promoções',
      channelDescription: (data['channel_description'] as String?) ?? 'Notificações promocionais',
      imageUrl: notification?.android?.imageUrl ?? (data['image_url'] as String?),
      targetScreen: data['target_screen'] as String?,
      deepLink: data['deep_link'] as String?,
      data: Map<String, dynamic>.from(data),
    );
  }

  /// Cria uma notificação promocional a partir de JSON
  factory PromotionalNotification.fromJson(Map<String, dynamic> json) {
    return PromotionalNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String),
      channelId: json['channel_id'] as String,
      channelName: json['channel_name'] as String,
      channelDescription: json['channel_description'] as String,
      imageUrl: json['image_url'] as String?,
      targetScreen: json['target_screen'] as String?,
      deepLink: json['deep_link'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      scheduledTime: json['scheduled_time'] != null 
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      isScheduled: json['is_scheduled'] as bool? ?? false,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
      'channel_id': channelId,
      'channel_name': channelName,
      'channel_description': channelDescription,
      'image_url': imageUrl,
      'target_screen': targetScreen,
      'deep_link': deepLink,
      'data': data,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'is_scheduled': isScheduled,
    };
  }

  /// Copia a notificação com novos valores
  PromotionalNotification copyWith({
    int? id,
    String? title,
    String? body,
    NotificationType? type,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? imageUrl,
    String? targetScreen,
    String? deepLink,
    Map<String, dynamic>? data,
    DateTime? scheduledTime,
    bool? isScheduled,
  }) {
    return PromotionalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      imageUrl: imageUrl ?? this.imageUrl,
      targetScreen: targetScreen ?? this.targetScreen,
      deepLink: deepLink ?? this.deepLink,
      data: data ?? this.data,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isScheduled: isScheduled ?? this.isScheduled,
    );
  }

  @override
  String toString() {
    return 'PromotionalNotification('
        'id: $id, '
        'title: $title, '
        'type: ${type.value}, '
        'targetScreen: $targetScreen'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromotionalNotification &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, body, type);
  }
}

/// Templates pré-definidos para notificações promocionais
mixin PromotionalNotificationTemplates {
  static const Map<String, PromotionalNotification> templates = {
    'premium_offer': PromotionalNotification(
      id: 1,
      title: '✨ ReceitaAgro Premium',
      body: 'Desbloqueie todos os recursos por apenas R\$ 9,90/mês!',
      type: NotificationType.premium,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Ofertas especiais do ReceitaAgro Premium',
      targetScreen: 'subscription',
      data: {'promotion_type': 'premium_monthly'},
    ),
    
    'new_defensivos': PromotionalNotification(
      id: 2,
      title: '🌱 Novos Defensivos Disponíveis',
      body: 'Confira os últimos defensivos adicionados ao nosso banco de dados!',
      type: NotificationType.newFeature,
      channelId: 'receituagro_news',
      channelName: 'Novidades do App',
      channelDescription: 'Novos conteúdos e recursos',
      targetScreen: 'defensivos',
      data: {'feature_type': 'new_content'},
    ),
    
    'pest_season_alert': PromotionalNotification(
      id: 3,
      title: '🐛 Alerta de Temporada',
      body: 'Época de maior incidência de pragas. Proteja sua plantação!',
      type: NotificationType.promotional,
      channelId: 'receituagro_promotional',
      channelName: 'Ofertas e Promoções',
      channelDescription: 'Alertas sazonais e dicas',
      targetScreen: 'pragas',
      data: {'alert_type': 'seasonal'},
    ),
    
    'diagnostic_feature': PromotionalNotification(
      id: 4,
      title: '🔍 Nova Funcionalidade',
      body: 'Agora você pode fazer diagnósticos mais precisos com nossa IA!',
      type: NotificationType.newFeature,
      channelId: 'receituagro_news',
      channelName: 'Novidades do App',
      channelDescription: 'Novas funcionalidades disponíveis',
      targetScreen: 'diagnosticos',
      data: {'feature_type': 'ai_diagnostic'},
    ),
  };

  /// Obtém template por nome
  static PromotionalNotification? getTemplate(String name) {
    return templates[name];
  }

  /// Lista todos os templates disponíveis
  static List<String> get availableTemplates => templates.keys.toList();

  /// Cria uma notificação personalizada baseada em template
  static PromotionalNotification createFromTemplate(
    String templateName, {
    Map<String, dynamic>? customData,
    String? customTitle,
    String? customBody,
  }) {
    final template = templates[templateName];
    if (template == null) {
      throw ArgumentError('Template "$templateName" not found');
    }

    return template.copyWith(
      title: customTitle ?? template.title,
      body: customBody ?? template.body,
      data: {...template.data, ...?customData},
      id: DateTime.now().millisecondsSinceEpoch, // ID único
    );
  }
}
