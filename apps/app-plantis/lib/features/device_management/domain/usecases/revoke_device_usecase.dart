import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../repositories/device_repository.dart';

/// Use case para revogar dispositivos no app-plantis
/// Gerencia revogação individual e em massa com controle de segurança
class RevokeDeviceUseCase {
  final DeviceRepository _deviceRepository;
  final AuthStateNotifier _authStateNotifier;

  RevokeDeviceUseCase(
    this._deviceRepository,
    this._authStateNotifier,
  );

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> call(RevokeDeviceParams params) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 RevokeDevice: Revoking device ${params.deviceUuid}');
      }

      // Obtém o usuário atual
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure('Usuário não autenticado'),
        );
      }

      final userId = currentUser.id;

      // Verifica se o dispositivo existe
      final deviceResult = await _deviceRepository.getDeviceByUuid(params.deviceUuid);

      return await deviceResult.fold(
        (failure) => Left(failure),
        (device) async {
          if (device == null) {
            if (kDebugMode) {
              debugPrint('❌ RevokeDevice: Device not found');
            }
            return const Left(
              NotFoundFailure(
                'Dispositivo não encontrado',
                code: 'DEVICE_NOT_FOUND',
              ),
            );
          }

          if (!device.isActive) {
            if (kDebugMode) {
              debugPrint('⚠️ RevokeDevice: Device already revoked');
            }
            return const Left(
              ValidationFailure(
                'Dispositivo já está revogado',
                code: 'DEVICE_ALREADY_REVOKED',
              ),
            );
          }

          // Verifica se é o dispositivo atual (se deve impedir)
          if (params.preventSelfRevoke) {
            final currentDevice = await DeviceModel.fromCurrentDevice();
            if (device.uuid == currentDevice.uuid) {
              if (kDebugMode) {
                debugPrint('❌ RevokeDevice: Cannot revoke current device');
              }
              return const Left(
                ValidationFailure(
                  'Não é possível revogar o dispositivo atual',
                  code: 'CANNOT_REVOKE_CURRENT_DEVICE',
                ),
              );
            }
          }

          // Executa a revogação
          if (kDebugMode) {
            debugPrint('🔐 RevokeDevice: Executing revocation');
          }

          final revokeResult = await _deviceRepository.revokeDevice(
            userId: userId,
            deviceUuid: params.deviceUuid,
          );

          return revokeResult.fold(
            (failure) {
              if (kDebugMode) {
                debugPrint('❌ RevokeDevice: Revocation failed - $failure');
              }
              return Left(failure);
            },
            (_) {
              if (kDebugMode) {
                debugPrint('✅ RevokeDevice: Device revoked successfully');
              }
              return const Right(null);
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RevokeDevice: Unexpected error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao revogar dispositivo',
          code: 'REVOKE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }
}

/// Use case para revogar todos os outros dispositivos exceto o atual
class RevokeAllOtherDevicesUseCase {
  final DeviceRepository _deviceRepository;
  final AuthStateNotifier _authStateNotifier;

  RevokeAllOtherDevicesUseCase(
    this._deviceRepository,
    this._authStateNotifier,
  );

  /// Revoga todos os outros dispositivos mantendo apenas o atual
  Future<Either<Failure, RevokeAllResult>> call([RevokeAllOtherDevicesParams? params]) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 RevokeAllOther: Revoking all other devices');
      }

      // Obtém o usuário atual
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(
          AuthFailure('Usuário não autenticado'),
        );
      }

      final userId = currentUser.id;

      // Obtém UUID do dispositivo atual
      String currentDeviceUuid;
      if (params?.currentDeviceUuid != null) {
        currentDeviceUuid = params!.currentDeviceUuid!;
      } else {
        final currentDevice = await DeviceModel.fromCurrentDevice();
        currentDeviceUuid = currentDevice.uuid;
      }

      // Obtém lista atual de dispositivos para contagem
      final devicesResult = await _deviceRepository.getUserDevices(userId);
      final deviceCount = await devicesResult.fold(
        (failure) => 0,
        (devices) => devices.where((d) => d.isActive && d.uuid != currentDeviceUuid).length,
      );

      if (deviceCount == 0) {
        if (kDebugMode) {
          debugPrint('ℹ️ RevokeAllOther: No other devices to revoke');
        }
        return const Right(
          RevokeAllResult(
            revokedCount: 0,
            message: 'Nenhum outro dispositivo para revogar',
          ),
        );
      }

      // Executa a revogação em massa
      if (kDebugMode) {
        debugPrint('🔐 RevokeAllOther: Revoking $deviceCount other devices');
      }

      final revokeResult = await _deviceRepository.revokeAllOtherDevices(
        userId: userId,
        currentDeviceUuid: currentDeviceUuid,
      );

      return revokeResult.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ RevokeAllOther: Mass revocation failed - $failure');
          }
          return Left(failure);
        },
        (_) {
          if (kDebugMode) {
            debugPrint('✅ RevokeAllOther: All other devices revoked successfully');
          }

          final message = deviceCount == 1
              ? '1 dispositivo foi revogado'
              : '$deviceCount dispositivos foram revogados';

          return Right(
            RevokeAllResult(
              revokedCount: deviceCount,
              message: message,
            ),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RevokeAllOther: Unexpected error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao revogar outros dispositivos',
          code: 'REVOKE_ALL_OTHER_ERROR',
          details: e,
        ),
      );
    }
  }
}

/// Parâmetros para RevokeDeviceUseCase
class RevokeDeviceParams {
  final String deviceUuid;
  final bool preventSelfRevoke;
  final String? reason;

  const RevokeDeviceParams({
    required this.deviceUuid,
    this.preventSelfRevoke = true,
    this.reason,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevokeDeviceParams &&
        other.deviceUuid == deviceUuid &&
        other.preventSelfRevoke == preventSelfRevoke &&
        other.reason == reason;
  }

  @override
  int get hashCode => deviceUuid.hashCode ^ preventSelfRevoke.hashCode ^ reason.hashCode;

  @override
  String toString() => 'RevokeDeviceParams(deviceUuid: $deviceUuid, preventSelfRevoke: $preventSelfRevoke)';
}

/// Parâmetros para RevokeAllOtherDevicesUseCase
class RevokeAllOtherDevicesParams {
  final String? currentDeviceUuid;
  final String? reason;

  const RevokeAllOtherDevicesParams({
    this.currentDeviceUuid,
    this.reason,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RevokeAllOtherDevicesParams &&
        other.currentDeviceUuid == currentDeviceUuid &&
        other.reason == reason;
  }

  @override
  int get hashCode => currentDeviceUuid.hashCode ^ reason.hashCode;

  @override
  String toString() => 'RevokeAllOtherDevicesParams(currentDeviceUuid: $currentDeviceUuid)';
}

/// Resultado da revogação em massa
class RevokeAllResult {
  final int revokedCount;
  final String message;

  const RevokeAllResult({
    required this.revokedCount,
    required this.message,
  });

  @override
  String toString() => 'RevokeAllResult(revokedCount: $revokedCount, message: $message)';
}