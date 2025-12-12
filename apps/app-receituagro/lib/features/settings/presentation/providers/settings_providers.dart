import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/device_identity_service.dart';
import '../../../../core/services/promotional_notification_manager.dart';
import '../../../../core/services/receituagro_notification_service.dart';
import '../../data/repositories/user_settings_repository_impl.dart';
import '../../domain/repositories/i_user_settings_repository.dart';
import '../../domain/usecases/get_user_settings_usecase.dart';
import '../../domain/usecases/update_user_settings_usecase.dart';

part 'settings_providers.g.dart';

/// Provider for UserSettingsRepository
@riverpod
IUserSettingsRepository userSettingsRepository(Ref ref) {
  return UserSettingsRepositoryImpl();
}

/// Provider for GetUserSettingsUseCase
@riverpod
GetUserSettingsUseCase getUserSettingsUseCase(Ref ref) {
  return GetUserSettingsUseCase(ref.watch(userSettingsRepositoryProvider));
}

/// Provider for UpdateUserSettingsUseCase
@riverpod
UpdateUserSettingsUseCase updateUserSettingsUseCase(Ref ref) {
  return UpdateUserSettingsUseCase(ref.watch(userSettingsRepositoryProvider));
}

@riverpod
DeviceIdentityService deviceIdentityService(Ref ref) {
  return DeviceIdentityService.instance;
}

@riverpod
ReceitaAgroNotificationService receitaAgroNotificationService(Ref ref) {
  return ReceitaAgroNotificationService();
}

@riverpod
PromotionalNotificationManager promotionalNotificationManager(Ref ref) {
  return PromotionalNotificationManager();
}
