import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_info.dart';
import '../entities/device_session.dart';

/// Repositório abstrato para gerenciamento de dispositivos
abstract class DeviceRepository {
  /// Obtém lista de dispositivos do usuário
  Future<Either<Failure, List<DeviceInfo>>> getUserDevices(String userId);

  /// Valida se um dispositivo pode ser usado
  Future<Either<Failure, DeviceInfo>> validateDevice({
    required String userId,
    required DeviceInfo device,
  });

  /// Revoga acesso de um dispositivo específico
  Future<Either<Failure, Unit>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  /// Atualiza última atividade do dispositivo
  Future<Either<Failure, DeviceInfo>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);

  /// Obtém dispositivo por UUID
  Future<Either<Failure, DeviceInfo?>> getDeviceByUuid(String uuid);

  /// Obtém estatísticas de dispositivos do usuário
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId);

  /// Revoga acesso de todos os outros dispositivos exceto o atual
  Future<Either<Failure, Unit>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });

  /// Remove dispositivos inativos há X dias
  Future<Either<Failure, List<String>>> cleanupInactiveDevices({
    required String userId,
    required int inactiveDays,
  });

  /// Obtém contagem de dispositivos ativos
  Future<Either<Failure, int>> getActiveDeviceCount(String userId);

  /// Obtém limite de dispositivos para o usuário
  Future<Either<Failure, int>> getDeviceLimit(String userId);

  /// Sincroniza dispositivos com o servidor
  Future<Either<Failure, List<DeviceInfo>>> syncDevices(String userId);
}
