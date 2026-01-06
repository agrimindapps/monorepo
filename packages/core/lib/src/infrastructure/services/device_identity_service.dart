import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../domain/entities/device_entity.dart';

/// Serviço de identificação única de dispositivos
///
/// Este serviço é responsável por:
/// - Gerar e persistir um UUID único para o dispositivo
/// - Coletar informações do dispositivo (modelo, SO, etc.)
/// - Criar DeviceEntity a partir das informações coletadas
///
/// Usado por todos os apps do monorepo para gerenciamento de dispositivos.
class DeviceIdentityService {
  DeviceIdentityService({
    DeviceInfoPlugin? deviceInfo,
    FlutterSecureStorage? secureStorage,
  })  : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  final DeviceInfoPlugin _deviceInfo;
  final FlutterSecureStorage _secureStorage;

  static const String _deviceUuidKey = 'device_uuid_v2';
  static const String _deviceInfoKey = 'device_info_cache';

  // Singleton pattern para uso global
  static DeviceIdentityService? _instance;
  static DeviceIdentityService get instance =>
      _instance ??= DeviceIdentityService();

  /// Obtém ou cria um UUID único e persistente para o dispositivo
  Future<String> getDeviceUuid() async {
    try {
      final existingUuid = await _secureStorage.read(key: _deviceUuidKey);
      if (existingUuid != null && existingUuid.isNotEmpty) {
        return existingUuid;
      }

      final deviceData = await _getDeviceIdentifiers();
      final uuid = _generateStableUuid(deviceData);
      await _secureStorage.write(key: _deviceUuidKey, value: uuid);

      return uuid;
    } catch (e) {
      final fallbackUuid = _generateFallbackUuid();
      try {
        await _secureStorage.write(key: _deviceUuidKey, value: fallbackUuid);
      } catch (_) {
        // Ignore storage errors for fallback
      }
      return fallbackUuid;
    }
  }

  /// Obtém informações completas do dispositivo como DeviceEntity
  Future<DeviceEntity> getCurrentDeviceEntity() async {
    try {
      final cachedEntity = await _getCachedDeviceEntity();
      if (cachedEntity != null && _isCacheValid(cachedEntity)) {
        return cachedEntity;
      }

      final deviceEntity = await _buildCurrentDeviceEntity();
      await _cacheDeviceEntity(deviceEntity);

      return deviceEntity;
    } catch (e) {
      return _createFallbackEntity();
    }
  }

  /// Força atualização das informações do dispositivo
  Future<DeviceEntity> refreshDeviceInfo() async {
    await _secureStorage.delete(key: _deviceInfoKey);
    return getCurrentDeviceEntity();
  }

