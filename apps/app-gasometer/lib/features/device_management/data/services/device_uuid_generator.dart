import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/enums.dart';

/// Serviço responsável por gerar e gerenciar UUIDs de dispositivos
///
/// Centraliza a lógica de geração de identificadores únicos,
/// seguindo o princípio Single Responsibility.

class DeviceUuidGenerator {
  DeviceUuidGenerator();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();

  /// Gera um UUID único para o dispositivo baseado nas características do hardware
  ///
  /// Retorna um UUID v5 baseado em informações únicas do dispositivo,
  /// ou um UUID v4 aleatório se não for possível obter informações únicas
  Future<String> generateDeviceUuid() async {
    try {
      if (Platform.isAndroid) {
        return _generateAndroidUuid();
      } else if (Platform.isIOS) {
        return _generateIosUuid();
      } else if (Platform.isMacOS) {
        return _generateMacOsUuid();
      } else if (Platform.isWindows) {
        return _generateWindowsUuid();
      }

      // Fallback: UUID v4 aleatório para plataformas não suportadas
      return _uuid.v4();
    } catch (e) {
      // Em caso de erro, gera um UUID v4 aleatório
      return _uuid.v4();
    }
  }

  /// Gera UUID para dispositivos Android usando androidId
  Future<String> _generateAndroidUuid() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;

    // Usa androidId como seed para UUID v5
    final androidId = androidInfo.id;

    // Namespace para dispositivos Android (namespace URL do app)
    final namespace = Namespace.url.value;

    return _uuid.v5(namespace, 'android:$androidId');
  }

  /// Gera UUID para dispositivos iOS usando identifierForVendor
  Future<String> _generateIosUuid() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;

    // identifierForVendor é único por vendor e dispositivo
    final vendorId = iosInfo.identifierForVendor ?? _uuid.v4();

    // Namespace para dispositivos iOS
    final namespace = Namespace.url.value;

    return _uuid.v5(namespace, 'ios:$vendorId');
  }

  /// Gera UUID para dispositivos macOS usando serialNumber
  Future<String> _generateMacOsUuid() async {
    final macInfo = await _deviceInfoPlugin.macOsInfo;

    // Usa uma combinação de informações únicas
    final uniqueString = '${macInfo.systemGUID}-${macInfo.computerName}';

    final namespace = Namespace.url.value;

    return _uuid.v5(namespace, 'macos:$uniqueString');
  }

  /// Gera UUID para dispositivos Windows usando deviceId
  Future<String> _generateWindowsUuid() async {
    final windowsInfo = await _deviceInfoPlugin.windowsInfo;

    // Usa o deviceId do Windows
    final deviceId = windowsInfo.deviceId;

    final namespace = Namespace.url.value;

    return _uuid.v5(namespace, 'windows:$deviceId');
  }

  /// Valida se um UUID está no formato correto
  bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    return uuidRegex.hasMatch(uuid);
  }

  /// Gera um UUID temporário (v4 aleatório)
  ///
  /// Útil para dispositivos em modo guest ou durante migrações
  String generateTemporaryUuid() {
    return _uuid.v4();
  }

  /// Compara se dois UUIDs são equivalentes (case-insensitive)
  bool areUuidsEqual(String uuid1, String uuid2) {
    return uuid1.toLowerCase() == uuid2.toLowerCase();
  }
}
