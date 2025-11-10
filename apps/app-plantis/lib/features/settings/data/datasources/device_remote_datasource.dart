import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart';

/// Datasource remoto para gerenciamento de dispositivos via Firebase
class DeviceRemoteDataSource {
  final FirebaseFirestore _firestore;

  DeviceRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Obtém todos os dispositivos de um usuário do Firestore
  Future<List<DeviceEntity>> getUserDevices(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .orderBy('lastActiveAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DeviceEntity.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw ServerFailure(
        'Erro ao buscar dispositivos do servidor',
        code: 'GET_DEVICES_ERROR',
        details: e,
      );
    }
  }

  /// Revoga um dispositivo específico no Firestore
  Future<bool> revokeDevice(String userId, String deviceUuid) async {
    try {
      // Busca o documento do dispositivo
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .where('uuid', isEqualTo: deviceUuid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const NotFoundFailure(
          'Dispositivo não encontrado',
          code: 'DEVICE_NOT_FOUND',
        );
      }

      final deviceDoc = snapshot.docs.first;

      // Atualiza status para inativo
      await deviceDoc.reference.update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      if (e is Failure) rethrow;

      throw ServerFailure(
        'Erro ao revogar dispositivo',
        code: 'REVOKE_DEVICE_ERROR',
        details: e,
      );
    }
  }

  /// Obtém informações do dispositivo atual
  Future<DeviceEntity> getCurrentDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return DeviceEntity(
          id: '',
          uuid: _generateWebUuid(webInfo),
          name: webInfo.browserName.name,
          model: '${webInfo.browserName.name} ${webInfo.appVersion ?? 'Unknown'}',
          platform: 'web',
          systemVersion: webInfo.platform ?? 'Unknown',
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          isPhysicalDevice: true,
          manufacturer: webInfo.vendor ?? 'Unknown',
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      }

      // Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return DeviceEntity(
          id: '',
          uuid: androidInfo.id,
          name: androidInfo.device,
          model: androidInfo.model,
          platform: 'Android',
          systemVersion: 'Android ${androidInfo.version.release}',
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
          manufacturer: androidInfo.manufacturer,
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      }

      // iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceEntity(
          id: '',
          uuid: iosInfo.identifierForVendor ?? '',
          name: iosInfo.name,
          model: iosInfo.model,
          platform: 'iOS',
          systemVersion: 'iOS ${iosInfo.systemVersion}',
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          isPhysicalDevice: iosInfo.isPhysicalDevice,
          manufacturer: 'Apple',
          firstLoginAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      }

      // Fallback para outras plataformas
      return DeviceEntity(
        id: '',
        uuid: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Unknown Device',
        model: 'Unknown',
        platform: defaultTargetPlatform.name,
        systemVersion: 'Unknown',
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        isPhysicalDevice: true,
        manufacturer: 'Unknown',
        firstLoginAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerFailure(
        'Erro ao obter informações do dispositivo',
        code: 'GET_DEVICE_INFO_ERROR',
        details: e,
      );
    }
  }

  /// Gera UUID para dispositivos web (baseado em características do navegador)
  String _generateWebUuid(WebBrowserInfo info) {
    final components = [
      info.browserName.name,
      info.platform ?? '',
      info.vendor ?? '',
      info.userAgent ?? '',
    ].join('_');

    return components.hashCode.toString();
  }
}
