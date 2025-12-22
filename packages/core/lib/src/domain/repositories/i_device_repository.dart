import 'package:dartz/dartz.dart';

import '../../shared/utils/failure.dart';
import '../entities/device_entity.dart';

/// Interface do repositório de dispositivos
/// Define os contratos para operações de gerenciamento de dispositivos
abstract class IDeviceRepository {
  /// Obtém todos os dispositivos do usuário
  Future<Either<Failure, List<DeviceEntity>>> getUserDevices(String userId);

  /// Obtém um dispositivo específico pelo UUID
  Future<Either<Failure, DeviceEntity?>> getDeviceByUuid(String deviceUuid);

  /// Valida um dispositivo para um usuário
  /// Retorna o dispositivo validado ou falha se inválido
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  });

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  /// Revoga todos os dispositivos do usuário exceto o atual
  Future<Either<Failure, void>> revokeAllOtherDevices({
    required String userId,
    required String currentDeviceUuid,
  });

  /// Atualiza a última atividade de um dispositivo
  Future<Either<Failure, DeviceEntity>> updateLastActivity({
    required String userId,
    required String deviceUuid,
  });

  /// Verifica se o usuário pode adicionar mais dispositivos
  Future<Either<Failure, bool>> canAddMoreDevices(String userId, {bool isPremium = false});

  /// Obtém o número atual de dispositivos ativos do usuário
  Future<Either<Failure, int>> getActiveDeviceCount(String userId);

  /// Obtém o limite máximo de dispositivos para o usuário
  Future<Either<Failure, int>> getDeviceLimit(String userId);

  /// Remove dispositivos inativos por mais de X dias
  Future<Either<Failure, List<String>>> cleanupInactiveDevices({
    required String userId,
    required int inactiveDays,
  });

  /// Obtém estatísticas de dispositivos do usuário
  Future<Either<Failure, DeviceStatistics>> getDeviceStatistics(String userId);

  /// Sincroniza dispositivos locais com o servidor
  Future<Either<Failure, List<DeviceEntity>>> syncDevices(String userId);
}

/// Estatísticas de dispositivos do usuário
class DeviceStatistics {
  const DeviceStatistics({
    required this.totalDevices,
    required this.activeDevices,
    required this.devicesByPlatform,
    required this.lastActiveDevice,
    required this.oldestDevice,
    required this.newestDevice,
  });

  /// Total de dispositivos registrados
  final int totalDevices;

  /// Dispositivos ativos (não revogados)
  final int activeDevices;

  /// Contagem por plataforma
  final Map<String, int> devicesByPlatform;

  /// Último dispositivo ativo
  final DeviceEntity? lastActiveDevice;

  /// Dispositivo mais antigo
  final DeviceEntity? oldestDevice;

  /// Dispositivo mais recente
  final DeviceEntity? newestDevice;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'totalDevices': totalDevices,
      'activeDevices': activeDevices,
      'devicesByPlatform': devicesByPlatform,
      'lastActiveDevice': lastActiveDevice?.toJson(),
      'oldestDevice': oldestDevice?.toJson(),
      'newestDevice': newestDevice?.toJson(),
    };
  }

  /// Cria instância do JSON
  factory DeviceStatistics.fromJson(Map<String, dynamic> json) {
    return DeviceStatistics(
      totalDevices: json['totalDevices'] as int,
      activeDevices: json['activeDevices'] as int,
      devicesByPlatform: Map<String, int>.from(json['devicesByPlatform'] as Map),
      lastActiveDevice: json['lastActiveDevice'] != null
          ? DeviceEntity.fromJson(json['lastActiveDevice'] as Map<String, dynamic>)
          : null,
      oldestDevice: json['oldestDevice'] != null
          ? DeviceEntity.fromJson(json['oldestDevice'] as Map<String, dynamic>)
          : null,
      newestDevice: json['newestDevice'] != null
          ? DeviceEntity.fromJson(json['newestDevice'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() => 'DeviceStatistics(total: $totalDevices, active: $activeDevices)';
}

/// Resultado da validação de dispositivo
class DeviceValidationResult {
  const DeviceValidationResult({
    required this.isValid,
    required this.status,
    this.device,
    this.message,
    this.remainingSlots,
  });

  /// Se o dispositivo é válido
  final bool isValid;

  /// Status da validação
  final DeviceValidationStatus status;

  /// Dispositivo validado (se válido)
  final DeviceEntity? device;

  /// Mensagem explicativa
  final String? message;

  /// Slots restantes para novos dispositivos
  final int? remainingSlots;

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'status': status.name,
      'device': device?.toJson(),
      'message': message,
      'remainingSlots': remainingSlots,
    };
  }

  /// Cria instância do JSON
  factory DeviceValidationResult.fromJson(Map<String, dynamic> json) {
    return DeviceValidationResult(
      isValid: json['isValid'] as bool,
      status: DeviceValidationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DeviceValidationStatus.invalid,
      ),
      device: json['device'] != null
          ? DeviceEntity.fromJson(json['device'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      remainingSlots: json['remainingSlots'] as int?,
    );
  }

  @override
  String toString() => 'DeviceValidationResult(isValid: $isValid, status: $status)';
}
