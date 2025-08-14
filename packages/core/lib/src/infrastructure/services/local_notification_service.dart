import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';

/// Implementação do serviço de notificações locais usando flutter_local_notifications
class LocalNotificationService implements INotificationRepository {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  NotificationTapCallback? _onNotificationTap;
  NotificationActionCallback? _onNotificationAction;
  NotificationSettings _settings = const NotificationSettings();
  
  bool _isInitialized = false;

  /// Configura as configurações globais
  void configure(NotificationSettings settings) {
    _settings = settings;
  }

  @override
  Future<bool> initialize({List<NotificationChannelEntity>? defaultChannels}) async {
    if (_isInitialized) return true;

    try {
      // Configurações de inicialização para Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configurações de inicialização para iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
      );

      // Configurações de inicialização para macOS
      const DarwinInitializationSettings macosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      );

      final bool? result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Criar canais padrão para Android
      if (Platform.isAndroid && defaultChannels != null) {
        for (final channel in defaultChannels) {
          await createNotificationChannel(channel);
        }
      }

      _isInitialized = result ?? false;
      
      if (_settings.enableDebugLogs) {
        debugPrint('🔔 NotificationService initialized: $_isInitialized');
      }

      return _isInitialized;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error initializing notifications: $e');
      }
      return false;
    }
  }

  @override
  Future<NotificationPermissionEntity> getPermissionStatus() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        final canScheduleExact = await canScheduleExactNotifications();
        
        return NotificationPermissionEntity(
          isGranted: status.isGranted,
          canShowAlerts: status.isGranted,
          canShowBadges: status.isGranted,
          canPlaySounds: status.isGranted,
          canScheduleExactAlarms: canScheduleExact,
          shouldShowRationale: status.isPermanentlyDenied,
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      } else if (Platform.isIOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        return NotificationPermissionEntity(
          isGranted: granted ?? false,
          canShowAlerts: granted ?? false,
          canShowBadges: granted ?? false,
          canPlaySounds: granted ?? false,
          canScheduleExactAlarms: true, // iOS não tem essa limitação
        );
      }

      return const NotificationPermissionEntity(
        isGranted: false,
        canShowAlerts: false,
        canShowBadges: false,
        canPlaySounds: false,
        canScheduleExactAlarms: false,
      );
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error getting permission status: $e');
      }
      return const NotificationPermissionEntity(
        isGranted: false,
        canShowAlerts: false,
        canShowBadges: false,
        canPlaySounds: false,
        canScheduleExactAlarms: false,
      );
    }
  }

  @override
  Future<NotificationPermissionEntity> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        final canScheduleExact = await canScheduleExactNotifications();
        
        return NotificationPermissionEntity(
          isGranted: status.isGranted,
          canShowAlerts: status.isGranted,
          canShowBadges: status.isGranted,
          canPlaySounds: status.isGranted,
          canScheduleExactAlarms: canScheduleExact,
          shouldShowRationale: status.isPermanentlyDenied,
          isPermanentlyDenied: status.isPermanentlyDenied,
        );
      } else if (Platform.isIOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        return NotificationPermissionEntity(
          isGranted: granted ?? false,
          canShowAlerts: granted ?? false,
          canShowBadges: granted ?? false,
          canPlaySounds: granted ?? false,
          canScheduleExactAlarms: true,
        );
      }

      return const NotificationPermissionEntity(
        isGranted: false,
        canShowAlerts: false,
        canShowBadges: false,
        canPlaySounds: false,
        canScheduleExactAlarms: false,
      );
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error requesting permission: $e');
      }
      return const NotificationPermissionEntity(
        isGranted: false,
        canShowAlerts: false,
        canShowBadges: false,
        canPlaySounds: false,
        canScheduleExactAlarms: false,
      );
    }
  }

  @override
  Future<bool> openNotificationSettings() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.request().then((status) {
          if (status.isPermanentlyDenied) {
            return openAppSettings();
          }
          return status.isGranted;
        });
      } else if (Platform.isIOS) {
        return await openAppSettings();
      }
      return false;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error opening notification settings: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> createNotificationChannel(NotificationChannelEntity channel) async {
    if (!Platform.isAndroid) return true;

    try {
      final androidChannel = AndroidNotificationChannel(
        channel.id,
        channel.name,
        description: channel.description,
        importance: _mapImportance(channel.importance),
        showBadge: channel.showBadge,
        playSound: channel.enableSound,
        enableVibration: channel.enableVibration,
        enableLights: channel.enableLights,
        groupId: channel.groupId,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      if (_settings.enableDebugLogs) {
        debugPrint('✅ Created notification channel: ${channel.id}');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error creating notification channel: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> deleteNotificationChannel(String channelId) async {
    if (!Platform.isAndroid) return true;

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannel(channelId);

      if (_settings.enableDebugLogs) {
        debugPrint('🗑️ Deleted notification channel: $channelId');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error deleting notification channel: $e');
      }
      return false;
    }
  }

  @override
  Future<List<NotificationChannelEntity>> getNotificationChannels() async {
    if (!Platform.isAndroid) return [];

    try {
      final channels = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.getNotificationChannels();

      if (channels == null) return [];

      return channels.map((channel) => NotificationChannelEntity(
        id: channel.id,
        name: channel.name,
        description: channel.description,
        importance: _mapImportanceFromAndroid(channel.importance),
        showBadge: channel.showBadge,
        enableSound: channel.playSound,
        enableVibration: channel.enableVibration,
        enableLights: channel.enableLights,
        groupId: channel.groupId,
      )).toList();
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error getting notification channels: $e');
      }
      return [];
    }
  }

  @override
  Future<bool> showNotification(NotificationEntity notification) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        notification.channelId ?? 'default',
        notification.channelName ?? 'Default',
        channelDescription: notification.channelDescription,
        importance: _mapImportance(notification.importance),
        priority: _mapPriority(notification.priority),
        icon: notification.icon ?? _settings.defaultIcon,
        color: notification.color != null ? Color(notification.color!) : 
               (_settings.defaultColor != null ? Color(_settings.defaultColor!) : null),
        autoCancel: notification.autoCancel,
        ongoing: notification.ongoing,
        silent: notification.silent,
        channelShowBadge: notification.showBadge,
        largeIcon: notification.largeIcon != null ? DrawableResourceAndroidBitmap(notification.largeIcon!) : null,
        actions: notification.actions?.map((action) => AndroidNotificationAction(
          action.id,
          action.title,
          icon: action.icon != null ? DrawableResourceAndroidBitmap(action.icon!) : null,
        )).toList(),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: notification.showBadge,
        presentSound: !notification.silent,
        interruptionLevel: notification.priority == NotificationPriorityEntity.high 
            ? InterruptionLevel.timeSensitive 
            : InterruptionLevel.active,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notification.id,
        notification.title,
        notification.body,
        details,
        payload: notification.payload,
      );

      if (_settings.enableDebugLogs) {
        debugPrint('✅ Showed notification: ${notification.id} - ${notification.title}');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error showing notification: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> scheduleNotification(NotificationEntity notification) async {
    if (notification.scheduledDate == null) {
      return showNotification(notification);
    }

    try {
      final androidDetails = AndroidNotificationDetails(
        notification.channelId ?? 'default',
        notification.channelName ?? 'Default',
        channelDescription: notification.channelDescription,
        importance: _mapImportance(notification.importance),
        priority: _mapPriority(notification.priority),
        icon: notification.icon ?? _settings.defaultIcon,
        color: notification.color != null ? Color(notification.color!) : 
               (_settings.defaultColor != null ? Color(_settings.defaultColor!) : null),
        autoCancel: notification.autoCancel,
        ongoing: notification.ongoing,
        silent: notification.silent,
        channelShowBadge: notification.showBadge,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: notification.showBadge,
        presentSound: !notification.silent,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.scheduledDate!, tz.local),
        details,
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      if (_settings.enableDebugLogs) {
        debugPrint('📅 Scheduled notification: ${notification.id} for ${notification.scheduledDate}');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error scheduling notification: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> schedulePeriodicNotification(
    NotificationEntity notification,
    Duration repeatInterval,
  ) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        notification.channelId ?? 'default',
        notification.channelName ?? 'Default',
        channelDescription: notification.channelDescription,
        importance: _mapImportance(notification.importance),
        priority: _mapPriority(notification.priority),
        icon: notification.icon ?? _settings.defaultIcon,
        color: notification.color != null ? Color(notification.color!) : 
               (_settings.defaultColor != null ? Color(_settings.defaultColor!) : null),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: notification.showBadge,
        presentSound: !notification.silent,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final repeatIntervalMapping = _mapRepeatInterval(repeatInterval);
      
      await _notifications.periodicallyShow(
        notification.id,
        notification.title,
        notification.body,
        repeatIntervalMapping,
        details,
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      if (_settings.enableDebugLogs) {
        debugPrint('🔄 Scheduled periodic notification: ${notification.id} every $repeatInterval');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error scheduling periodic notification: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> cancelNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);

      if (_settings.enableDebugLogs) {
        debugPrint('🚫 Cancelled notification: $notificationId');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error cancelling notification: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();

      if (_settings.enableDebugLogs) {
        debugPrint('🚫 Cancelled all notifications');
      }

      return true;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error cancelling all notifications: $e');
      }
      return false;
    }
  }

  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    try {
      final pendingRequests = await _notifications.pendingNotificationRequests();

      return pendingRequests.map((request) => PendingNotificationEntity(
        id: request.id,
        title: request.title ?? '',
        body: request.body ?? '',
        payload: request.payload,
      )).toList();
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error getting pending notifications: $e');
      }
      return [];
    }
  }

  @override
  Future<List<PendingNotificationEntity>> getActiveNotifications() async {
    try {
      final activeNotifications = await _notifications.getActiveNotifications();

      return activeNotifications.map((notification) => PendingNotificationEntity(
        id: notification.id ?? 0,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: null,
      )).toList();
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error getting active notifications: $e');
      }
      return [];
    }
  }

  @override
  void setNotificationTapCallback(Function(String? payload) callback) {
    _onNotificationTap = callback;
  }

  @override
  void setNotificationActionCallback(Function(String actionId, String? payload) callback) {
    _onNotificationAction = callback;
  }

  @override
  Future<bool> isNotificationScheduled(int notificationId) async {
    final pending = await getPendingNotifications();
    return pending.any((notification) => notification.id == notificationId);
  }

  @override
  int generateNotificationId(String identifier) {
    return identifier.hashCode.abs() % 2147483647;
  }

  @override
  int dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  @override
  DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  @override
  Future<bool> canScheduleExactNotifications() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error checking exact notification permission: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> requestExactNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestExactAlarmsPermission() ?? false;
    } catch (e) {
      if (_settings.enableDebugLogs) {
        debugPrint('❌ Error requesting exact notification permission: $e');
      }
      return false;
    }
  }

  /// Manipula resposta de notificação (tap ou ação)
  void _handleNotificationResponse(NotificationResponse response) {
    if (_settings.enableDebugLogs) {
      debugPrint('🔔 Notification response: ${response.actionId} - ${response.payload}');
    }

    if (response.actionId != null) {
      // Ação específica foi executada
      _onNotificationAction?.call(response.actionId!, response.payload);
    } else {
      // Notificação foi tocada
      _onNotificationTap?.call(response.payload);
    }
  }

  /// Mapeia importância para Android
  Importance _mapImportance(NotificationImportanceEntity importance) {
    switch (importance) {
      case NotificationImportanceEntity.none:
        return Importance.none;
      case NotificationImportanceEntity.min:
        return Importance.min;
      case NotificationImportanceEntity.low:
        return Importance.low;
      case NotificationImportanceEntity.defaultImportance:
        return Importance.defaultImportance;
      case NotificationImportanceEntity.high:
        return Importance.high;
      case NotificationImportanceEntity.max:
        return Importance.max;
    }
  }

  /// Mapeia prioridade para Android
  Priority _mapPriority(NotificationPriorityEntity priority) {
    switch (priority) {
      case NotificationPriorityEntity.min:
        return Priority.min;
      case NotificationPriorityEntity.low:
        return Priority.low;
      case NotificationPriorityEntity.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriorityEntity.high:
        return Priority.high;
      case NotificationPriorityEntity.max:
        return Priority.max;
    }
  }

  /// Mapeia importância do Android para entidade
  NotificationImportanceEntity _mapImportanceFromAndroid(Importance importance) {
    switch (importance) {
      case Importance.unspecified:
        return NotificationImportanceEntity.defaultImportance; // Map unspecified to default
      case Importance.none:
        return NotificationImportanceEntity.none;
      case Importance.min:
        return NotificationImportanceEntity.min;
      case Importance.low:
        return NotificationImportanceEntity.low;
      case Importance.defaultImportance:
        return NotificationImportanceEntity.defaultImportance;
      case Importance.high:
        return NotificationImportanceEntity.high;
      case Importance.max:
        return NotificationImportanceEntity.max;
    }
  }

  /// Mapeia intervalo de repetição para RepeatInterval
  RepeatInterval _mapRepeatInterval(Duration duration) {
    if (duration.inMinutes <= 1) return RepeatInterval.everyMinute;
    if (duration.inHours <= 1) return RepeatInterval.hourly;
    if (duration.inDays <= 1) return RepeatInterval.daily;
    if (duration.inDays <= 7) return RepeatInterval.weekly;
    return RepeatInterval.daily; // fallback
  }
}