import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Interface para o serviço de notificações do ReceitaAgro
abstract class IReceitaAgroNotificationService {
  Future<bool> initialize();
  Future<bool> areNotificationsEnabled();
  Future<bool> requestNotificationPermission();
  Future<bool> openNotificationSettings();
  Future<void> showPestDetectedNotification({
    required String pestName,
    required String plantName,
    String? imageUrl,
  });
  Future<void> showApplicationReminderNotification({
    required String defensiveName,
    required String plantName,
    required DateTime applicationDate,
  });
  Future<void> showNewRecipeNotification({
    required String recipeName,
    required String category,
  });
  Future<void> showWeatherAlertNotification({
    required String message,
    required String recommendation,
  });
  Future<void> scheduleMonitoringReminder({
    required String fieldName,
    required Duration interval,
  });
  Future<bool> cancelNotification(String identifier);
  Future<bool> cancelAllNotifications();
  Future<List<PendingNotificationEntity>> getPendingNotifications();
  Future<bool> isNotificationScheduled(String identifier);
}

/// Implementação do serviço de notificações específico do ReceitaAgro
class ReceitaAgroNotificationService implements IReceitaAgroNotificationService {

  static const String _appName = 'ReceitaAgro';
  static const int _primaryColor = 0xFF4CAF50; // Verde agricultura

  final INotificationRepository _notificationRepository;
  bool _isInitialized = false;
  
  /// Construtor que permite injeção de dependência
  ReceitaAgroNotificationService({
    INotificationRepository? notificationRepository,
  }) : _notificationRepository = notificationRepository ?? LocalNotificationService();

  /// Inicializa o serviço de notificações do ReceitaAgro
  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await NotificationHelper.initializeTimeZone();
      final settings = NotificationHelper.createDefaultSettings(
        defaultColor: _primaryColor,
      );
      (_notificationRepository as LocalNotificationService).configure(settings);
      final defaultChannels = NotificationHelper.getDefaultChannels(
        appName: _appName,
        primaryColor: _primaryColor,
      );
      final result = await _notificationRepository.initialize(
        defaultChannels: defaultChannels,
      );
      _notificationRepository.setNotificationTapCallback(_handleNotificationTap);
      _notificationRepository.setNotificationActionCallback(_handleNotificationAction);

