import 'dart:async';

import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

import '../../domain/extensions/vehicle_device_extension.dart';

/// Provider otimizado para gerenciamento de dispositivos veiculares
/// Usa DeviceManagementService do core package com extensões específicas de veículos
class VehicleDeviceProvider extends ChangeNotifier {

  VehicleDeviceProvider({
    core.DeviceManagementService? coreDeviceService,
    required core.ConnectivityService connectivityService,
  }) : _coreDeviceService = coreDeviceService,
       _connectivityService = connectivityService {
    _initializeConnectivity();
  }
  final core.DeviceManagementService? _coreDeviceService;
  final core.ConnectivityService _connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  // Estado
  List<core.DeviceEntity> _devices = [];
  VehicleDeviceStatistics? _statistics;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOnline = true;

  // Getters
  List<core.DeviceEntity> get devices => List.unmodifiable(_devices);
  VehicleDeviceStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;
  bool get hasError => _errorMessage != null;
  bool get hasDevices => _devices.isNotEmpty;

  /// Dispositivos ativos (com funcionalidades veiculares)
  List<core.DeviceEntity> get activeDevices =>
      _devices.where((device) => device.canAccessVehicle).toList();

  /// Dispositivos inativos
  List<core.DeviceEntity> get inactiveDevices =>
      _devices.where((device) => !device.isActive).toList();

  /// Dispositivos confiáveis para dados financeiros
  List<core.DeviceEntity> get trustedDevices =>
      _devices.where((device) => device.canAccessFinancialData).toList();

  /// Número de dispositivos ativos
  int get activeDeviceCount => activeDevices.length;

  /// Indica se pode adicionar mais dispositivos (baseado em limites premium)
  bool get canAddMoreDevices => activeDeviceCount < _getDeviceLimit();

  /// Dispositivo atual (se disponível)
  core.DeviceEntity? get currentDevice {
    // Retorna o dispositivo mais recentemente ativo
    if (_devices.isEmpty) return null;
    final sortedDevices = List<core.DeviceEntity>.from(_devices)
      ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
    return sortedDevices.first;
  }

