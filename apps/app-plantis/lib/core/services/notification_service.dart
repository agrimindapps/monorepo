import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'plantis_tasks';
  static const String _channelName = 'Tarefas de Plantas';
  static const String _channelDescription = 'Notificações para cuidados com plantas';

  /// Inicializar o serviço de notificações
  Future<bool> initialize() async {
    try {
      // Configurações de inicialização para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configurações de inicialização para iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final bool? result = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Criar canal de notificação para Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Solicitar permissões
      await _requestPermissions();

      return result ?? false;
    } catch (e) {
      debugPrint('Erro ao inicializar notificações: $e');
      return false;
    }
  }

  /// Criar canal de notificação para Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Solicitar permissões necessárias
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+)
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Verificar se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  /// Mostrar notificação imediata
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF4CAF50), // Verde das plantas
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Erro ao mostrar notificação: $e');
    }
  }

  /// Cancelar notificação específica
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Erro ao cancelar notificação: $e');
    }
  }

  /// Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Erro ao cancelar todas as notificações: $e');
    }
  }

  /// Obter notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Erro ao obter notificações pendentes: $e');
      return [];
    }
  }

  /// Lidar com tap na notificação
  static void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notificação tapped com payload: $payload');
      // Aqui você pode navegar para uma tela específica
      // ou executar uma ação baseada no payload
    }
  }

  /// Criar ID único para notificação baseado em string
  static int createNotificationId(String identifier) {
    return identifier.hashCode.abs() % 2147483647;
  }
}

/// Tipos de notificações do app
enum NotificationType {
  taskReminder('task_reminder'),
  taskOverdue('task_overdue'),
  dailyReminder('daily_reminder');

  const NotificationType(this.value);
  final String value;
}