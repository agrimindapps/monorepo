import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Serviço de notificações específico do GasOMeter
class GasOMeterNotificationService {
  static final GasOMeterNotificationService _instance = GasOMeterNotificationService._internal();
  factory GasOMeterNotificationService() => _instance;
  GasOMeterNotificationService._internal();

  static const String _appName = 'GasOMeter';
  static const int _primaryColor = 0xFF2196F3; // Azul combustível

  final INotificationRepository _notificationRepository = LocalNotificationService();
  bool _isInitialized = false;

  /// Inicializa o serviço de notificações do GasOMeter
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Inicializa timezone
      await NotificationHelper.initializeTimeZone();

      // Configura settings
      final settings = NotificationHelper.createDefaultSettings(
        defaultColor: _primaryColor,
      );
      (_notificationRepository as LocalNotificationService).configure(settings);

      // Cria canais padrão
      final defaultChannels = NotificationHelper.getDefaultChannels(
        appName: _appName,
        primaryColor: _primaryColor,
      );

      // Inicializa o serviço
      final result = await _notificationRepository.initialize(
        defaultChannels: defaultChannels,
      );

      // Define callbacks
      _notificationRepository.setNotificationTapCallback(_handleNotificationTap);
      _notificationRepository.setNotificationActionCallback(_handleNotificationAction);

