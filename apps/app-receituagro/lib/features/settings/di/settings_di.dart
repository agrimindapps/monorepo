import 'package:core/core.dart';

import '../../../core/providers/receituagro_auth_notifier.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/repositories/user_settings_repository_impl.dart';
import '../domain/repositories/i_user_settings_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/get_user_settings_usecase.dart';
import '../domain/usecases/update_user_settings_usecase.dart';

/// Dependency Injection setup for Settings module following Clean Architecture.
/// Registers all dependencies required for the settings feature.
abstract class SettingsDI {
  static void register(GetIt getIt) {
    getIt.registerLazySingleton<IUserSettingsRepository>(
      () => UserSettingsRepositoryImpl(),
    );
    getIt.registerFactory<GetUserSettingsUseCase>(
      () => GetUserSettingsUseCase(getIt<IUserSettingsRepository>()),
    );

    getIt.registerFactory<UpdateUserSettingsUseCase>(
      () => UpdateUserSettingsUseCase(getIt<IUserSettingsRepository>()),
    );
    getIt.registerLazySingleton<ProfileImageService>(
      () => ProfileImageServiceFactory.createDefault(),
    );
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        profileImageService: getIt<ProfileImageService>(),
        authNotifier: getIt<ReceitaAgroAuthNotifier>(),
      ),
    );
  }

  /// Unregister all dependencies (useful for testing)
  static void unregister(GetIt getIt) {

    if (getIt.isRegistered<UpdateUserSettingsUseCase>()) {
      getIt.unregister<UpdateUserSettingsUseCase>();
    }

    if (getIt.isRegistered<GetUserSettingsUseCase>()) {
      getIt.unregister<GetUserSettingsUseCase>();
    }

    if (getIt.isRegistered<IUserSettingsRepository>()) {
      getIt.unregister<IUserSettingsRepository>();
    }

    if (getIt.isRegistered<ProfileRepository>()) {
      getIt.unregister<ProfileRepository>();
    }

    if (getIt.isRegistered<ProfileImageService>()) {
      getIt.unregister<ProfileImageService>();
    }
  }
}
