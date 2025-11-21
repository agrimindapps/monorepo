import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../data/repositories/user_settings_repository_impl.dart';
import '../../domain/repositories/i_user_settings_repository.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';
import 'device_management_providers.dart';

part 'settings_providers.g.dart';

/// Provider for UserSettingsRepository
@riverpod
IUserSettingsRepository userSettingsRepository(UserSettingsRepositoryRef ref) {
  return UserSettingsRepositoryImpl();
}

/// Provider for GetUserSettingsUseCase
@riverpod
GetUserSettingsUseCase getUserSettingsUseCase(GetUserSettingsUseCaseRef ref) {
  return GetUserSettingsUseCase(ref.watch(userSettingsRepositoryProvider));
}

/// Provider for UpdateUserSettingsUseCase
@riverpod
UpdateUserSettingsUseCase updateUserSettingsUseCase(UpdateUserSettingsUseCaseRef ref) {
  return UpdateUserSettingsUseCase(ref.watch(userSettingsRepositoryProvider));
}

/// Provider for DeviceManagementService
@riverpod
DeviceManagementService? deviceManagementService(DeviceManagementServiceRef ref) {
  // We can now return the service directly as we have a provider for it
  // But the original code returned null if not registered (maybe for web support?)
  // Let's return the service from the provider we created.
  // If dependencies are missing, the provider might fail or return something else.
  // Our deviceManagementServiceProvider returns a valid instance.
  return ref.watch(deviceManagementServiceProvider);
}

@riverpod
DeviceIdentityService deviceIdentityService(Ref ref) {
  return DeviceIdentityService.instance;
}