      _isInitialized = result;
      return result;
    } catch (e) {
      debugPrint('❌ Error initializing ReceitaAgro notifications: $e');
      return false;
    }
  }

  /// Verifica se as notificações estão habilitadas
  @override
  Future<bool> areNotificationsEnabled() async {
    final permission = await _notificationRepository.getPermissionStatus();
    return permission.isGranted;
  }

  /// Solicita permissão para notificações
  @override
  Future<bool> requestNotificationPermission() async {
    final permission = await _notificationRepository.requestPermission();
    return permission.isGranted;
  }

  /// Abre configurações de notificação
  @override
  Future<bool> openNotificationSettings() async {
    return await _notificationRepository.openNotificationSettings();
  }

  /// Mostra notificação de nova praga detectada
  @override
  Future<void> showPestDetectedNotification({
    required String pestName,
    required String plantName,
    String? imageUrl,
  }) async {
    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('pest_detected_$pestName'),
      title: '🐛 Praga Detectada!',
      body: '$pestName encontrada em $plantName. Veja as recomendações.',
      payload: jsonEncode({
        'type': 'pest_detected',
        'pest_name': pestName,
        'plant_name': plantName,
        'image_url': imageUrl,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de lembrete de aplicação
  @override
  Future<void> showApplicationReminderNotification({
    required String defensiveName,
    required String plantName,
    required DateTime applicationDate,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('application_$defensiveName'),
      title: '📅 Lembrete de Aplicação',
      body: 'Aplicar $defensiveName em $plantName hoje.',
      scheduledDate: applicationDate,
      payload: jsonEncode({
        'type': 'application_reminder',
        'defensive_name': defensiveName,
        'plant_name': plantName,
        'application_date': applicationDate.toIso8601String(),
      }),
      color: _primaryColor,
    );

    await _notificationRepository.scheduleNotification(notification);
  }

  /// Mostra notificação de nova receita disponível
  @override
  Future<void> showNewRecipeNotification({
    required String recipeName,
    required String category,
  }) async {
    final notification = NotificationHelper.createPromotionNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('new_recipe_$recipeName'),
      title: '📋 Nova Receita Disponível!',
      body: '$recipeName na categoria $category.',
      payload: jsonEncode({
        'type': 'new_recipe',
        'recipe_name': recipeName,
        'category': category,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de clima favorável para aplicação
  @override
  Future<void> showWeatherAlertNotification({
    required String message,
    required String recommendation,
  }) async {
    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('weather_alert'),
      title: '🌤️ Alerta Climático',
      body: '$message - $recommendation',
      payload: jsonEncode({
        'type': 'weather_alert',
        'message': message,
        'recommendation': recommendation,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Agenda lembrete recorrente para monitoramento
  @override
  Future<void> scheduleMonitoringReminder({
    required String fieldName,
    required Duration interval,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('monitoring_$fieldName'),
      title: '👁️ Lembrete de Monitoramento',
      body: 'Hora de verificar as plantas em $fieldName.',
      payload: jsonEncode({
        'type': 'monitoring_reminder',
        'field_name': fieldName,
        'interval': interval.inHours,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.schedulePeriodicNotification(notification, interval);
  }

  /// Cancela notificação específica
  @override
  Future<bool> cancelNotification(String identifier) async {
    final id = _notificationRepository.generateNotificationId(identifier);
    return await _notificationRepository.cancelNotification(id);
  }

  /// Cancela todas as notificações
  @override
  Future<bool> cancelAllNotifications() async {
    return await _notificationRepository.cancelAllNotifications();
  }

  /// Lista notificações pendentes
  @override
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _notificationRepository.getPendingNotifications();
  }

  /// Verifica se uma notificação específica está agendada
  @override
  Future<bool> isNotificationScheduled(String identifier) async {
    final id = _notificationRepository.generateNotificationId(identifier);
    return await _notificationRepository.isNotificationScheduled(id);
  }

  /// Manipula tap em notificação
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      debugPrint('🔔 ReceitaAgro notification tapped: $type');
      switch (type) {
        case 'pest_detected':
          _navigateToPestDetails(data);
          break;
        case 'application_reminder':
          _navigateToApplicationSchedule(data);
          break;
        case 'new_recipe':
          _navigateToRecipeDetails(data);
          break;
        case 'weather_alert':
          _navigateToWeatherInfo(data);
          break;
        case 'monitoring_reminder':
          _navigateToMonitoring(data);
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Manipula ação de notificação
  void _handleNotificationAction(String actionId, String? payload) {
    debugPrint('🔔 ReceitaAgro notification action: $actionId');

    switch (actionId) {
      case 'view_details':
        _handleNotificationTap(payload);
        break;
      case 'dismiss':
        break;
      case 'remind_later':
        _handleRemindLater(payload);
        break;
    }
  }

  /// Navegar para detalhes da praga
  void _navigateToPestDetails(Map<String, dynamic> data) {
    debugPrint('Navigate to pest: ${data['pest_name']}');
  }

  /// Navegar para agenda de aplicação
  void _navigateToApplicationSchedule(Map<String, dynamic> data) {
    debugPrint('Navigate to application: ${data['defensive_name']}');
  }

  /// Navegar para detalhes da receita
  void _navigateToRecipeDetails(Map<String, dynamic> data) {
    debugPrint('Navigate to recipe: ${data['recipe_name']}');
  }

  /// Navegar para informações climáticas
  void _navigateToWeatherInfo(Map<String, dynamic> data) {
    debugPrint('Navigate to weather info');
  }

  /// Navegar para monitoramento
  void _navigateToMonitoring(Map<String, dynamic> data) {
    debugPrint('Navigate to monitoring: ${data['field_name']}');
  }

  /// Reagendar lembrete
  void _handleRemindLater(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;
      final newDate = DateTime.now().add(const Duration(hours: 1));

      switch (type) {
        case 'application_reminder':
          showApplicationReminderNotification(
            defensiveName: (data['defensive_name'] as String?) ?? '',
            plantName: (data['plant_name'] as String?) ?? '',
            applicationDate: newDate,
          );
          break;
      }
    } catch (e) {
      debugPrint('❌ Error rescheduling notification: $e');
    }
  }
}

/// Tipos de notificação do ReceitaAgro
enum ReceitaAgroNotificationType {
  pestDetected('pest_detected'),
  applicationReminder('application_reminder'),
  newRecipe('new_recipe'),
  weatherAlert('weather_alert'),
  monitoringReminder('monitoring_reminder');

  const ReceitaAgroNotificationType(this.value);
  final String value;
}