      _isInitialized = result;
      return result;
    } catch (e) {
      debugPrint('❌ Error initializing GasOMeter notifications: $e');
      return false;
    }
  }

  /// Verifica se as notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    final permission = await _notificationRepository.getPermissionStatus();
    return permission.isGranted;
  }

  /// Solicita permissão para notificações
  Future<bool> requestNotificationPermission() async {
    final permission = await _notificationRepository.requestPermission();
    return permission.isGranted;
  }

  /// Abre configurações de notificação
  Future<bool> openNotificationSettings() async {
    return await _notificationRepository.openNotificationSettings();
  }

  /// Mostra notificação de lembrete de abastecimento
  Future<void> showFuelReminderNotification({
    required String vehicleName,
    required double currentKm,
    required double estimatedKmToEmpty,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('fuel_reminder_$vehicleName'),
      title: '⛽ Lembrete de Combustível',
      body: '$vehicleName está com pouco combustível. Aproximadamente ${estimatedKmToEmpty.toStringAsFixed(0)}km restantes.',
      payload: jsonEncode({
        'type': 'fuel_reminder',
        'vehicle_name': vehicleName,
        'current_km': currentKm,
        'estimated_km_to_empty': estimatedKmToEmpty,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de lembrete de manutenção
  Future<void> showMaintenanceReminderNotification({
    required String vehicleName,
    required String maintenanceType,
    required double currentKm,
    required double maintenanceKm,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('maintenance_${vehicleName}_$maintenanceType'),
      title: '🔧 Lembrete de Manutenção',
      body: '$vehicleName precisa de $maintenanceType. Atual: ${currentKm.toStringAsFixed(0)}km / Meta: ${maintenanceKm.toStringAsFixed(0)}km',
      payload: jsonEncode({
        'type': 'maintenance_reminder',
        'vehicle_name': vehicleName,
        'maintenance_type': maintenanceType,
        'current_km': currentKm,
        'maintenance_km': maintenanceKm,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de economia de combustível
  Future<void> showFuelEconomyNotification({
    required String vehicleName,
    required double currentEconomy,
    required double previousEconomy,
  }) async {
    final isImproved = currentEconomy > previousEconomy;
    final difference = (currentEconomy - previousEconomy).abs();
    
    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('fuel_economy_$vehicleName'),
      title: isImproved ? '📈 Economia Melhorou!' : '📉 Economia Piorou',
      body: '$vehicleName: ${currentEconomy.toStringAsFixed(1)}km/l (${isImproved ? '+' : '-'}${difference.toStringAsFixed(1)}km/l)',
      payload: jsonEncode({
        'type': 'fuel_economy',
        'vehicle_name': vehicleName,
        'current_economy': currentEconomy,
        'previous_economy': previousEconomy,
        'improved': isImproved,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Mostra notificação de relatório mensal
  Future<void> showMonthlyReportNotification({
    required String month,
    required double totalExpenses,
    required double totalFuel,
    required int totalRefuels,
  }) async {
    final notification = NotificationHelper.createPromotionNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('monthly_report_$month'),
      title: '📊 Relatório Mensal Disponível',
      body: '$month: R\$ ${totalExpenses.toStringAsFixed(2)} gastos, ${totalFuel.toStringAsFixed(0)}L, $totalRefuels abastecimentos.',
      payload: jsonEncode({
        'type': 'monthly_report',
        'month': month,
        'total_expenses': totalExpenses,
        'total_fuel': totalFuel,
        'total_refuels': totalRefuels,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Agenda lembrete para verificar quilometragem
  Future<void> scheduleOdometerCheckReminder({
    required String vehicleName,
    required Duration interval,
  }) async {
    final notification = NotificationHelper.createReminderNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('odometer_check_$vehicleName'),
      title: '📏 Atualizar Quilometragem',
      body: 'Lembrete para registrar a quilometragem atual do $vehicleName.',
      payload: jsonEncode({
        'type': 'odometer_check',
        'vehicle_name': vehicleName,
        'interval': interval.inHours,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.schedulePeriodicNotification(notification, interval);
  }

  /// Mostra notificação de preço do combustível
  Future<void> showFuelPriceAlertNotification({
    required String fuelType,
    required String stationName,
    required double price,
    required double averagePrice,
  }) async {
    final isCheaper = price < averagePrice;
    final difference = (price - averagePrice).abs();

    final notification = NotificationHelper.createAlertNotification(
      appName: _appName,
      id: _notificationRepository.generateNotificationId('fuel_price_alert_$stationName'),
      title: isCheaper ? '💰 Preço Baixo!' : '🚨 Preço Alto',
      body: '$fuelType em $stationName: R\$ ${price.toStringAsFixed(3)} (${isCheaper ? '-' : '+'}R\$ ${difference.toStringAsFixed(3)} da média)',
      payload: jsonEncode({
        'type': 'fuel_price_alert',
        'fuel_type': fuelType,
        'station_name': stationName,
        'price': price,
        'average_price': averagePrice,
        'is_cheaper': isCheaper,
      }),
      color: _primaryColor,
    );

    await _notificationRepository.showNotification(notification);
  }

  /// Cancela notificação específica
  Future<bool> cancelNotification(String identifier) async {
    final id = _notificationRepository.generateNotificationId(identifier);
    return await _notificationRepository.cancelNotification(id);
  }

  /// Cancela todas as notificações
  Future<bool> cancelAllNotifications() async {
    return await _notificationRepository.cancelAllNotifications();
  }

  /// Lista notificações pendentes
  Future<List<PendingNotificationEntity>> getPendingNotifications() async {
    return await _notificationRepository.getPendingNotifications();
  }

  /// Verifica se uma notificação específica está agendada
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

      debugPrint('🔔 GasOMeter notification tapped: $type');

      // Aqui você pode navegar para telas específicas baseado no tipo
      switch (type) {
        case 'fuel_reminder':
          _navigateToFuelPage(data);
          break;
        case 'maintenance_reminder':
          _navigateToMaintenancePage(data);
          break;
        case 'fuel_economy':
          _navigateToReportsPage(data);
          break;
        case 'monthly_report':
          _navigateToReportsPage(data);
          break;
        case 'odometer_check':
          _navigateToOdometerPage(data);
          break;
        case 'fuel_price_alert':
          _navigateToFuelPage(data);
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Manipula ação de notificação
  void _handleNotificationAction(String actionId, String? payload) {
    debugPrint('🔔 GasOMeter notification action: $actionId');

    switch (actionId) {
      case 'view_details':
        _handleNotificationTap(payload);
        break;
      case 'dismiss':
        // Apenas dismissar
        break;
      case 'remind_later':
        _handleRemindLater(payload);
        break;
    }
  }

  /// Navegar para página de combustível
  void _navigateToFuelPage(Map<String, dynamic> data) {
    // TODO: Implementar navegação para página de combustível
    debugPrint('Navigate to fuel page: ${data['vehicle_name']}');
  }

  /// Navegar para página de manutenção
  void _navigateToMaintenancePage(Map<String, dynamic> data) {
    // TODO: Implementar navegação para página de manutenção
    debugPrint('Navigate to maintenance page: ${data['vehicle_name']} - ${data['maintenance_type']}');
  }

  /// Navegar para página de relatórios
  void _navigateToReportsPage(Map<String, dynamic> data) {
    // TODO: Implementar navegação para página de relatórios
    debugPrint('Navigate to reports page');
  }

  /// Navegar para página de odômetro
  void _navigateToOdometerPage(Map<String, dynamic> data) {
    // TODO: Implementar navegação para página de odômetro
    debugPrint('Navigate to odometer page: ${data['vehicle_name']}');
  }

  /// Reagendar lembrete
  void _handleRemindLater(String? payload) {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'maintenance_reminder':
          showMaintenanceReminderNotification(
            vehicleName: data['vehicle_name'] as String? ?? '',
            maintenanceType: data['maintenance_type'] as String? ?? '',
            currentKm: (data['current_km'] as num?)?.toDouble() ?? 0.0,
            maintenanceKm: (data['maintenance_km'] as num?)?.toDouble() ?? 0.0,
          );
          break;
        // Adicionar outros tipos conforme necessário
      }
    } catch (e) {
      debugPrint('❌ Error rescheduling notification: $e');
    }
  }
}

/// Tipos de notificação do GasOMeter
enum GasOMeterNotificationType {
  fuelReminder('fuel_reminder'),
  maintenanceReminder('maintenance_reminder'),
  fuelEconomy('fuel_economy'),
  monthlyReport('monthly_report'),
  odometerCheck('odometer_check'),
  fuelPriceAlert('fuel_price_alert');

  const GasOMeterNotificationType(this.value);
  final String value;
}