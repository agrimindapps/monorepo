import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'device_uuid_generator.dart';

/// Resultado da coleta de informações do dispositivo
class DeviceInfoResult {
  const DeviceInfoResult({
    required this.deviceModel,
    required this.deviceBrand,
    required this.osVersion,
    required this.deviceUuid,
    required this.platformName,
    required this.isPhysicalDevice,
  });

  final String deviceModel;
  final String deviceBrand;
  final String osVersion;
  final String deviceUuid;
  final String platformName;
  final bool isPhysicalDevice;
}

/// Serviço responsável por coletar informações do dispositivo
///
/// Isola a lógica de coleta de informações específicas da plataforma,
/// seguindo o princípio Single Responsibility.

class DeviceInfoCollector {
  DeviceInfoCollector(this._uuidGenerator);

  final DeviceUuidGenerator _uuidGenerator;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Coleta informações completas do dispositivo atual
  Future<DeviceInfoResult> getCurrentDeviceInfo() async {
    final uuid = await _uuidGenerator.generateDeviceUuid();
    final platformName = await _getPlatformName();
    final isPhysical = await _isPhysicalDevice();

    if (Platform.isAndroid) {
      return _getAndroidInfo(uuid, platformName, isPhysical);
    } else if (Platform.isIOS) {
      return _getIosInfo(uuid, platformName, isPhysical);
    } else if (Platform.isMacOS) {
      return _getMacOsInfo(uuid, platformName, isPhysical);
    } else if (Platform.isWindows) {
      return _getWindowsInfo(uuid, platformName, isPhysical);
    }

    // Fallback para plataformas não suportadas
    return DeviceInfoResult(
      deviceModel: 'Unknown Device',
      deviceBrand: 'Unknown Brand',
      osVersion: 'Unknown',
      deviceUuid: uuid,
      platformName: platformName,
      isPhysicalDevice: isPhysical,
    );
  }

  /// Coleta informações de dispositivos Android
  Future<DeviceInfoResult> _getAndroidInfo(
    String uuid,
    String platformName,
    bool isPhysical,
  ) async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;

    return DeviceInfoResult(
      deviceModel: androidInfo.model,
      deviceBrand: androidInfo.brand,
      osVersion: 'Android ${androidInfo.version.release}',
      deviceUuid: uuid,
      platformName: platformName,
      isPhysicalDevice: isPhysical && !androidInfo.isPhysicalDevice,
    );
  }

  /// Coleta informações de dispositivos iOS
  Future<DeviceInfoResult> _getIosInfo(
    String uuid,
    String platformName,
    bool isPhysical,
  ) async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;

    return DeviceInfoResult(
      deviceModel: iosInfo.model,
      deviceBrand: 'Apple',
      osVersion: 'iOS ${iosInfo.systemVersion}',
      deviceUuid: uuid,
      platformName: platformName,
      isPhysicalDevice: isPhysical && iosInfo.isPhysicalDevice,
    );
  }

  /// Coleta informações de dispositivos macOS
  Future<DeviceInfoResult> _getMacOsInfo(
    String uuid,
    String platformName,
    bool isPhysical,
  ) async {
    final macInfo = await _deviceInfoPlugin.macOsInfo;

    return DeviceInfoResult(
      deviceModel: macInfo.model,
      deviceBrand: 'Apple',
      osVersion: 'macOS ${macInfo.osRelease}',
      deviceUuid: uuid,
      platformName: platformName,
      isPhysicalDevice: isPhysical,
    );
  }

  /// Coleta informações de dispositivos Windows
  Future<DeviceInfoResult> _getWindowsInfo(
    String uuid,
    String platformName,
    bool isPhysical,
  ) async {
    final windowsInfo = await _deviceInfoPlugin.windowsInfo;

    return DeviceInfoResult(
      deviceModel: windowsInfo.productName,
      deviceBrand: 'Microsoft',
      osVersion: windowsInfo.displayVersion,
      deviceUuid: uuid,
      platformName: platformName,
      isPhysicalDevice: isPhysical,
    );
  }

  /// Obtém o nome da plataforma
  Future<String> _getPlatformName() async {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Verifica se é um dispositivo físico
  Future<bool> _isPhysicalDevice() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return iosInfo.isPhysicalDevice;
    }
    return true;
  }

  /// Obtém informações resumidas do dispositivo (para logs e debug)
  Future<String> getDeviceInfoSummary() async {
    final info = await getCurrentDeviceInfo();
    return '${info.deviceBrand} ${info.deviceModel} (${info.osVersion}) - '
        '${info.platformName} - UUID: ${info.deviceUuid.substring(0, 8)}...';
  }
}