  /// Obtém dispositivo por UUID
  core.DeviceEntity? getDeviceByUuid(String uuid) {
    try {
      return _devices.firstWhere((device) => device.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o dispositivo é o atual
  bool isCurrentDevice(String uuid) {
    final current = currentDevice;
    return current?.uuid == uuid;
  }

  // ===== CORE SERVICE METHODS =====

  /// Carrega dispositivos do usuário
  Future<void> loadUserDevices() async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Replace with core service when properly configured
      // For now, provide mock data for testing
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      // Mock device data for testing
      _devices = [
        core.DeviceEntity(
          id: 'device_1',
          uuid: 'mock_uuid_1',
          name: 'iPhone Principal',
          model: 'iPhone 14 Pro',
          platform: 'iOS',
          systemVersion: '16.4',
          appVersion: '2.1.0',
          buildNumber: '45',
          isPhysicalDevice: true,
          manufacturer: 'Apple',
          firstLoginAt: DateTime.now().subtract(const Duration(days: 30)),
          lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        core.DeviceEntity(
          id: 'device_2',
          uuid: 'mock_uuid_2',
          name: 'Samsung Tablet',
          model: 'Galaxy Tab S8',
          platform: 'Android',
          systemVersion: '13.0',
          appVersion: '2.1.0',
          buildNumber: '45',
          isPhysicalDevice: true,
          manufacturer: 'Samsung',
          firstLoginAt: DateTime.now().subtract(const Duration(days: 15)),
          lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      _updateStatistics();
      debugPrint('🔄 VehicleDevice: Loaded ${_devices.length} mock devices');

    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Valida se o dispositivo pode ser registrado
  Future<bool> validateDeviceRegistration(core.DeviceEntity device) async {
    try {
      // Check device limit first
      if (!canAddMoreDevices) {
        _setError('Limite de dispositivos atingido. Faça upgrade para adicionar mais.');
        return false;
      }

      // TODO: Use core service validation when properly configured
      // For now, simple validation
      await Future.delayed(const Duration(milliseconds: 300));

      final isValid = device.isPhysicalDevice && device.isActive;
      if (!isValid) {
        _setError('Dispositivo não passou na validação de segurança.');
      }

      return isValid;
    } catch (e) {
      _setError('Erro na validação: $e');
      return false;
    }
  }

  /// Revoga um dispositivo específico
  Future<bool> revokeDevice(String deviceId) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Use core service when properly configured
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove device from local list
      final deviceExists = _devices.any((device) => device.id == deviceId);
      if (!deviceExists) {
        _setError('Dispositivo não encontrado');
        return false;
      }

      _devices.removeWhere((device) => device.id == deviceId);
      _updateStatistics();
      debugPrint('🔄 VehicleDevice: Device $deviceId revoked');
      return true;

    } catch (e) {
      _setError('Erro inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Revoga múltiplos dispositivos
  Future<int> revokeMultipleDevices(List<String> deviceIds) async {
    _setLoading(true);
    _clearError();

    int revokedCount = 0;

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      for (final deviceId in deviceIds) {
        final deviceExists = _devices.any((device) => device.id == deviceId);
        if (deviceExists) {
          _devices.removeWhere((device) => device.id == deviceId);
          revokedCount++;
        }
      }

      _updateStatistics();
      debugPrint('🔄 VehicleDevice: Revoked $revokedCount/${deviceIds.length} devices');

      if (revokedCount < deviceIds.length) {
        _setError('Alguns dispositivos não puderam ser revogados');
      }

    } catch (e) {
      _setError('Erro ao revogar dispositivos: $e');
    } finally {
      _setLoading(false);
    }

    return revokedCount;
  }

  /// Obtém estatísticas detalhadas dos dispositivos
  Future<void> refreshStatistics() async {
    _updateStatistics();
  }

  // ===== VEHICLE-SPECIFIC METHODS =====

  /// Obtém dispositivos ordenados por prioridade de sync
  List<core.DeviceEntity> getDevicesBySyncPriority() {
    final sortedDevices = List<core.DeviceEntity>.from(_devices)
      ..sort((a, b) => b.syncPriority.compareTo(a.syncPriority));
    return sortedDevices;
  }

  /// Obtém dispositivos elegíveis para sync de dados offline
  List<core.DeviceEntity> getOfflineSyncDevices() {
    return _devices.where((device) => device.canSyncOfflineData).toList();
  }

  /// Verifica se há conflitos de dados entre dispositivos
  Future<bool> checkForDataConflicts() async {
    // TODO: Implement data conflict detection
    // This would check for expense/fuel data conflicts across devices
    return false;
  }

  // ===== CONNECTIVITY METHODS =====

  void _initializeConnectivity() {
    _connectivityService.isOnline().then((result) {
      result.fold(
        (failure) => debugPrint('🔌 Connectivity check failed: ${failure.message}'),
        (isOnline) {
          _isOnline = isOnline;
          notifyListeners();
        },
      );
    });

    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      _onConnectivityChanged,
      onError: (Object error) => debugPrint('🔌 Connectivity stream error: $error'),
    );
  }

  void _onConnectivityChanged(bool isOnline) {
    final wasOnline = _isOnline;
    _isOnline = isOnline;

    debugPrint('🔌 VehicleDevice connectivity: ${wasOnline ? 'online' : 'offline'} → ${isOnline ? 'online' : 'offline'}');

    if (!wasOnline && isOnline) {
      // Came back online - refresh devices
      loadUserDevices();
    }

    notifyListeners();
  }

  // ===== PREMIUM INTEGRATION =====

  int _getDeviceLimit() {
    // TODO: Integrate with RevenueCat service for dynamic limits
    // For now, return hardcoded limit
    return 3; // Free tier limit
  }

  /// Obtém informações de limite de dispositivos baseado na assinatura
  Future<DeviceLimitInfo> getDeviceLimitInfo() async {
    // TODO: Implement premium service integration
    final currentCount = activeDeviceCount;
    final limit = _getDeviceLimit();

    return DeviceLimitInfo(
      currentCount: currentCount,
      limit: limit,
      canAddMore: currentCount < limit,
      planName: 'Plano Gratuito',
      requiresUpgrade: currentCount >= limit,
    );
  }

  // ===== HELPER METHODS =====

  void _updateStatistics() {
    _statistics = VehicleDeviceStatistics.fromDevices(_devices);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('🚗 VehicleDeviceProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Atualiza lista de dispositivos
  Future<void> refresh() async {
    await loadUserDevices();
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<bool> revokeAllOtherDevices() async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement with core service
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay

      // Mock implementation - remove all devices except the most recent
      if (_devices.isNotEmpty) {
        final current = currentDevice;
        if (current != null) {
          _devices = [current];
          notifyListeners();
        }
      }

      return true;
    } catch (e) {
      _setError('Erro ao revogar outros dispositivos: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Informações sobre limite de dispositivos
class DeviceLimitInfo {

  const DeviceLimitInfo({
    required this.currentCount,
    required this.limit,
    required this.canAddMore,
    required this.planName,
    required this.requiresUpgrade,
  });
  final int currentCount;
  final int limit;
  final bool canAddMore;
  final String planName;
  final bool requiresUpgrade;

  /// Porcentagem do limite utilizada
  double get usagePercentage => limit > 0 ? (currentCount / limit) : 0.0;

  /// Dispositivos restantes que podem ser adicionados
  int get remainingDevices => limit - currentCount;

  /// Status textual do limite
  String get statusText {
    if (requiresUpgrade) {
      return 'Limite atingido ($currentCount/$limit)';
    }
    return 'Dispositivos: $currentCount/$limit';
  }
}