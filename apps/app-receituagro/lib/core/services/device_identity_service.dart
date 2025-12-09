import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Serviço de identificação única de dispositivos
class DeviceIdentityService {
  static DeviceIdentityService? _instance;
  static DeviceIdentityService get instance =>
      _instance ??= DeviceIdentityService._();

  DeviceIdentityService._()
    : _deviceInfo = DeviceInfoPlugin(),
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  final DeviceInfoPlugin _deviceInfo;
  final FlutterSecureStorage _secureStorage;

  static const String _deviceUuidKey = 'device_uuid_v2';
  static const String _deviceInfoKey = 'device_info_cache';

  /// Obtém ou cria um UUID único e persistente para o dispositivo
  Future<String> getDeviceUuid() async {
    try {
      String? existingUuid = await _secureStorage.read(key: _deviceUuidKey);
      if (existingUuid != null && existingUuid.isNotEmpty) {
        return existingUuid;
      }
      final deviceData = await _getDeviceIdentifiers();
      final uuid = _generateStableUuid(deviceData);
      await _secureStorage.write(key: _deviceUuidKey, value: uuid);

      return uuid;
    } catch (e) {
      final fallbackUuid = _generateFallbackUuid();
      await _secureStorage.write(key: _deviceUuidKey, value: fallbackUuid);
      return fallbackUuid;
    }
  }

  /// Obtém informações completas do dispositivo
  Future<DeviceInfo> getDeviceInfo() async {
    try {
      final cachedInfo = await _getCachedDeviceInfo();
      if (cachedInfo != null && _isCacheValid(cachedInfo)) {
        return cachedInfo;
      }
      final deviceInfo = await _getCurrentDeviceInfo();
      await _cacheDeviceInfo(deviceInfo);

      return deviceInfo;
    } catch (e) {
      return DeviceInfo.fallback();
    }
  }

  /// Força atualização das informações do dispositivo
  Future<DeviceInfo> refreshDeviceInfo() async {
    await _secureStorage.delete(key: _deviceInfoKey);
    return await getDeviceInfo();
  }

  /// Verifica se o dispositivo mudou significativamente
  Future<bool> hasDeviceChanged() async {
    try {
      final cachedInfo = await _getCachedDeviceInfo();
      if (cachedInfo == null) return false;

      final currentInfo = await _getCurrentDeviceInfo();
      return cachedInfo.platform != currentInfo.platform ||
          cachedInfo.model != currentInfo.model ||
          cachedInfo.systemVersion != currentInfo.systemVersion;
    } catch (e) {
      return false;
    }
  }

