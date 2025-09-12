import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Serviço de identificação única de dispositivos
class DeviceIdentityService {
  DeviceIdentityService()
      : _deviceInfo = DeviceInfoPlugin(),
        _secureStorage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
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
      // 1. Tentar recuperar UUID existente
      String? existingUuid = await _secureStorage.read(key: _deviceUuidKey);
      if (existingUuid != null && existingUuid.isNotEmpty) {
        return existingUuid;
      }

      // 2. Gerar novo UUID baseado em características únicas do dispositivo
      final deviceData = await _getDeviceIdentifiers();
      final uuid = _generateStableUuid(deviceData);

      // 3. Armazenar de forma segura
      await _secureStorage.write(key: _deviceUuidKey, value: uuid);
      
      return uuid;
    } catch (e) {
      // Fallback: gerar UUID baseado apenas em timestamp
      final fallbackUuid = _generateFallbackUuid();
      await _secureStorage.write(key: _deviceUuidKey, value: fallbackUuid);
      return fallbackUuid;
    }
  }

  /// Obtém informações completas do dispositivo
  Future<DeviceInfo> getDeviceInfo() async {
    try {
      // Verificar cache
      final cachedInfo = await _getCachedDeviceInfo();
      if (cachedInfo != null && _isCacheValid(cachedInfo)) {
        return cachedInfo;
      }

      // Obter informações atuais
      final deviceInfo = await _getCurrentDeviceInfo();
      
      // Armazenar em cache
      await _cacheDeviceInfo(deviceInfo);
      
      return deviceInfo;
    } catch (e) {
      // Retornar informações básicas em caso de erro
      return DeviceInfo.fallback();
    }
  }

  /// Força atualização das informações do dispositivo
  Future<DeviceInfo> refreshDeviceInfo() async {
    // Limpar cache
    await _secureStorage.delete(key: _deviceInfoKey);
    
    // Obter informações atualizadas
    return await getDeviceInfo();
  }

  /// Verifica se o dispositivo mudou significativamente
  Future<bool> hasDeviceChanged() async {
    try {
      final cachedInfo = await _getCachedDeviceInfo();
      if (cachedInfo == null) return false;

      final currentInfo = await _getCurrentDeviceInfo();
      
      // Verificar mudanças críticas
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
    
    throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
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
      if (Platform.isIOS) {
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

      // Adicionar informações da aplicação
      final packageInfo = await PackageInfo.fromPlatform();
      identifiers['packageName'] = packageInfo.packageName;
      
    } catch (e) {
      // Em caso de erro, usar identificadores mínimos
      identifiers['platform'] = Platform.operatingSystem;
      identifiers['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return identifiers;
  }

  /// Gera UUID estável baseado em características do dispositivo
  String _generateStableUuid(Map<String, String> identifiers) {
    // Criar string determinística com os identificadores
    final sortedKeys = identifiers.keys.toList()..sort();
    final identifierString = sortedKeys
        .map((key) => '$key=${identifiers[key]}')
        .join('|');

    // Gerar hash SHA-256
    final bytes = utf8.encode(identifierString);
    final digest = sha256.convert(bytes);
    
    // Converter para formato UUID (32 caracteres hexadecimais)
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
    final platform = Platform.operatingSystem.substring(0, 3);
    
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
      // Ignorar erros de cache
    }
  }

  /// Verifica se o cache ainda é válido (24 horas)
  bool _isCacheValid(DeviceInfo cachedInfo) {
    try {
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        cachedInfo.toMap()['cachedAt'] as int? ?? 0
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
      map['firstLoginAt'] as int? ?? DateTime.now().millisecondsSinceEpoch
    ),
    lastActiveAt: DateTime.fromMillisecondsSinceEpoch(
      map['lastActiveAt'] as int? ?? DateTime.now().millisecondsSinceEpoch
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