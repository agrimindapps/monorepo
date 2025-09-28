import 'dart:convert';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Configuração específica de notificações para o Plantis
class PlantisNotificationConfig {
  static const int _primaryColor = 0xFF4CAF50; // Verde plantas

  /// Canais de notificação específicos do Plantis
  static final List<NotificationChannelEntity> plantisChannels = [
    const NotificationChannelEntity(
      id: 'plantis_watering',
      name: 'Lembretes de Rega',
      description: 'Notificações para lembrar de regar suas plantas',
      importance: NotificationImportanceEntity.high,
      showBadge: true,
      enableLights: true,
      enableVibration: true,
    ),
    const NotificationChannelEntity(
      id: 'plantis_fertilizing',
      name: 'Lembretes de Adubação',
      description: 'Notificações para lembrar de adubar suas plantas',
      importance: NotificationImportanceEntity.high,
      showBadge: true,
      enableLights: true,
      enableVibration: true,
    ),
    const NotificationChannelEntity(
      id: 'plantis_pruning',
      name: 'Lembretes de Poda',
      description: 'Notificações para lembrar de podar suas plantas',
      importance: NotificationImportanceEntity.defaultImportance,
      showBadge: true,
      enableLights: false,
      enableVibration: true,
    ),
    const NotificationChannelEntity(
      id: 'plantis_pest_inspection',
      name: 'Inspeção de Pragas',
      description: 'Lembretes para verificar pragas nas plantas',
      importance: NotificationImportanceEntity.defaultImportance,
      showBadge: true,
      enableLights: false,
      enableVibration: false,
    ),
    const NotificationChannelEntity(
      id: 'plantis_general',
      name: 'Notificações Gerais',
      description: 'Outras notificações do Plantis',
      importance: NotificationImportanceEntity.defaultImportance,
      showBadge: true,
      enableLights: false,
      enableVibration: false,
    ),
    const NotificationChannelEntity(
      id: 'plantis_sync',
      name: 'Sincronização',
      description: 'Status de sincronização dos dados',
      importance: NotificationImportanceEntity.low,
      showBadge: false,
      enableLights: false,
      enableVibration: false,
    ),
  ];

  /// Configurações globais para o Plantis
  static const NotificationSettings plantisSettings = NotificationSettings(
    defaultIcon: '@mipmap/ic_launcher',
    defaultColor: _primaryColor,
    enableDebugLogs: kDebugMode,
    autoCancel: true,
    showBadge: true,
  );

  /// Mapeamento de tipos de cuidado para canais
  static const Map<String, String> careTypeToChannel = {
    'watering': 'plantis_watering',
    'fertilizing': 'plantis_fertilizing',
    'pruning': 'plantis_pruning',
    'pest_inspection': 'plantis_pest_inspection',
    'cleaning': 'plantis_general',
    'repotting': 'plantis_general',
    'general': 'plantis_general',
  };

  /// Obtém o canal apropriado para um tipo de cuidado
  static String getChannelForCareType(String careType) {
    return careTypeToChannel[careType] ?? 'plantis_general';
  }

  /// Cria uma notificação de cuidado de planta
  static NotificationEntity createPlantCareNotification({
    required int id,
    required String title,
    required String body,
    required String careType,
    required String plantId,
    required String plantName,
    DateTime? scheduledDate,
    Map<String, dynamic>? extraData,
  }) {
    final payload = {
      'type': 'plant_care',
      'careType': careType,
      'plantId': plantId,
      'plantName': plantName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?extraData,
    };

    return NotificationEntity(
      id: id,
      channelId: getChannelForCareType(careType),
      title: title,
      body: body,
      payload: jsonEncode(payload),
      scheduledDate: scheduledDate,
      priority: careType == 'watering' ? NotificationPriorityEntity.high : NotificationPriorityEntity.defaultPriority,
      actions: const [
        NotificationActionEntity(
          id: 'mark_done',
          title: 'Marcar como Feito',
        ),
        NotificationActionEntity(
          id: 'snooze',
          title: 'Lembrar em 1h',
        ),
      ],
    );
  }

  /// Cria uma notificação de sincronização
  static NotificationEntity createSyncNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? extraData,
  }) {
    final payload = {
      'type': 'sync',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?extraData,
    };

    return NotificationEntity(
      id: id,
      channelId: 'plantis_sync',
      title: title,
      body: body,
      payload: jsonEncode(payload),
      priority: NotificationPriorityEntity.low,
    );
  }

  /// Cria uma notificação geral do Plantis
  static NotificationEntity createGeneralNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? extraData,
  }) {
    final payload = {
      'type': 'general',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?extraData,
    };

    return NotificationEntity(
      id: id,
      channelId: 'plantis_general',
      title: title,
      body: body,
      payload: jsonEncode(payload),
      priority: NotificationPriorityEntity.defaultPriority,
    );
  }
}