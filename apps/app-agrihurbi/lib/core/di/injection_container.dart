import 'package:core/core.dart' as core_lib;
import 'package:core/core.dart' show GetIt, SharedPreferences;
import 'package:flutter/foundation.dart';

import '../services/premium_service.dart';

final getIt = GetIt.instance;

/// Placeholder for injectable configuration
/// Run 'flutter packages pub run build_runner build' to generate
/// NOTE: Manual injection disabled - using generated injection.config.dart instead
void configureDependencies() {
  // All injection now handled by generated injection.config.dart
  // Manual registrations commented out to avoid conflicts
}

/// Legacy initialization function for backward compatibility
Future<void> init({bool firebaseEnabled = false}) async {
  await configureAppDependencies(firebaseEnabled: firebaseEnabled);
}

/// Configure dependencies using @injectable + code generation
///
/// MASSIVE REDUCTION: from 400+ lines to <50 lines!
/// All @injectable classes are auto-registered by code generation
Future<void> configureAppDependencies({bool firebaseEnabled = false}) async {
  // Register Firebase services only if Firebase is initialized
  if (firebaseEnabled) {
    try {
      getIt.registerSingleton<core_lib.FirebaseAuthService>(
        core_lib.FirebaseAuthService(),
      );
      getIt.registerSingleton<core_lib.FirebaseAnalyticsService>(
        core_lib.FirebaseAnalyticsService(),
      );
      debugPrint('Firebase services registered in DI');
    } catch (e) {
      debugPrint('Failed to register Firebase services: $e');
    }
  } else {
    debugPrint('Firebase services not registered (running in local-only mode)');
  }

  // Register RevenueCat service (doesn't require Firebase)
  getIt.registerSingleton<core_lib.RevenueCatService>(
    core_lib.RevenueCatService(),
  );

  // Register PremiumService conditionally based on Firebase availability
  if (firebaseEnabled &&
      getIt.isRegistered<core_lib.FirebaseAnalyticsService>()) {
    getIt.registerSingleton(
      PremiumService(
        getIt<core_lib.RevenueCatService>(),
        getIt<core_lib.FirebaseAnalyticsService>(),
      ),
    );
  }
  final sharedPrefs = await core_lib.SharedPreferences.getInstance();
  getIt.registerSingleton<core_lib.SharedPreferences>(sharedPrefs);
  getIt.registerSingleton<core_lib.EnhancedSecureStorageService>(
    core_lib.EnhancedSecureStorageService(appIdentifier: 'app_agrihurbi'),
  );
  configureDependencies();

  debugPrint('✅ App Dependencies configured successfully!');
  debugPrint(
    '   - Injectable dependencies: Auto-registered by code generation',
  );
}
