import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/user_settings_repository_impl.dart';
import '../domain/repositories/i_user_settings_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_user_settings_usecase.dart';
import '../domain/usecases/update_user_settings_usecase.dart';
import '../presentation/providers/profile_provider.dart';
import '../presentation/providers/settings_provider.dart';
import '../presentation/providers/user_settings_provider.dart';

/// Dependency Injection setup for Settings module following Clean Architecture.
/// Registers all dependencies required for the settings feature.
abstract class SettingsDI {
  static void register(GetIt getIt) {
    // Repository layer
    getIt.registerLazySingleton<IUserSettingsRepository>(
      () => UserSettingsRepositoryImpl(),
    );

    // Use cases layer
    getIt.registerFactory<GetUserSettingsUseCase>(
      () => GetUserSettingsUseCase(getIt<IUserSettingsRepository>()),
    );

    getIt.registerFactory<UpdateUserSettingsUseCase>(
      () => UpdateUserSettingsUseCase(getIt<IUserSettingsRepository>()),
    );

    // Provider layer - Legacy UserSettingsProvider
    getIt.registerFactory<UserSettingsProvider>(
      () => UserSettingsProvider(
        getUserSettingsUseCase: getIt<GetUserSettingsUseCase>(),
        updateUserSettingsUseCase: getIt<UpdateUserSettingsUseCase>(),
      ),
    );

    // Unified Settings Provider for the refactored SettingsPage
    getIt.registerLazySingleton<SettingsProvider>(
      () => SettingsProvider(
        getUserSettingsUseCase: getIt<GetUserSettingsUseCase>(),
        updateUserSettingsUseCase: getIt<UpdateUserSettingsUseCase>(),
      ),
    );

    // Register as singleton for provider persistence across app
    getIt.registerLazySingleton<UserSettingsProvider>(
      () => UserSettingsProvider(
        getUserSettingsUseCase: getIt<GetUserSettingsUseCase>(),
        updateUserSettingsUseCase: getIt<UpdateUserSettingsUseCase>(),
      ),
      instanceName: 'singleton',
    );

    // ===== PROFILE MANAGEMENT =====
    
    // ProfileImageService from core package
    getIt.registerLazySingleton<ProfileImageService>(
      () => ProfileImageServiceFactory.createDefault(),
    );
    
    // ProfileRepository implementation
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        profileImageService: getIt<ProfileImageService>(),
        authProvider: getIt<ReceitaAgroAuthProvider>(),
      ),
    );
    
    // ProfileProvider for state management
    getIt.registerLazySingleton<ProfileProvider>(
      () => ProfileProvider(
        profileRepository: getIt<ProfileRepository>(),
      ),
    );
  }

  /// Unregister all dependencies (useful for testing)
  static void unregister(GetIt getIt) {
    if (getIt.isRegistered<SettingsProvider>()) {
      getIt.unregister<SettingsProvider>();
    }

    if (getIt.isRegistered<UserSettingsProvider>()) {
      getIt.unregister<UserSettingsProvider>();
    }

    if (getIt.isRegistered<UserSettingsProvider>(instanceName: 'singleton')) {
      getIt.unregister<UserSettingsProvider>(instanceName: 'singleton');
    }

    if (getIt.isRegistered<UpdateUserSettingsUseCase>()) {
      getIt.unregister<UpdateUserSettingsUseCase>();
    }

    if (getIt.isRegistered<GetUserSettingsUseCase>()) {
      getIt.unregister<GetUserSettingsUseCase>();
    }

    if (getIt.isRegistered<IUserSettingsRepository>()) {
      getIt.unregister<IUserSettingsRepository>();
    }

    // Profile dependencies cleanup
    if (getIt.isRegistered<ProfileProvider>()) {
      getIt.unregister<ProfileProvider>();
    }

    if (getIt.isRegistered<ProfileRepository>()) {
      getIt.unregister<ProfileRepository>();
    }

    if (getIt.isRegistered<ProfileImageService>()) {
      getIt.unregister<ProfileImageService>();
    }
  }
}