import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/auth_state_notifier.dart';
import '../../data/models/device_model.dart';
import '../repositories/device_repository.dart';

/// Use case para validar dispositivo no app-plantis
/// Verifica limites, valida com servidor e gerencia cache local
class ValidateDeviceUseCase {
  final DeviceRepository _deviceRepository;
  final AuthStateNotifier _authStateNotifier;

  ValidateDeviceUseCase(this._deviceRepository, this._authStateNotifier);

  /// Executa validação do dispositivo atual
  Future<Either<Failure, DeviceValidationResult>> call([
    ValidateDeviceParams? params,
  ]) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 ValidateDevice: Starting device validation');
      }

      // Obtém o usuário atual
      final currentUser = _authStateNotifier.currentUser;
      if (currentUser == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final userId = currentUser.id;

      // Obtém informações do dispositivo atual ou usa fornecido
      DeviceModel device;
      if (params?.device != null) {
        device = params!.device!;
      } else {
        device = await DeviceModel.fromCurrentDevice();
      }

      if (kDebugMode) {
        debugPrint('🔐 ValidateDevice: Validating device ${device.uuid}');
      }

      // Verifica se já existe e está ativo
      final existingResult = await _deviceRepository.getDeviceByUuid(
        device.uuid,
      );

      return await existingResult.fold((failure) => Left(failure), (
        existingDevice,
      ) async {
        if (existingDevice != null && existingDevice.isActive) {
          if (kDebugMode) {
            debugPrint(
              '✅ ValidateDevice: Device already valid, updating activity',
            );
          }

          // Dispositivo já válido, apenas atualiza atividade
          final updateResult = await _deviceRepository.updateLastActivity(
            userId: userId,
            deviceUuid: device.uuid,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (updatedDevice) => Right(
              DeviceValidationResult(
                isValid: true,
                device: updatedDevice,
                status: DeviceValidationStatus.valid,
                message: 'Dispositivo já validado e ativo',
              ),
            ),
          );
        }

        // Dispositivo novo ou inativo, verifica limites
        if (kDebugMode) {
          debugPrint('🔐 ValidateDevice: New/inactive device, checking limits');
        }

        final canAddResult = await _deviceRepository.canAddMoreDevices(userId);

        return await canAddResult.fold((failure) => Left(failure), (
          canAdd,
        ) async {
          if (!canAdd && existingDevice == null) {
            if (kDebugMode) {
              debugPrint('❌ ValidateDevice: Device limit exceeded');
            }

            // Obtém contagem atual para informar ao usuário
            final devicesResult = await _deviceRepository.getUserDevices(
              userId,
            );
            final activeCount = devicesResult.fold(
              (failure) => 0,
              (devices) => devices.where((d) => d.isActive).length,
            );

            return Right(
              DeviceValidationResult(
                isValid: false,
                status: DeviceValidationStatus.exceeded,
                message: 'Limite de dispositivos atingido ($activeCount/3)',
                remainingSlots: 0,
              ),
            );
          }

          // Valida com o servidor
          if (kDebugMode) {
            debugPrint('🔐 ValidateDevice: Validating with server');
          }

          final validationResult = await _deviceRepository.validateDevice(
            userId: userId,
            device: device,
          );

          return validationResult.fold(
            (failure) {
              if (kDebugMode) {
                debugPrint(
                  '❌ ValidateDevice: Server validation failed - $failure',
                );
              }

              return Right(
                DeviceValidationResult(
                  isValid: false,
                  status: DeviceValidationStatus.invalid,
                  message: failure.message,
                ),
              );
            },
            (validatedDevice) {
              if (kDebugMode) {
                debugPrint('✅ ValidateDevice: Device validated successfully');
              }

              return Right(
                DeviceValidationResult(
                  isValid: true,
                  device: validatedDevice,
                  status: DeviceValidationStatus.valid,
                  message: 'Dispositivo validado com sucesso',
                ),
              );
            },
          );
        });
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ValidateDevice: Unexpected error - $e');
      }
      return Left(
        ServerFailure(
          'Erro ao validar dispositivo',
          code: 'VALIDATE_DEVICE_ERROR',
          details: e,
        ),
      );
    }
  }
}

/// Parâmetros para ValidateDeviceUseCase
class ValidateDeviceParams {
  final DeviceModel? device;
  final bool forceValidation;

  const ValidateDeviceParams({this.device, this.forceValidation = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidateDeviceParams &&
        other.device == device &&
        other.forceValidation == forceValidation;
  }

  @override
  int get hashCode => device.hashCode ^ forceValidation.hashCode;

  @override
  String toString() =>
      'ValidateDeviceParams(device: ${device?.uuid}, forceValidation: $forceValidation)';
}

/// Resultado da validação de dispositivo específico do plantis
class DeviceValidationResult {
  final bool isValid;
  final DeviceModel? device;
  final DeviceValidationStatus status;
  final String? message;
  final int? remainingSlots;

  const DeviceValidationResult({
    required this.isValid,
    required this.status,
    this.device,
    this.message,
    this.remainingSlots,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'device': device?.toJson(),
      'status': status.name,
      'message': message,
      'remainingSlots': remainingSlots,
    };
  }

  /// Cria instância do JSON
  factory DeviceValidationResult.fromJson(Map<String, dynamic> json) {
    return DeviceValidationResult(
      isValid: json['isValid'] as bool,
      device:
          json['device'] != null
              ? DeviceModel.fromJson(json['device'] as Map<String, dynamic>)
              : null,
      status: DeviceValidationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DeviceValidationStatus.invalid,
      ),
      message: json['message'] as String?,
      remainingSlots: json['remainingSlots'] as int?,
    );
  }

  @override
  String toString() =>
      'DeviceValidationResult(isValid: $isValid, status: $status)';
}
