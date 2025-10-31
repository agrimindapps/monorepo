import 'package:core/core.dart'
    hide
        ValidateDeviceUseCase,
        RevokeDeviceUseCase,
        RevokeAllOtherDevicesUseCase,
        ValidateDeviceParams,
        RevokeDeviceParams,
        RevokeAllOtherDevicesParams,
        DeviceValidationResult;

import '../../data/models/device_model.dart';
import '../../domain/usecases/revoke_device_usecase.dart';
import '../../domain/usecases/validate_device_usecase.dart';

/// Service para ações de dispositivos
/// Centraliza lógica de validação e revogação
class DeviceActionService {
  final ValidateDeviceUseCase _validateDeviceUseCase;
  final RevokeDeviceUseCase _revokeDeviceUseCase;
  final RevokeAllOtherDevicesUseCase _revokeAllOtherDevicesUseCase;

  DeviceActionService({
    required ValidateDeviceUseCase validateDeviceUseCase,
    required RevokeDeviceUseCase revokeDeviceUseCase,
    required RevokeAllOtherDevicesUseCase revokeAllOtherDevicesUseCase,
  }) : _validateDeviceUseCase = validateDeviceUseCase,
       _revokeDeviceUseCase = revokeDeviceUseCase,
       _revokeAllOtherDevicesUseCase = revokeAllOtherDevicesUseCase;

  /// Valida o dispositivo atual
  Future<Either<Failure, DeviceValidationResult>> validateCurrentDevice({
    DeviceModel? device,
    bool forceValidation = false,
  }) async {
    return _validateDeviceUseCase(
      ValidateDeviceParams(device: device, forceValidation: forceValidation),
    );
  }

  /// Revoga um dispositivo específico
  Future<Either<Failure, void>> revokeDevice(String deviceUuid) async {
    return _revokeDeviceUseCase(RevokeDeviceParams(deviceUuid: deviceUuid));
  }

  /// Revoga todos os outros dispositivos
  Future<Either<Failure, void>> revokeAllOtherDevices(
    String currentDeviceUuid,
  ) async {
    return _revokeAllOtherDevicesUseCase(
      RevokeAllOtherDevicesParams(currentDeviceUuid: currentDeviceUuid),
    );
  }
}
