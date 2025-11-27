import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Service for managing weight tracker notifications
class WeightNotificationService {
  static final WeightNotificationService _instance =
      WeightNotificationService._internal();
  factory WeightNotificationService() => _instance;
  WeightNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderNotificationId = 2000;
  static const int _goalAchievedNotificationId = 2001;
  static const int _milestoneNotificationId = 2002;

  static const String _channelId = 'weight_tracker_channel';
  static const String _channelName = 'Rastreador de Peso';
  static const String _channelDescription = 'Notificações do rastreador de peso';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.defaultImportance,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to weight tracker
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule daily weight reminder
  Future<void> scheduleDailyReminder({
    required String time, // HH:mm format
    required String message,
  }) async {
    if (!_isInitialized) await initialize();

    // Cancel existing reminder
    await _notifications.cancel(_dailyReminderNotificationId);

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _dailyReminderNotificationId,
      '⚖️ Hora de se pesar!',
      message,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Show goal achieved notification
  Future<void> showGoalAchievedNotification() async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _goalAchievedNotificationId,
      '👑 Meta Atingida!',
      'Parabéns! Você atingiu seu peso meta! Continue mantendo seus hábitos saudáveis.',
      details,
    );
  }

  /// Show milestone achieved notification
  Future<void> showMilestoneNotification(String milestoneTitle) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _milestoneNotificationId,
      '🎯 Marco Atingido!',
      'Você alcançou: $milestoneTitle! Continue assim!',
      details,
    );
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementNotification(String emoji, String title) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _milestoneNotificationId + 1,
      '$emoji Conquista Desbloqueada!',
      'Você desbloqueou: $title',
      details,
    );
  }

  /// Cancel all weight tracker reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancel(_dailyReminderNotificationId);
  }

  /// Cancel all weight tracker notifications
  Future<void> cancelAll() async {
    await _notifications.cancel(_dailyReminderNotificationId);
    await _notifications.cancel(_goalAchievedNotificationId);
    await _notifications.cancel(_milestoneNotificationId);
  }
}
