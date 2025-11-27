import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Service for managing water reminder notifications
class WaterNotificationService {
  static final WaterNotificationService _instance =
      WaterNotificationService._internal();

  factory WaterNotificationService() => _instance;

  WaterNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Notification channel ID for water reminders
  static const String _channelId = 'water_reminder_channel';
  static const String _channelName = 'Lembretes de Hidratação';
  static const String _channelDescription =
      'Notificações para lembrar de beber água';

  /// Notification IDs
  static const int _baseNotificationId = 1000;
  static const int _adaptiveNotificationId = 2000;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }

    _isInitialized = true;
    debugPrint('✅ WaterNotificationService initialized');
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    debugPrint('iOS notification received: $title');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - can navigate to water tracker page
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Schedule recurring water reminders
  Future<void> scheduleWaterReminders({
    required int intervalMinutes,
    required String startTime,
    required String endTime,
  }) async {
    // Cancel existing reminders first
    await cancelAllReminders();

    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    // Calculate number of reminders
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final totalMinutes = endMinutes - startMinutes;

    if (totalMinutes <= 0) return;

    final numberOfReminders = totalMinutes ~/ intervalMinutes;

    // Schedule reminders
    for (int i = 0; i <= numberOfReminders; i++) {
      final reminderMinutes = startMinutes + (i * intervalMinutes);
      if (reminderMinutes > endMinutes) break;

      final hour = reminderMinutes ~/ 60;
      final minute = reminderMinutes % 60;

      await _scheduleDailyReminder(
        id: _baseNotificationId + i,
        hour: hour,
        minute: minute,
        title: _getRandomTitle(),
        body: _getRandomBody(),
      );
    }

    debugPrint('✅ Scheduled $numberOfReminders water reminders');
  }

  /// Schedule a single daily reminder at specific time
  Future<void> _scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(body),
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: 'water_reminder',
    );
  }

  /// Schedule an adaptive reminder (e.g., if user hasn't logged water in X hours)
  Future<void> scheduleAdaptiveReminder({
    required DateTime lastRecordTime,
    required int thresholdMinutes,
  }) async {
    final reminderTime = lastRecordTime.add(Duration(minutes: thresholdMinutes));

    // Only schedule if reminder time is in the future
    if (reminderTime.isBefore(DateTime.now())) return;

    // Cancel previous adaptive reminder
    await _notifications.cancel(_adaptiveNotificationId);

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    await _notifications.zonedSchedule(
      _adaptiveNotificationId,
      '💧 Hora de se hidratar!',
      'Você não bebe água há ${thresholdMinutes ~/ 60} horas. Que tal um copo agora?',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'adaptive_water_reminder',
    );

    debugPrint('✅ Adaptive reminder scheduled for $reminderTime');
  }

  /// Cancel all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ All water reminders cancelled');
  }

  /// Cancel only recurring reminders (keep adaptive)
  Future<void> cancelRecurringReminders() async {
    for (int i = 0; i < 50; i++) {
      await _notifications.cancel(_baseNotificationId + i);
    }
    debugPrint('🗑️ Recurring reminders cancelled');
  }

  /// Show an immediate notification (for testing or special events)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      999,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'immediate_notification',
    );
  }

  /// Show goal achieved notification
  Future<void> showGoalAchievedNotification() async {
    await _notifications.show(
      998,
      '🎉 Meta Atingida!',
      'Parabéns! Você atingiu sua meta de hidratação hoje. Continue assim!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.social,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'goal_achieved',
    );
  }

  /// Show streak notification
  Future<void> showStreakNotification(int streakDays) async {
    String title;
    String body;

    if (streakDays == 7) {
      title = '🔥 1 Semana de Hidratação!';
      body = 'Você manteve sua hidratação por 7 dias seguidos. Incrível!';
    } else if (streakDays == 30) {
      title = '🏆 1 Mês Hidratado!';
      body = 'Um mês inteiro bebendo água suficiente. Você é um campeão!';
    } else if (streakDays % 10 == 0) {
      title = '⭐ $streakDays dias de sequência!';
      body = 'Continue assim, sua saúde agradece!';
    } else {
      return; // Don't show for other streak values
    }

    await _notifications.show(
      997,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          category: AndroidNotificationCategory.social,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'streak_$streakDays',
    );
  }

  // Random notification titles for variety
  String _getRandomTitle() {
    final titles = [
      '💧 Hora de beber água!',
      '🚰 Mantenha-se hidratado!',
      '💦 Que tal um copo de água?',
      '🌊 Lembre-se de se hidratar!',
      '💧 Seu corpo precisa de água!',
    ];
    return titles[DateTime.now().minute % titles.length];
  }

  // Random notification bodies for variety
  String _getRandomBody() {
    final bodies = [
      'A hidratação é essencial para sua saúde e bem-estar.',
      'Beber água ajuda na concentração e energia.',
      'Manter-se hidratado melhora a pele e o metabolismo.',
      'Um copo de água pode fazer toda a diferença!',
      'Sua meta de hidratação está te esperando!',
    ];
    return bodies[DateTime.now().second % bodies.length];
  }

  /// Check pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
