import 'package:core/core.dart' hide Column;

// ❌ REMOVIDO: user_settings_repository_impl.dart (via @LazySingleton)
// ❌ REMOVIDO: i_user_settings_repository.dart (via @LazySingleton)
// ❌ REMOVIDO: get_user_settings_usecase.dart (via @injectable)
// ❌ REMOVIDO: update_user_settings_usecase.dart (via @injectable)

/// Dependency Injection setup for Settings module following Clean Architecture.
///
/// ⚠️ IMPORTANTE: IUserSettingsRepository e use cases agora via @LazySingleton/@injectable
/// Registra apenas ProfileImageService (não tem @injectable)
abstract class SettingsDI {
  static void register(GetIt getIt) {
    // ❌ REMOVIDO: IUserSettingsRepository (via @LazySingleton)
    // ❌ REMOVIDO: GetUserSettingsUseCase (via @injectable)
    // ❌ REMOVIDO: UpdateUserSettingsUseCase (via @injectable)

    // ✅ ProfileImageService ainda precisa de registro manual (sem @injectable)
    getIt.registerLazySingleton<ProfileImageService>(
      () => ProfileImageServiceFactory.createDefault(),
    );
    // ProfileRepository now managed by Riverpod - see profile_providers.dart
  }

  /// Unregister all dependencies (useful for testing)
  static void unregister(GetIt getIt) {
    // ❌ REMOVIDO: UpdateUserSettingsUseCase (via @injectable)
    // ❌ REMOVIDO: GetUserSettingsUseCase (via @injectable)
    // ❌ REMOVIDO: IUserSettingsRepository (via @LazySingleton)

    // ProfileRepository now managed by Riverpod

    if (getIt.isRegistered<ProfileImageService>()) {
      getIt.unregister<ProfileImageService>();
    }
  }
}
