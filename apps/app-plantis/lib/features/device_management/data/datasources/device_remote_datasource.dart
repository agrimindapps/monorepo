import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';

import '../models/device_model.dart';

/// Interface para datasource remoto de dispositivos
abstract class DeviceRemoteDataSource {
  /// Obtém todos os dispositivos do usuário do servidor
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);

  /// Obtém dispositivo específico do servidor
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);

  /// Valida um dispositivo com o servidor
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  /// Revoga todos os outros dispositivos exceto o atual
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });

  /// Atualiza a última atividade de um dispositivo
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);

  /// Obtém o número atual de dispositivos ativos do usuário
  Future<Either<Failure, int>> getActiveDeviceCount(String userId);

  /// Obtém estatísticas de dispositivos do usuário
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId);

  /// Sincroniza dispositivos com o servidor
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId);
}

/// Implementação simplificada do datasource remoto
/// Stub implementation - funcionalidade será delegada diretamente ao core repository
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  DeviceRemoteDataSourceImpl();

  @override
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - getUserDevices for $userId');
    }
    // Retorna lista vazia por enquanto - o core repository será usado diretamente nos use cases
    return const Right([]);
  }

  @override
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - getDeviceByUuid $deviceUuid');
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - validateDevice ${device.uuid}');
    }
    return Left(ServerFailure('Not implemented in stub'));
  }

  @override
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - revokeDevice $deviceUuid');
    }
    return Left(ServerFailure('Not implemented in stub'));
  }

  @override
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - revokeAllOtherDevices');
    }
    return Left(ServerFailure('Not implemented in stub'));
  }

  @override
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  }) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - updateLastActivity $deviceUuid');
    }
    return Left(ServerFailure('Not implemented in stub'));
  }

  @override
  Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - canAddMoreDevices for $userId');
    }
    return const Right(true); // Permite por padrão
  }

  @override
  Future<Either<Failure, int>> getActiveDeviceCount(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - getActiveDeviceCount for $userId');
    }
    return const Right(0);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - getDeviceStatistics for $userId');
    }
    return const Right({
      'total_devices': 0,
      'active_devices': 0,
      'inactive_devices': 0,
    });
  }

  @override
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId) async {
    if (kDebugMode) {
      debugPrint('🌐 DeviceRemote: Stub implementation - syncDevices for $userId');
    }
    return const Right([]);
  }
}