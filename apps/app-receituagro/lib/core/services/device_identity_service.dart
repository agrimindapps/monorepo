import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Serviço para gerenciar a identidade única do dispositivo
/// Gera e armazena um UUID único por instalação do app para usuários não autenticados
class DeviceIdentityService {
  static const String _deviceUuidKey = 'device_uuid_v1';
  static const String _installationTimestampKey = 'installation_timestamp';
  
  static const Uuid _uuid = Uuid();
  
  /// Singleton instance
  static DeviceIdentityService? _instance;
  
  /// SharedPreferences instance
  SharedPreferences? _prefs;
  
  /// Cached device UUID
  String? _cachedDeviceUuid;
  
  /// Private constructor
  DeviceIdentityService._();
  
  /// Get singleton instance
  static DeviceIdentityService get instance {
    _instance ??= DeviceIdentityService._();
    return _instance!;
  }
  
  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Obtém o UUID único do dispositivo
  /// Gera um novo se não existir
  Future<String> getDeviceUuid() async {
    if (_cachedDeviceUuid != null) {
      return _cachedDeviceUuid!;
    }
    
    await initialize();
    
    // Tenta recuperar UUID existente
    _cachedDeviceUuid = _prefs!.getString(_deviceUuidKey);
    
    if (_cachedDeviceUuid == null || _cachedDeviceUuid!.isEmpty) {
      // Gera novo UUID e armazena
      _cachedDeviceUuid = await _generateAndStoreDeviceUuid();
    }
    
    return _cachedDeviceUuid!;
  }
  
  /// Gera um novo UUID e armazena
  Future<String> _generateAndStoreDeviceUuid() async {
    await initialize();
    
    final newUuid = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Armazena o UUID e timestamp da instalação
    await _prefs!.setString(_deviceUuidKey, newUuid);
    await _prefs!.setInt(_installationTimestampKey, timestamp);
    
    return newUuid;
  }
  
  /// Obtém timestamp da primeira instalação/geração do UUID
  Future<DateTime?> getInstallationTimestamp() async {
    await initialize();
    
    final timestamp = _prefs!.getInt(_installationTimestampKey);
    if (timestamp == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Força a regeneração do UUID (usar com cuidado)
  /// Isso irá "resetar" a identidade do usuário não autenticado
  Future<String> regenerateDeviceUuid() async {
    _cachedDeviceUuid = null;
    return await _generateAndStoreDeviceUuid();
  }
  
  /// Limpa o UUID do dispositivo (para reset completo)
  Future<void> clearDeviceUuid() async {
    await initialize();
    
    await _prefs!.remove(_deviceUuidKey);
    await _prefs!.remove(_installationTimestampKey);
    _cachedDeviceUuid = null;
  }
  
  /// Verifica se o dispositivo já possui um UUID
  Future<bool> hasDeviceUuid() async {
    await initialize();
    
    final uuid = _prefs!.getString(_deviceUuidKey);
    return uuid != null && uuid.isNotEmpty;
  }
  
  /// Obtém informações do dispositivo para debug
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final uuid = await getDeviceUuid();
    final installationTime = await getInstallationTimestamp();
    
    return {
      'deviceUuid': uuid,
      'installationTimestamp': installationTime?.millisecondsSinceEpoch,
      'installationDate': installationTime?.toIso8601String(),
      'isNewInstallation': installationTime != null 
          ? DateTime.now().difference(installationTime).inDays < 1
          : false,
    };
  }
}