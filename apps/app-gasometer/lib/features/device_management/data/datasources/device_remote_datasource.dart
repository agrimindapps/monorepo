import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/error/failures.dart';
import '../models/device_info_model.dart';
import '../models/device_statistics_model.dart';

/// Data source remoto para gerenciamento de dispositivos usando Firestore
@lazySingleton
class DeviceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final DeviceInfoPlugin _deviceInfoPlugin;
  
  /// Limite máximo de dispositivos por usuário
  static const int _deviceLimit = 3;
  
  /// Timeout para operações Firestore
  static const Duration _operationTimeout = Duration(seconds: 30);

  DeviceRemoteDataSource({
    FirebaseFirestore? firestore,
    DeviceInfoPlugin? deviceInfoPlugin,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  /// Coleção de dispositivos no Firestore
  CollectionReference get _devicesCollection => 
      _firestore.collection('user_devices');


  /// Obtém dispositivos de um usuário
  Future<Either<Failure, List<DeviceInfoModel>>> getUserDevices(
    String userId,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRemoteDataSource: Getting devices for user $userId');
      }

      final querySnapshot = await _devicesCollection
          .doc(userId)
          .collection('devices')
          .orderBy('lastActiveAt', descending: true)
          .get()
          .timeout(_operationTimeout);

      final devices = querySnapshot.docs
          .map((doc) => DeviceInfoModel.fromFirestore(
                {...doc.data(), 'uuid': doc.id},
              ))
          .toList();

      if (kDebugMode) {
        debugPrint('✅ DeviceRemoteDataSource: Got ${devices.length} devices');
      }

      return Right(devices);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao buscar dispositivos'),
      );
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRemoteDataSource: Firebase error - ${e.code}: ${e.message}');
      }
      return Left(
        ServerFailure('Erro ao buscar dispositivos: ${e.message}'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRemoteDataSource: Unexpected error - $e');
      }
      return Left(
        ServerFailure('Erro inesperado ao buscar dispositivos'),
      );
    }
  }

  /// Valida e registra um dispositivo
  Future<Either<Failure, DeviceInfoModel>> validateDevice(
    String userId,
    DeviceInfoModel device,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRemoteDataSource: Validating device ${device.uuid}');
      }

      // Usar transação para evitar race conditions
      return await _firestore.runTransaction<Either<Failure, DeviceInfoModel>>(
        (transaction) async {
          final userDevicesRef = _devicesCollection.doc(userId).collection('devices');
          final deviceRef = userDevicesRef.doc(device.uuid);
          
          // Verificar se dispositivo já existe
          final deviceDoc = await transaction.get(deviceRef);
          
          if (deviceDoc.exists) {
            // Dispositivo já registrado, atualizar atividade
            final existingDevice = DeviceInfoModel.fromFirestore({
              ...deviceDoc.data() as Map<String, dynamic>,
              'uuid': deviceDoc.id,
            });
            
            final updatedDevice = existingDevice.copyWith(
              lastActiveAt: DateTime.now(),
              isActive: true,
            );
            
            transaction.update(deviceRef, updatedDevice.toFirestore());
            
            if (kDebugMode) {
              debugPrint('✅ DeviceRemoteDataSource: Updated existing device');
            }
            
            return Right(updatedDevice);
          }
          
          // Novo dispositivo - verificar limite
          final existingDevicesQuery = await userDevicesRef.get();
          final activeDevicesCount = existingDevicesQuery.docs
              .where((doc) {
                final data = doc.data();
                return data['isActive'] as bool? ?? false;
              })
              .length;
          
          if (activeDevicesCount >= _deviceLimit) {
            return const Left(
              ValidationFailure(
                'Limite de dispositivos atingido. Máximo de $_deviceLimit dispositivos simultâneos.',
              ),
            );
          }
          
          // Registrar novo dispositivo
          final newDevice = device.copyWith(
            firstLoginAt: DateTime.now(),
            lastActiveAt: DateTime.now(),
            isActive: true,
          );
          
          transaction.set(deviceRef, newDevice.toFirestore());
          
          if (kDebugMode) {
            debugPrint('✅ DeviceRemoteDataSource: Registered new device');
          }
          
          return Right(newDevice);
        },
        timeout: _operationTimeout,
      );
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao validar dispositivo'),
      );
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRemoteDataSource: Validation Firebase error - ${e.code}');
      }
      return Left(
        ServerFailure('Erro ao validar dispositivo: ${e.message}'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ DeviceRemoteDataSource: Validation unexpected error - $e');
      }
      return Left(
        ServerFailure('Erro inesperado ao validar dispositivo'),
      );
    }
  }

  /// Revoga acesso de um dispositivo
  Future<Either<Failure, Unit>> revokeDevice(
    String userId,
    String deviceUuid,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint('🔄 DeviceRemoteDataSource: Revoking device $deviceUuid');
      }

      final deviceRef = _devicesCollection
          .doc(userId)
          .collection('devices')
          .doc(deviceUuid);

      await deviceRef.update({
        'isActive': false,
        'revokedAt': FieldValue.serverTimestamp(),
      }).timeout(_operationTimeout);

      if (kDebugMode) {
        debugPrint('✅ DeviceRemoteDataSource: Device revoked successfully');
      }

      return const Right(unit);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao revogar dispositivo'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro ao revogar dispositivo: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao revogar dispositivo'),
      );
    }
  }

  /// Atualiza última atividade de um dispositivo
  Future<Either<Failure, DeviceInfoModel>> updateLastActivity(
    String userId,
    String deviceUuid,
  ) async {
    try {
      final deviceRef = _devicesCollection
          .doc(userId)
          .collection('devices')
          .doc(deviceUuid);

      await deviceRef.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }).timeout(_operationTimeout);

      // Buscar dispositivo atualizado
      final deviceDoc = await deviceRef.get().timeout(_operationTimeout);
      
      if (!deviceDoc.exists) {
        return const Left(
          UnexpectedFailure('Dispositivo não encontrado'),
        );
      }

      final updatedDevice = DeviceInfoModel.fromFirestore({
        ...deviceDoc.data() as Map<String, dynamic>,
        'uuid': deviceDoc.id,
      });

      return Right(updatedDevice);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao atualizar atividade'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro ao atualizar atividade: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao atualizar atividade'),
      );
    }
  }

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    try {
      final querySnapshot = await _devicesCollection
          .doc(userId)
          .collection('devices')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(_operationTimeout);

      final activeDevicesCount = querySnapshot.docs.length;
      return Right(activeDevicesCount < _deviceLimit);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao verificar limite'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro ao verificar limite: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao verificar limite'),
      );
    }
  }

  /// Revoga todos os outros dispositivos exceto o atual
  Future<Either<Failure, Unit>> revokeAllOtherDevices(
    String userId,
    String currentDeviceUuid,
  ) async {
    try {
      final batch = _firestore.batch();
      
      final querySnapshot = await _devicesCollection
          .doc(userId)
          .collection('devices')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(_operationTimeout);

      for (final doc in querySnapshot.docs) {
        if (doc.id != currentDeviceUuid) {
          batch.update(doc.reference, {
            'isActive': false,
            'revokedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit().timeout(_operationTimeout);
      
      return const Right(unit);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao revogar outros dispositivos'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro ao revogar outros dispositivos: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao revogar outros dispositivos'),
      );
    }
  }

  /// Remove dispositivos inativos há X dias
  Future<Either<Failure, List<DeviceInfoModel>>> cleanupInactiveDevices(
    String userId,
    int inactiveDays,
  ) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: inactiveDays));
      
      final querySnapshot = await _devicesCollection
          .doc(userId)
          .collection('devices')
          .where('lastActiveAt', isLessThan: cutoffDate)
          .get()
          .timeout(_operationTimeout);

      final batch = _firestore.batch();
      final removedDevices = <DeviceInfoModel>[];
      
      for (final doc in querySnapshot.docs) {
        final device = DeviceInfoModel.fromFirestore({
          ...doc.data(),
          'uuid': doc.id,
        });
        removedDevices.add(device);
        batch.delete(doc.reference);
      }

      await batch.commit().timeout(_operationTimeout);
      
      return Right(removedDevices);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout na limpeza de dispositivos'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro na limpeza: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado na limpeza'),
      );
    }
  }

  /// Obtém estatísticas de dispositivos
  Future<Either<Failure, DeviceStatisticsModel>> getDeviceStatistics(
    String userId,
  ) async {
    try {
      final querySnapshot = await _devicesCollection
          .doc(userId)
          .collection('devices')
          .get()
          .timeout(_operationTimeout);

      final devices = querySnapshot.docs
          .map((doc) => DeviceInfoModel.fromFirestore({
                ...doc.data(),
                'uuid': doc.id,
              }))
          .toList();

      final activeDevices = devices.where((d) => d.isActive).length;
      final devicesByPlatform = <String, int>{};
      
      for (final device in devices) {
        final platform = device.platform;
        devicesByPlatform[platform] = (devicesByPlatform[platform] ?? 0) + 1;
      }
      
      DeviceInfoModel? lastActiveDevice;
      DeviceInfoModel? oldestDevice;
      DeviceInfoModel? newestDevice;
      
      if (devices.isNotEmpty) {
        lastActiveDevice = devices.reduce(
          (a, b) => a.lastActiveAt.isAfter(b.lastActiveAt) ? a : b,
        );
        oldestDevice = devices.reduce(
          (a, b) => a.firstLoginAt.isBefore(b.firstLoginAt) ? a : b,
        );
        newestDevice = devices.reduce(
          (a, b) => a.firstLoginAt.isAfter(b.firstLoginAt) ? a : b,
        );
      }

      final statistics = DeviceStatisticsModel(
        totalDevices: devices.length,
        activeDevices: activeDevices,
        devicesByPlatform: devicesByPlatform,
        lastActiveDevice: lastActiveDevice,
        oldestDevice: oldestDevice,
        newestDevice: newestDevice,
      );

      return Right(statistics);
    } on TimeoutException {
      return const Left(
        NetworkFailure('Timeout ao obter estatísticas'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure('Erro ao obter estatísticas: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro inesperado ao obter estatísticas'),
      );
    }
  }

  /// Obtém informações do dispositivo atual
  Future<Either<Failure, DeviceInfoModel>> getCurrentDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final uuid = await _generateDeviceUuid();

      DeviceInfoModel deviceInfo;
      
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceInfo = DeviceInfoModel(
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
        deviceInfo = DeviceInfoModel(
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
        throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
      }

      return Right(deviceInfo);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao obter informações do dispositivo'),
      );
    }
  }

  /// Gera UUID único para o dispositivo
  Future<String> _generateDeviceUuid() async {
    // Implementação simplificada - em produção, usar DeviceIdentityService
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
