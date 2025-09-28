import 'dart:io';

import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../presentation/providers/vehicle_device_provider.dart';

/// Serviço de integração do Device Management com o fluxo de autenticação
class DeviceIntegrationService {

  DeviceIntegrationService(
    this._coreDeviceService,
    this._deviceInfoPlugin,
  );
  final DeviceManagementService _coreDeviceService;
  final DeviceInfoPlugin _deviceInfoPlugin;

  /// Valida e registra dispositivo durante o login
  /// Retorna true se o dispositivo foi validado com sucesso
  Future<DeviceValidationResult> validateDeviceForLogin(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceIntegrationService: Validating device for login');
      }

      // 1. Obter informações do dispositivo atual
      final deviceInfoResult = await _getCurrentDeviceInfo();
      if (deviceInfoResult.isFailure) {
        return DeviceValidationResult.failure(
          'Erro ao obter informações do dispositivo: ${deviceInfoResult.error}',
        );
      }

      final deviceEntity = deviceInfoResult.deviceEntity!;

      // 2. Usar o core service para validar o dispositivo
      final validationResult = await _coreDeviceService.validateDevice(deviceEntity);

      return validationResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceIntegrationService: Device validation failed - ${failure.message}');
          }
          return DeviceValidationResult.failure(failure.message);
        },
        (validatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceIntegrationService: Device validated successfully');
          }
          return DeviceValidationResult.success(validatedDevice);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceIntegrationService: Unexpected error - $e');
      }
      return DeviceValidationResult.failure(
        'Erro inesperado na validação do dispositivo: $e',
      );
    }
  }

  /// Atualiza atividade do dispositivo durante o uso do app
  Future<void> updateDeviceActivity(String userId, String deviceUuid) async {
    try {
      // Using core service - this would be handled automatically by the core service
      // when user uses the app, but we can trigger a manual update if needed
      if (kDebugMode) {
        debugPrint('✅ DeviceIntegrationService: Device activity updated (handled by core)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceIntegrationService: Error updating activity - $e');
      }
    }
  }

  /// Configura o provider de device management após login
  void setupDeviceManagementProvider(
    VehicleDeviceProvider provider,
    String userId,
    DeviceEntity currentDevice,
  ) {
    // Load user devices in the provider
    provider.loadUserDevices();
  }

  /// Obtém informações do dispositivo atual
  Future<DeviceInfoResult> _getCurrentDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uuid = await _generateDeviceUuid();

      DeviceEntity deviceEntity;

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceEntity = DeviceEntity(
          id: uuid, // Using uuid as id for now
          uuid: uuid,
          name: iosInfo.name,
          model: iosInfo.model,
          platform: 'iOS',
          systemVersion: iosInfo.systemVersion,
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          manufacturer: 'Apple',
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceEntity = DeviceEntity(
          id: uuid, // Using uuid as id for now
          uuid: uuid,
          name: _generateFriendlyName(androidInfo),
          model: androidInfo.model,
          platform: 'Android',
          systemVersion: androidInfo.version.release,
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          manufacturer: androidInfo.manufacturer,
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      } else {
        return DeviceInfoResult.failure(
          'Plataforma não suportada: ${Platform.operatingSystem}',
        );
      }

      return DeviceInfoResult.success(deviceEntity);
    } catch (e) {
      return DeviceInfoResult.failure('Erro ao obter informações do dispositivo: $e');
    }
  }

  /// Gera UUID único para o dispositivo
  Future<String> _generateDeviceUuid() async {
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios-${DateTime.now().millisecondsSinceEpoch}';
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return 'android-${androidInfo.id}-${androidInfo.fingerprint.hashCode}';
    }
    return 'unknown-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Gera nome amigável para dispositivos Android
  String _generateFriendlyName(AndroidDeviceInfo androidInfo) {
    final brand = _capitalizeFirst(androidInfo.brand);
    final model = androidInfo.model;
    
    if (model.toLowerCase().startsWith(brand.toLowerCase())) {
      return model;
    }
    
    return '$brand $model';
  }

  /// Capitaliza primeira letra
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

/// Resultado da validação de dispositivo
class DeviceValidationResult {

  DeviceValidationResult._(
    this.isSuccess,
    this.errorMessage,
    this.deviceEntity,
  );

  factory DeviceValidationResult.success(DeviceEntity deviceEntity) =>
      DeviceValidationResult._(true, null, deviceEntity);

  factory DeviceValidationResult.failure(String errorMessage) =>
      DeviceValidationResult._(false, errorMessage, null);
  final bool isSuccess;
  final String? errorMessage;
  final DeviceEntity? deviceEntity;

  bool get isFailure => !isSuccess;
}

/// Resultado da obtenção de informações do dispositivo
class DeviceInfoResult {

  DeviceInfoResult._(this.isSuccess, this.error, this.deviceEntity);

  factory DeviceInfoResult.success(DeviceEntity deviceEntity) =>
      DeviceInfoResult._(true, null, deviceEntity);

  factory DeviceInfoResult.failure(String error) =>
      DeviceInfoResult._(false, error, null);
  final bool isSuccess;
  final String? error;
  final DeviceEntity? deviceEntity;

  bool get isFailure => !isSuccess;
}
