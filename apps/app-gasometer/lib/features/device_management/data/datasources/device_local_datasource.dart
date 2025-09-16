import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../models/device_info_model.dart';
import '../models/device_statistics_model.dart';

/// Data source local para gerenciamento de dispositivos usando Hive
@lazySingleton
class DeviceLocalDataSource {
  static const String _devicesBoxName = 'user_devices';
  static const String _statisticsBoxName = 'device_statistics';
  static const String _cacheExpiryKey = 'cache_expiry';
  
  /// Validade do cache em horas
  static const int _cacheValidityHours = 24;

  /// Obtém box do Hive para dispositivos
  Box<Map<dynamic, dynamic>> get _devicesBox => 
      Hive.box<Map<dynamic, dynamic>>(_devicesBoxName);

  /// Obtém box do Hive para estatísticas
  Box<Map<dynamic, dynamic>> get _statisticsBox => 
      Hive.box<Map<dynamic, dynamic>>(_statisticsBoxName);

  /// Cache dispositivos de um usuário
  Future<Either<Failure, Unit>> cacheDevices(
    String userId,
    List<DeviceInfoModel> devices,
  ) async {
    try {
      final deviceMaps = devices.map((d) => d.toMap()).toList();
      final cacheData = {
        'devices': deviceMaps,
        _cacheExpiryKey: DateTime.now()
            .add(const Duration(hours: _cacheValidityHours))
            .millisecondsSinceEpoch,
      };
      
      await _devicesBox.put(userId, cacheData);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao cache de dispositivos: $e'));
    }
  }

  /// Obtém dispositivos do cache
  Future<Either<Failure, List<DeviceInfoModel>>> getCachedDevices(
    String userId,
  ) async {
    try {
      final cachedData = _devicesBox.get(userId);
      if (cachedData == null) {
        return const Right([]);
      }

      // Verificar se cache ainda é válido
      final expiryTimestamp = cachedData[_cacheExpiryKey] as int?;
      if (expiryTimestamp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryDate)) {
          // Cache expirado, limpar
          await _devicesBox.delete(userId);
          return const Right([]);
        }
      }

      final devicesList = cachedData['devices'] as List?;
      if (devicesList == null) {
        return const Right([]);
      }

      final devices = devicesList
          .cast<Map<String, dynamic>>()
          .map((map) => DeviceInfoModel.fromMap(map))
          .toList();

      return Right(devices);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter dispositivos do cache: $e'));
    }
  }

  /// Atualiza um dispositivo no cache
  Future<Either<Failure, Unit>> updateDevice(
    String userId,
    DeviceInfoModel device,
  ) async {
    try {
      final cachedResult = await getCachedDevices(userId);
      
      return await cachedResult.fold(
        (failure) => Left(failure),
        (cachedDevices) async {
          final updatedDevices = cachedDevices.map((d) {
            return d.uuid == device.uuid ? device : d;
          }).toList();
          
          // Se o dispositivo não foi encontrado, adicionar
          if (!updatedDevices.any((d) => d.uuid == device.uuid)) {
            updatedDevices.add(device);
          }
          
          return await cacheDevices(userId, updatedDevices);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar dispositivo no cache: $e'));
    }
  }

  /// Remove um dispositivo do cache
  Future<Either<Failure, Unit>> removeDevice(
    String userId,
    String deviceUuid,
  ) async {
    try {
      final cachedResult = await getCachedDevices(userId);
      
      return await cachedResult.fold(
        (failure) => Left(failure),
        (cachedDevices) async {
          final filteredDevices = cachedDevices
              .where((d) => d.uuid != deviceUuid)
              .toList();
          
          return await cacheDevices(userId, filteredDevices);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Erro ao remover dispositivo do cache: $e'));
    }
  }

  /// Obtém um dispositivo por UUID do cache
  Future<Either<Failure, DeviceInfoModel?>> getDeviceByUuid(
    String deviceUuid,
  ) async {
    try {
      // Buscar em todos os usuários (não ideal, mas necessário para este método)
      for (final userId in _devicesBox.keys) {
        final cachedResult = await getCachedDevices(userId.toString());
        
        final device = cachedResult.fold(
          (failure) => null,
          (devices) => devices
              .cast<DeviceInfoModel?>()
              .firstWhere(
                (d) => d?.uuid == deviceUuid,
                orElse: () => null,
              ),
        );
        
        if (device != null) {
          return Right(device);
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar dispositivo por UUID: $e'));
    }
  }

  /// Limpa cache de um usuário
  Future<Either<Failure, Unit>> clearCache(String userId) async {
    try {
      await _devicesBox.delete(userId);
      await _statisticsBox.delete(userId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  /// Cache estatísticas de dispositivos
  Future<Either<Failure, Unit>> cacheStatistics(
    String userId,
    DeviceStatisticsModel statistics,
  ) async {
    try {
      final cacheData = {
        'statistics': statistics.toMap(),
        _cacheExpiryKey: DateTime.now()
            .add(const Duration(hours: _cacheValidityHours))
            .millisecondsSinceEpoch,
      };
      
      await _statisticsBox.put(userId, cacheData);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao cache de estatísticas: $e'));
    }
  }

  /// Obtém estatísticas do cache
  Future<Either<Failure, DeviceStatisticsModel?>> getCachedStatistics(
    String userId,
  ) async {
    try {
      final cachedData = _statisticsBox.get(userId);
      if (cachedData == null) {
        return const Right(null);
      }

      // Verificar se cache ainda é válido
      final expiryTimestamp = cachedData[_cacheExpiryKey] as int?;
      if (expiryTimestamp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryDate)) {
          await _statisticsBox.delete(userId);
          return const Right(null);
        }
      }

      final statisticsMap = cachedData['statistics'] as Map<String, dynamic>?;
      if (statisticsMap == null) {
        return const Right(null);
      }

      final statistics = DeviceStatisticsModel.fromMap(statisticsMap);
      return Right(statistics);
    } catch (e) {
      return Left(CacheFailure('Erro ao obter estatísticas do cache: $e'));
    }
  }

  /// Limpa todo o cache (todos os usuários)
  Future<Either<Failure, Unit>> clearAllCache() async {
    try {
      await _devicesBox.clear();
      await _statisticsBox.clear();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar todo o cache: $e'));
    }
  }
}
