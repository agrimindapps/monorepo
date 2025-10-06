import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Solicita permissões de notificação (principalmente para iOS)
  Future<bool> requestPermissions() async {
    final result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    return result ?? true; // Android não precisa de permissão explícita
  }

  /// Mostra uma notificação imediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    String? channelId,
    String? channelName,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'petiveti_channel',
      'PetiVeti Notifications',
      channelDescription: 'Notificações do aplicativo PetiVeti',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Agenda uma notificação para um horário específico
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'petiveti_reminders',
      'PetiVeti Lembretes',
      channelDescription: 'Lembretes agendados do PetiVeti',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Agenda uma notificação recorrente
  Future<void> scheduleRecurringNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'petiveti_recurring',
      'PetiVeti Recorrentes',
      channelDescription: 'Notificações recorrentes do PetiVeti',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancela uma notificação agendada
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancela todas as notificações agendadas
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Obtém notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  /// Cria notificação de lembrete de medicamento
  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String animalName,
    required DateTime reminderTime,
    required String dosage,
  }) async {
    final id = medicationId.hashCode;
    
    await scheduleNotification(
      id: id,
      title: 'Hora do medicamento! 💊',
      body: '$animalName precisa tomar $medicationName ($dosage)',
      scheduledDate: reminderTime,
      payload: 'medication:$medicationId',
    );
  }

  /// Cria notificação de lembrete de vacina
  Future<void> scheduleVaccineReminder({
    required String vaccineId,
    required String vaccineName,
    required String animalName,
    required DateTime reminderDate,
  }) async {
    final id = vaccineId.hashCode;
    
    await scheduleNotification(
      id: id,
      title: 'Vacina agendada! 💉',
      body: '$animalName tem vacina de $vaccineName marcada para hoje',
      scheduledDate: reminderDate,
      payload: 'vaccine:$vaccineId',
    );
  }

  /// Cria notificação de lembrete de consulta
  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String animalName,
    required DateTime appointmentTime,
    required String? veterinarian,
  }) async {
    final id = appointmentId.hashCode;
    
    final vetText = veterinarian != null ? ' com $veterinarian' : '';
    
    await scheduleNotification(
      id: id,
      title: 'Consulta agendada! 🏥',
      body: '$animalName tem consulta hoje às ${_formatTime(appointmentTime)}$vetText',
      scheduledDate: appointmentTime.subtract(const Duration(hours: 1)), // 1h antes
      payload: 'appointment:$appointmentId',
    );
  }

  /// Cria notificação de lembrete de peso
  Future<void> scheduleWeightReminder({
    required String animalId,
    required String animalName,
    required DateTime reminderDate,
  }) async {
    final id = 'weight_$animalId'.hashCode;
    
    await scheduleNotification(
      id: id,
      title: 'Hora de pesar! ⚖️',
      body: 'Lembre-se de registrar o peso de $animalName',
      scheduledDate: reminderDate,
      payload: 'weight:$animalId',
    );
  }

  /// Cria notificação de medicamento vencendo
  Future<void> showMedicationExpiringNotification({
    required String medicationName,
    required String animalName,
    required int daysUntilExpiry,
  }) async {
    final id = 'expiring_${medicationName}_$animalName'.hashCode;
    
    String message;
    if (daysUntilExpiry == 0) {
      message = 'O medicamento $medicationName de $animalName vence hoje!';
    } else if (daysUntilExpiry == 1) {
      message = 'O medicamento $medicationName de $animalName vence amanhã!';
    } else {
      message = 'O medicamento $medicationName de $animalName vence em $daysUntilExpiry dias!';
    }
    
    await showNotification(
      id: id,
      title: 'Medicamento vencendo! ⚠️',
      body: message,
      priority: NotificationPriority.high,
    );
  }

  /// Formata horário para exibição
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Callback quando notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Processa payload da notificação
  void _handleNotificationPayload(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final id = parts[1];

    switch (type) {
      case 'medication':
        _navigateToMedication(id);
        break;
      case 'vaccine':
        _navigateToVaccine(id);
        break;
      case 'appointment':
        _navigateToAppointment(id);
        break;
      case 'weight':
        _navigateToWeight(id);
        break;
    }
  }

  void _navigateToMedication(String medicationId) {
    print('Navigate to medication: $medicationId');
  }

  void _navigateToVaccine(String vaccineId) {
    print('Navigate to vaccine: $vaccineId');
  }

  void _navigateToAppointment(String appointmentId) {
    print('Navigate to appointment: $appointmentId');
  }

  void _navigateToWeight(String animalId) {
    print('Navigate to weight for animal: $animalId');
  }
}

/// Enum para prioridade de notificação
enum NotificationPriority {
  min,
  low,
  defaultPriority,
  high,
  max,
}
