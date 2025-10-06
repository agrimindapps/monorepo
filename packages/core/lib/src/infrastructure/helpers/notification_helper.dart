import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

/// Helper para inicialização do sistema de notificações
class NotificationHelper {
  static bool _isInitialized = false;

  /// Inicializa o sistema de timezone (necessário para notificações agendadas)
  static Future<void> initializeTimeZone() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('✅ Timezone initialized for notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing timezone: $e');
      }
    }
  }

  /// Retorna canais de notificação padrão para um app
  /// 
  /// [appName] - Nome do app para identificar os canais
  /// [primaryColor] - Cor primária do app (formato 0xAARRGGBB)
  static List<NotificationChannelEntity> getDefaultChannels({
    required String appName,
    required int primaryColor,
  }) {
    final lowercaseAppName = appName.toLowerCase();
    
    return [
      NotificationChannelEntity(
        id: '${lowercaseAppName}_general',
        name: '$appName - Geral',
        description: 'Notificações gerais do $appName',
        importance: NotificationImportanceEntity.defaultImportance,
        showBadge: true,
        enableSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      NotificationChannelEntity(
        id: '${lowercaseAppName}_reminders',
        name: '$appName - Lembretes',
        description: 'Lembretes e tarefas do $appName',
        importance: NotificationImportanceEntity.high,
        showBadge: true,
        enableSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      NotificationChannelEntity(
        id: '${lowercaseAppName}_alerts',
        name: '$appName - Alertas',
        description: 'Alertas importantes do $appName',
        importance: NotificationImportanceEntity.high,
        showBadge: true,
        enableSound: true,
        enableVibration: true,
        enableLights: true,
      ),
      NotificationChannelEntity(
        id: '${lowercaseAppName}_promotions',
        name: '$appName - Promoções',
        description: 'Ofertas e promoções do $appName',
        importance: NotificationImportanceEntity.low,
        showBadge: false,
        enableSound: false,
        enableVibration: false,
        enableLights: false,
      ),
    ];
  }

  /// Cria uma notificação de lembrete padrão
  static NotificationEntity createReminderNotification({
    required String appName,
    required int id,
    required String title,
    required String body,
    DateTime? scheduledDate,
    String? payload,
    int? color,
  }) {
    final lowercaseAppName = appName.toLowerCase();
    
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: '${lowercaseAppName}_reminders',
      channelName: '$appName - Lembretes',
      channelDescription: 'Lembretes e tarefas do $appName',
      scheduledDate: scheduledDate,
      type: scheduledDate != null 
          ? NotificationTypeEntity.scheduled 
          : NotificationTypeEntity.instant,
      priority: NotificationPriorityEntity.high,
      importance: NotificationImportanceEntity.high,
      color: color,
      autoCancel: true,
      ongoing: false,
      silent: false,
      showBadge: true,
    );
  }

  /// Cria uma notificação de alerta padrão
  static NotificationEntity createAlertNotification({
    required String appName,
    required int id,
    required String title,
    required String body,
    String? payload,
    int? color,
  }) {
    final lowercaseAppName = appName.toLowerCase();
    
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: '${lowercaseAppName}_alerts',
      channelName: '$appName - Alertas',
      channelDescription: 'Alertas importantes do $appName',
      type: NotificationTypeEntity.instant,
      priority: NotificationPriorityEntity.max,
      importance: NotificationImportanceEntity.max,
      color: color,
      autoCancel: true,
      ongoing: false,
      silent: false,
      showBadge: true,
    );
  }

  /// Cria uma notificação promocional padrão
  static NotificationEntity createPromotionNotification({
    required String appName,
    required int id,
    required String title,
    required String body,
    String? payload,
    int? color,
  }) {
    final lowercaseAppName = appName.toLowerCase();
    
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: '${lowercaseAppName}_promotions',
      channelName: '$appName - Promoções',
      channelDescription: 'Ofertas e promoções do $appName',
      type: NotificationTypeEntity.instant,
      priority: NotificationPriorityEntity.low,
      importance: NotificationImportanceEntity.low,
      color: color,
      autoCancel: true,
      ongoing: false,
      silent: true,
      showBadge: false,
    );
  }

  /// Cria configurações padrão para notificações
  static NotificationSettings createDefaultSettings({
    String? defaultIcon,
    int? defaultColor,
    bool enableDebugLogs = kDebugMode,
  }) {
    return NotificationSettings(
      defaultIcon: defaultIcon ?? '@mipmap/ic_launcher',
      defaultColor: defaultColor,
      enableDebugLogs: enableDebugLogs,
      autoCancel: true,
      showBadge: true,
    );
  }

  /// Valida se uma data/hora é válida para agendamento
  static bool isValidScheduleDate(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now.add(const Duration(minutes: 1)));
  }

  /// Calcula próxima data baseada em intervalo
  static DateTime calculateNextSchedule(DateTime baseDate, Duration interval) {
    DateTime nextDate = baseDate.add(interval);
    while (nextDate.isBefore(DateTime.now())) {
      nextDate = nextDate.add(interval);
    }
    
    return nextDate;
  }

  /// Converte cor em formato Flutter para int
  static int colorToInt(Color color) {
    return color.value;
  }

  /// Converte int para cor Flutter
  static Color intToColor(int colorValue) {
    return Color(colorValue);
  }
}