  /// Obtém informações atuais do dispositivo
  Future<DeviceInfo> _getCurrentDeviceInfo() async {
    final uuid = await getDeviceUuid();
    final packageInfo = await PackageInfo.fromPlatform();

    // Web platform
    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return DeviceInfo(
        uuid: uuid,
        name: '${webInfo.browserName} on ${webInfo.platform ?? 'Web'}',
        model: webInfo.browserName.toString(),
        platform: 'Web',
        systemVersion: webInfo.appVersion ?? 'unknown',
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        identifier: webInfo.userAgent ?? uuid,
        isPhysicalDevice: false,
        manufacturer: 'Web Browser',
        firstLoginAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        isActive: true,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return DeviceInfo(
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
      final androidInfo = await _deviceInfo.androidInfo;
      return DeviceInfo(
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
    }

    // Fallback for other platforms
    return DeviceInfo(
      uuid: uuid,
      name: 'Unknown Device',
      model: 'Unknown',
      platform: 'Unknown',
      systemVersion: 'Unknown',
      appVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      identifier: uuid,
      isPhysicalDevice: false,
      manufacturer: 'Unknown',
      firstLoginAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
      isActive: true,
    );
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

  /// Obtém identificadores únicos do dispositivo
  Future<Map<String, String>> _getDeviceIdentifiers() async {
    final identifiers = <String, String>{};

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        identifiers['platform'] = 'web';
        identifiers['browser'] = webInfo.browserName.toString();
        identifiers['userAgent'] = webInfo.userAgent ?? 'unknown';
        identifiers['vendor'] = webInfo.vendor ?? 'unknown';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        identifiers['platform'] = 'ios';
        identifiers['model'] = iosInfo.model;
        identifiers['systemVersion'] = iosInfo.systemVersion;
        identifiers['localizedModel'] = iosInfo.localizedModel;
        if (iosInfo.identifierForVendor != null) {
          identifiers['vendorId'] = iosInfo.identifierForVendor!;
        }
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        identifiers['platform'] = 'android';
        identifiers['model'] = androidInfo.model;
        identifiers['brand'] = androidInfo.brand;
        identifiers['device'] = androidInfo.device;
        identifiers['product'] = androidInfo.product;
        identifiers['androidId'] = androidInfo.id;
        identifiers['fingerprint'] = androidInfo.fingerprint;
      }
      final packageInfo = await PackageInfo.fromPlatform();
      identifiers['packageName'] = packageInfo.packageName;
    } catch (e) {
      identifiers['platform'] = kIsWeb ? 'web' : 'unknown';
      identifiers['timestamp'] =
          DateTime.now().millisecondsSinceEpoch.toString();
    }

    return identifiers;
  }

  /// Gera UUID estável baseado em características do dispositivo
  String _generateStableUuid(Map<String, String> identifiers) {
    final sortedKeys = identifiers.keys.toList()..sort();
    final identifierString = sortedKeys
        .map((key) => '$key=${identifiers[key]}')
        .join('|');
    final bytes = utf8.encode(identifierString);
    final digest = sha256.convert(bytes);
    final hexString = digest.toString();
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  /// Gera UUID de fallback em caso de erro
  String _generateFallbackUuid() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    final platform = kIsWeb ? 'web' : 'unk';

    return 'fallback-$platform-$timestamp-$random';
  }

  /// Obtém informações de dispositivo do cache
  Future<DeviceInfo?> _getCachedDeviceInfo() async {
    try {
      final cachedData = await _secureStorage.read(key: _deviceInfoKey);
      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      return DeviceInfo.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  /// Armazena informações do dispositivo em cache
  Future<void> _cacheDeviceInfo(DeviceInfo deviceInfo) async {
    try {
      final data = deviceInfo.toMap();
      data['cachedAt'] = DateTime.now().millisecondsSinceEpoch;

      final jsonData = jsonEncode(data);
      await _secureStorage.write(key: _deviceInfoKey, value: jsonData);
    } catch (e) {
    }
  }

  /// Verifica se o cache ainda é válido (24 horas)
  bool _isCacheValid(DeviceInfo cachedInfo) {
    try {
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        cachedInfo.toMap()['cachedAt'] as int? ?? 0,
      );

      final age = DateTime.now().difference(cachedAt);
      return age.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  /// Limpa dados armazenados (útil para logout completo)
  Future<void> clearStoredData() async {
    await Future.wait([
      _secureStorage.delete(key: _deviceUuidKey),
      _secureStorage.delete(key: _deviceInfoKey),
    ]);
  }
}

/// Modelo de informações do dispositivo
class DeviceInfo {
  const DeviceInfo({
    required this.uuid,
    required this.name,
    required this.model,
    required this.platform,
    required this.systemVersion,
    required this.appVersion,
    required this.buildNumber,
    required this.identifier,
    required this.isPhysicalDevice,
    required this.manufacturer,
    required this.firstLoginAt,
    required this.lastActiveAt,
    required this.isActive,
  });

  final String uuid;
  final String name;
  final String model;
  final String platform;
  final String systemVersion;
  final String appVersion;
  final String buildNumber;
  final String identifier;
  final bool isPhysicalDevice;
  final String manufacturer;
  final DateTime firstLoginAt;
  final DateTime lastActiveAt;
  final bool isActive;

  /// Nome para exibição
  String get displayName => '$name • $platform $systemVersion';

  /// Versão completa da aplicação
  String get fullAppVersion => '$appVersion ($buildNumber)';

  /// Indica se é dispositivo de desenvolvimento
  bool get isDevelopmentDevice => !isPhysicalDevice;

  /// Cria instância com valores de fallback
  factory DeviceInfo.fallback() => DeviceInfo(
    uuid: 'unknown-device',
    name: 'Unknown Device',
    model: 'Unknown',
    platform: Platform.operatingSystem,
    systemVersion: 'Unknown',
    appVersion: '1.0.0',
    buildNumber: '1',
    identifier: 'unknown',
    isPhysicalDevice: true,
    manufacturer: 'Unknown',
    firstLoginAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
    isActive: true,
  );

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() => {
    'uuid': uuid,
    'name': name,
    'model': model,
    'platform': platform,
    'systemVersion': systemVersion,
    'appVersion': appVersion,
    'buildNumber': buildNumber,
    'identifier': identifier,
    'isPhysicalDevice': isPhysicalDevice,
    'manufacturer': manufacturer,
    'firstLoginAt': firstLoginAt.millisecondsSinceEpoch,
    'lastActiveAt': lastActiveAt.millisecondsSinceEpoch,
    'isActive': isActive,
  };

  /// Cria instância a partir de Map
  static DeviceInfo fromMap(Map<String, dynamic> map) => DeviceInfo(
    uuid: map['uuid'] as String? ?? 'unknown',
    name: map['name'] as String? ?? 'Unknown Device',
    model: map['model'] as String? ?? 'Unknown',
    platform: map['platform'] as String? ?? 'unknown',
    systemVersion: map['systemVersion'] as String? ?? 'Unknown',
    appVersion: map['appVersion'] as String? ?? '1.0.0',
    buildNumber: map['buildNumber'] as String? ?? '1',
    identifier: map['identifier'] as String? ?? 'unknown',
    isPhysicalDevice: map['isPhysicalDevice'] as bool? ?? true,
    manufacturer: map['manufacturer'] as String? ?? 'Unknown',
    firstLoginAt: DateTime.fromMillisecondsSinceEpoch(
      map['firstLoginAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    ),
    lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
      map['lastActiveAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    ),
    isActive: map['isActive'] as bool? ?? true,
  );

  @override
  String toString() => 'DeviceInfo(uuid: $uuid, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}
