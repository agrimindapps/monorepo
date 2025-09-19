import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../models/device_model.dart';

/// Interface para datasource local de dispositivos
abstract class DeviceLocalDataSource {
  /// Obtém todos os dispositivos do usuário do cache local
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);

  /// Obtém dispositivo específico do cache local
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);

  /// Salva dispositivos do usuário no cache local
  Future<Either<Failure, void>> saveUserDevices(String userId, List<DeviceModel> devices);

  /// Salva um dispositivo específico no cache local
  Future<Either<Failure, void>> saveDevice(DeviceModel device);

  /// Remove dispositivo do cache local
  Future<Either<Failure, void>> removeDevice(String deviceUuid);

  /// Remove todos os dispositivos do usuário do cache local
  Future<Either<Failure, void>> removeUserDevices(String userId);

  /// Obtém estatísticas dos dispositivos do cache
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId);

  /// Limpa todo o cache de dispositivos
  Future<Either<Failure, void>> clearAll();

  /// Verifica se há dados em cache para o usuário
  Future<bool> hasDevicesCache(String userId);
}

/// Implementação simplificada do datasource local
/// Sem cache local persistente por enquanto - implementação mínima para compilação
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final ILocalStorageRepository _storageService;
  
  // Cache em memória temporário
  final Map<String, List<DeviceModel>> _userDevicesCache = {};
  final Map<String, DeviceModel> _devicesCache = {};

  DeviceLocalDataSourceImpl({
    required ILocalStorageRepository storageService,
  }) : _storageService = storageService;

  @override
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId) async {
    try {
      final devices = _userDevicesCache[userId] ?? [];
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Getting ${devices.length} devices for user $userId from cache');
      }
      return Right(devices);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dispositivos do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid) async {
    try {
      final device = _devicesCache[deviceUuid];
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Getting device $deviceUuid - ${device != null ? 'found' : 'not found'}');
      }
      return Right(device);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dispositivo do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserDevices(String userId, List<DeviceModel> devices) async {
    try {
      _userDevicesCache[userId] = devices;
      // Também salva individualmente para busca rápida
      for (final device in devices) {
        _devicesCache[device.uuid] = device;
      }
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Saved ${devices.length} devices for user $userId');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dispositivos no cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveDevice(DeviceModel device) async {
    try {
      _devicesCache[device.uuid] = device;
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Saved device ${device.uuid}');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar dispositivo no cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDevice(String deviceUuid) async {
    try {
      _devicesCache.remove(deviceUuid);
      // Remove das listas de usuários também
      for (final userId in _userDevicesCache.keys.toList()) {
        final devices = _userDevicesCache[userId] ?? [];
        devices.removeWhere((device) => device.uuid == deviceUuid);
        if (devices.isEmpty) {
          _userDevicesCache.remove(userId);
        } else {
          _userDevicesCache[userId] = devices;
        }
      }
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Removed device $deviceUuid');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dispositivo do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeUserDevices(String userId) async {
    try {
      final devices = _userDevicesCache[userId] ?? [];
      // Remove dispositivos individuais
      for (final device in devices) {
        _devicesCache.remove(device.uuid);
      }
      _userDevicesCache.remove(userId);
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Removed all devices for user $userId');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dispositivos do usuário do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId) async {
    try {
      final devices = _userDevicesCache[userId] ?? [];
      final activeDevices = devices.where((d) => d.isActive).length;
      final totalDevices = devices.length;

      final stats = {
        'total_devices': totalDevices,
        'active_devices': activeDevices,
        'inactive_devices': totalDevices - activeDevices,
      };

      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Generated statistics for user $userId: $stats');
      }
      return Right(stats);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas do cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      _userDevicesCache.clear();
      _devicesCache.clear();
      if (kDebugMode) {
        debugPrint('📱 DeviceLocal: Cleared all cache');
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  @override
  Future<bool> hasDevicesCache(String userId) async {
    final hasCache = _userDevicesCache.containsKey(userId) &&
                     _userDevicesCache[userId]!.isNotEmpty;
    if (kDebugMode) {
      debugPrint('📱 DeviceLocal: Has cache for user $userId: $hasCache');
    }
    return hasCache;
  }
}