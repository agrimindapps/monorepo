import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../presentation/providers/vehicle_device_notifier.dart';

/// Resultado da validação de dispositivo para o app-gasometer
/// Wrapper simplificado para evitar conflitos com as múltiplas versões do core
class GasometerDeviceValidationResult {
  const GasometerDeviceValidationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.deviceEntity,
  });

  factory GasometerDeviceValidationResult.success(DeviceEntity deviceEntity) =>
      GasometerDeviceValidationResult._(
        isSuccess: true,
        deviceEntity: deviceEntity,
      );

  factory GasometerDeviceValidationResult.failure(String errorMessage) =>
      GasometerDeviceValidationResult._(
        isSuccess: false,
        errorMessage: errorMessage,
      );

  final bool isSuccess;
  final String? errorMessage;
  final DeviceEntity? deviceEntity;

  bool get isFailure => !isSuccess;
}

/// Serviço de integração do Device Management com o fluxo de autenticação
class DeviceIntegrationService {

  DeviceIntegrationService(
    this._coreDeviceService,
    this._deviceInfoPlugin,
  );
  final DeviceManagementService _coreDeviceService;
  final DeviceInfoPlugin _deviceInfoPlugin;

  /// Valida e registra dispositivo durante o login
  /// Retorna GasometerDeviceValidationResult
  Future<GasometerDeviceValidationResult> validateDeviceForLogin(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceIntegrationService: Validating device for login');
      }
      final deviceInfoResult = await _getCurrentDeviceInfo();
      if (deviceInfoResult.isFailure) {
        return GasometerDeviceValidationResult.failure(
          'Erro ao obter informações do dispositivo: ${deviceInfoResult.error}',
        );
      }

      final deviceEntity = deviceInfoResult.deviceEntity!;
      final validationResult = await _coreDeviceService.validateDevice(deviceEntity);

      return validationResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceIntegrationService: Device validation failed - ${failure.message}');
          }
          return GasometerDeviceValidationResult.failure(failure.message);
        },
        (validatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceIntegrationService: Device validated successfully');
          }
          return GasometerDeviceValidationResult.success(validatedDevice);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceIntegrationService: Unexpected error - $e');
      }
      return GasometerDeviceValidationResult.failure(
        'Erro inesperado na validação do dispositivo: $e',
      );
    }
  }

  /// Atualiza atividade do dispositivo durante o uso do app
  Future<void> updateDeviceActivity(String userId, String deviceUuid) async {
    try {
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
    VehicleDeviceNotifier provider,
    String userId,
    DeviceEntity currentDevice,
  ) {
    provider.loadUserDevices();
  }

  /// Obtém informações do dispositivo atual
  Future<_DeviceInfoResult> _getCurrentDeviceInfo() async {
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
        return _DeviceInfoResult.failure(
          'Plataforma não suportada: ${Platform.operatingSystem}',
        );
      }

      return _DeviceInfoResult.success(deviceEntity);
    } catch (e) {
      return _DeviceInfoResult.failure('Erro ao obter informações do dispositivo: $e');
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

/// Resultado interno da obtenção de informações do dispositivo
class _DeviceInfoResult {

  _DeviceInfoResult._(this.isSuccess, this.error, this.deviceEntity);

  factory _DeviceInfoResult.success(DeviceEntity deviceEntity) =>
      _DeviceInfoResult._(true, null, deviceEntity);

  factory _DeviceInfoResult.failure(String error) =>
      _DeviceInfoResult._(false, error, null);
  final bool isSuccess;
  final String? error;
  final DeviceEntity? deviceEntity;

  bool get isFailure => !isSuccess;
}
