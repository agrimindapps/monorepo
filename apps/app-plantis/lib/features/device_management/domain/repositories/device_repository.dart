import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../../data/models/device_model.dart';

/// Interface do repository de dispositivos específico do app-plantis
/// Adapta a interface do core para as necessidades do app
abstract class DeviceRepository {
  /// Obtém todos os dispositivos do usuário
  /// Implementa estratégia offline-first com cache local
  Future<Either<Failure, List<DeviceModel>>> getUserDevices(String userId);

  /// Obtém um dispositivo específico pelo UUID
  /// Usa cache local com refresh automático se necessário
  Future<Either<Failure, DeviceModel?>> getDeviceByUuid(String deviceUuid);

  /// Valida um dispositivo para um usuário
  /// Requer conectividade para validação no servidor
  Future<Either<Failure, DeviceModel>> validateDevice({
    required String userId,
    required DeviceModel device,
  });

  /// Revoga um dispositivo específico
  /// Remove acesso e atualiza cache local
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  /// Revoga todos os dispositivos exceto o atual
  /// Útil para logout remoto e segurança
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });

  /// Atualiza a última atividade de um dispositivo
  /// Funciona offline com sincronização posterior
  Future<Either<Failure, DeviceModel>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });

  /// Verifica se o usuário pode adicionar mais dispositivos
  /// Funciona offline com aproximação baseada no cache
  Future<Either<Failure, bool>> canAddMoreDevices(String userId);

  /// Obtém estatísticas de dispositivos do usuário
  /// Combina dados remotos e locais conforme conectividade
  Future<Either<Failure, Map<String, dynamic>>> getDeviceStatistics(String userId);

  /// Sincroniza dispositivos locais com o servidor
  /// Força refresh completo dos dados
  Future<Either<Failure, List<DeviceModel>>> syncDevices(String userId);

  /// Limpa todo o cache local de dispositivos
  /// Útil para logout ou reset de dados
  Future<Either<Failure, void>> clearCache();
}