import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/tts_settings_repository_impl.dart';
import '../data/services/tts_service_impl.dart';
import '../domain/repositories/i_tts_settings_repository.dart';
import '../domain/services/i_tts_service.dart';

/// Dependency Injection module for TTS feature
/// Registers TTS services and repositories
class TTSModule {
  static Future<void> register(GetIt sl) async {
    // Register SharedPreferences if not already registered
    if (!sl.isRegistered<SharedPreferences>()) {
      final prefs = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => prefs);
    }

    // Register TTS Service
    if (!sl.isRegistered<ITTSService>()) {
      sl.registerLazySingleton<ITTSService>(() => TTSServiceImpl());
    }

    // Register TTS Settings Repository
    if (!sl.isRegistered<ITTSSettingsRepository>()) {
      sl.registerLazySingleton<ITTSSettingsRepository>(
        () => TTSSettingsRepositoryImpl(sl<SharedPreferences>()),
      );
    }
  }
}