  /// Verifica se o dispositivo mudou significativamente
  Future<bool> hasDeviceChanged() async {
    try {
      final cachedEntity = await _getCachedDeviceEntity();
      if (cachedEntity == null) return false;

      final currentEntity = await _buildCurrentDeviceEntity();
      return cachedEntity.platform != currentEntity.platform ||
          cachedEntity.model != currentEntity.model ||
          cachedEntity.systemVersion != currentEntity.systemVersion;
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

  /// Constrói DeviceEntity com informações atuais do dispositivo
  Future<DeviceEntity> _buildCurrentDeviceEntity() async {
    final uuid = await getDeviceUuid();
    final packageInfo = await PackageInfo.fromPlatform();
    final now = DateTime.now();

    // Web platform
    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return DeviceEntity(
        id: uuid,
        uuid: uuid,
        name: '${webInfo.browserName} on ${webInfo.platform ?? 'Web'}',
        model: webInfo.browserName.toString(),
        platform: 'web',
        systemVersion: webInfo.appVersion ?? 'unknown',
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: false,
        manufacturer: 'Web Browser',
        firstLoginAt: now,
        lastActiveAt: now,
        isActive: true,
        createdAt: now,
      );
    }

    // iOS platform
    if (_isIOS()) {
      final iosInfo = await _deviceInfo.iosInfo;
      return DeviceEntity(
        id: uuid,
        uuid: uuid,
        name: iosInfo.name,
        model: iosInfo.model,
        platform: 'ios',
        systemVersion: iosInfo.systemVersion,
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        manufacturer: 'Apple',
        firstLoginAt: now,
        lastActiveAt: now,
        isActive: true,
        createdAt: now,
      );
    }

    // Android platform
    if (_isAndroid()) {
      final androidInfo = await _deviceInfo.androidInfo;
      return DeviceEntity(
        id: uuid,
        uuid: uuid,
        name: _generateFriendlyName(androidInfo),
        model: androidInfo.model,
        platform: 'android',
        systemVersion: androidInfo.version.release,
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        manufacturer: androidInfo.manufacturer,
        firstLoginAt: now,
        lastActiveAt: now,
        isActive: true,
        createdAt: now,
      );
    }

    // Fallback for other platforms (macOS, Windows, Linux)
    return _createFallbackEntity();
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
      } else if (_isIOS()) {
        final iosInfo = await _deviceInfo.iosInfo;
        identifiers['platform'] = 'ios';
        identifiers['model'] = iosInfo.model;
        identifiers['systemVersion'] = iosInfo.systemVersion;
        identifiers['localizedModel'] = iosInfo.localizedModel;
        if (iosInfo.identifierForVendor != null) {
          identifiers['vendorId'] = iosInfo.identifierForVendor!;
        }
      } else if (_isAndroid()) {
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
    final identifierString =
        sortedKeys.map((key) => '$key=${identifiers[key]}').join('|');
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
    const platform = kIsWeb ? 'web' : 'unk';

    return 'fallback-$platform-$timestamp-$random';
  }

  /// Obtém DeviceEntity do cache
  Future<DeviceEntity?> _getCachedDeviceEntity() async {
    try {
      final cachedData = await _secureStorage.read(key: _deviceInfoKey);
      if (cachedData == null) return null;

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      return DeviceEntity.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Armazena DeviceEntity em cache
  Future<void> _cacheDeviceEntity(DeviceEntity entity) async {
    try {
      final data = entity.toJson();
      data['cachedAt'] = DateTime.now().millisecondsSinceEpoch;

      final jsonData = jsonEncode(data);
      await _secureStorage.write(key: _deviceInfoKey, value: jsonData);
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Verifica se o cache ainda é válido (24 horas)
  bool _isCacheValid(DeviceEntity cachedEntity) {
    try {
      final json = cachedEntity.toJson();
      final cachedAt = json['cachedAt'] as int?;
      if (cachedAt == null) return false;

      final cachedDate = DateTime.fromMillisecondsSinceEpoch(cachedAt);
      final age = DateTime.now().difference(cachedDate);
      return age.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  /// Cria entidade de fallback
  DeviceEntity _createFallbackEntity() {
    final now = DateTime.now();
    final uuid = 'unknown-device-${now.millisecondsSinceEpoch}';
    
    return DeviceEntity(
      id: uuid,
      uuid: uuid,
      name: 'Unknown Device',
      model: 'Unknown',
      platform: _getPlatformString(),
      systemVersion: 'Unknown',
      appVersion: '1.0.0',
      buildNumber: '1',
      isPhysicalDevice: true,
      manufacturer: 'Unknown',
      firstLoginAt: now,
      lastActiveAt: now,
      isActive: true,
      createdAt: now,
    );
  }

  /// Retorna string da plataforma atual
  String _getPlatformString() {
    if (kIsWeb) return 'web';
    if (_isIOS()) return 'ios';
    if (_isAndroid()) return 'android';
    return 'unknown';
  }

  /// Verifica se é iOS (sem usar dart:io diretamente para compatibilidade web)
  bool _isIOS() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Verifica se é Android (sem usar dart:io diretamente para compatibilidade web)
  bool _isAndroid() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }
}

