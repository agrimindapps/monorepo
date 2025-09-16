import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/entities/device_info.dart';
import '../domain/usecases/validate_device_limit.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../presentation/providers/device_management_provider.dart';

/// Serviço de integração do Device Management com o fluxo de autenticação
@lazySingleton
class DeviceIntegrationService {
  final ValidateDeviceLimitUseCase _validateDeviceLimitUseCase;
  final DeviceRemoteDataSource _deviceRemoteDataSource;
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceIntegrationService(
    this._validateDeviceLimitUseCase,
    this._deviceRemoteDataSource,
    this._deviceInfoPlugin,
  );

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

      final deviceInfo = deviceInfoResult.deviceInfo!;

      // 2. Validar limite e registrar dispositivo
      final validationResult = await _validateDeviceLimitUseCase.validateAndRegisterDevice(
        userId: userId,
        device: deviceInfo,
      );

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
      final result = await _deviceRemoteDataSource.updateLastActivity(userId, deviceUuid);
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ DeviceIntegrationService: Failed to update activity - ${failure.message}');
          }
        },
        (updatedDevice) {
          if (kDebugMode) {
            debugPrint('✅ DeviceIntegrationService: Device activity updated');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceIntegrationService: Error updating activity - $e');
      }
    }
  }

  /// Configura o provider de device management após login
  void setupDeviceManagementProvider(
    DeviceManagementProvider provider,
    String userId,
    DeviceInfo currentDevice,
  ) {
    provider.setCurrentUser(userId);
    provider.setCurrentDevice(currentDevice);
  }

  /// Obtém informações do dispositivo atual
  Future<DeviceInfoResult> _getCurrentDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uuid = await _generateDeviceUuid();

      DeviceInfo deviceInfo;
      
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceInfo = DeviceInfo(
          uuid: uuid,
          name: iosInfo.name,
          model: iosInfo.model,
          platform: 'iOS',
          systemVersion: iosInfo.systemVersion,
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          identifier: iosInfo.identifierForVendor ?? 'unknown',
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          manufacturer: 'Apple',
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          isActive: true,
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceInfo = DeviceInfo(
          uuid: uuid,
          name: _generateFriendlyName(androidInfo),
          model: androidInfo.model,
          platform: 'Android',
          systemVersion: androidInfo.version.release,
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          identifier: androidInfo.id,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          manufacturer: androidInfo.manufacturer,
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          isActive: true,
        );
      } else {
        return DeviceInfoResult.failure(
          'Plataforma não suportada: ${Platform.operatingSystem}',
        );
      }

      return DeviceInfoResult.success(deviceInfo);
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
  final bool isSuccess;
  final String? errorMessage;
  final DeviceInfo? deviceInfo;

  DeviceValidationResult._(
    this.isSuccess,
    this.errorMessage,
    this.deviceInfo,
  );

  factory DeviceValidationResult.success(DeviceInfo deviceInfo) =>
      DeviceValidationResult._(true, null, deviceInfo);

  factory DeviceValidationResult.failure(String errorMessage) =>
      DeviceValidationResult._(false, errorMessage, null);

  bool get isFailure => !isSuccess;
}

/// Resultado da obtenção de informações do dispositivo
class DeviceInfoResult {
  final bool isSuccess;
  final String? error;
  final DeviceInfo? deviceInfo;

  DeviceInfoResult._(this.isSuccess, this.error, this.deviceInfo);

  factory DeviceInfoResult.success(DeviceInfo deviceInfo) =>
      DeviceInfoResult._(true, null, deviceInfo);

  factory DeviceInfoResult.failure(String error) =>
      DeviceInfoResult._(false, error, null);

  bool get isFailure => !isSuccess;
}
