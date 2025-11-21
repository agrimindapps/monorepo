import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'package:core/core.dart';
import '../../../../core/services/device_identity_service.dart';

part 'settings_providers.g.dart';

/// Bridge provider for GetUserSettingsUseCase
@riverpod
GetUserSettingsUseCase getUserSettingsUseCase(GetUserSettingsUseCaseRef ref) {
  return GetIt.I.get<GetUserSettingsUseCase>();
}

/// Bridge provider for UpdateUserSettingsUseCase
@riverpod
UpdateUserSettingsUseCase updateUserSettingsUseCase(UpdateUserSettingsUseCaseRef ref) {
  return GetIt.I.get<UpdateUserSettingsUseCase>();
}

/// Bridge provider for DeviceManagementService
@riverpod
DeviceManagementService? deviceManagementService(DeviceManagementServiceRef ref) {
  if (GetIt.I.isRegistered<DeviceManagementService>()) {
    return GetIt.I.get<DeviceManagementService>();
  }
  return null;
}

@riverpod
DeviceIdentityService deviceIdentityService(Ref ref) {
  return DeviceIdentityService.instance;
}
