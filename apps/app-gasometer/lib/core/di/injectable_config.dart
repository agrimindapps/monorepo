import 'package:core/core.dart' hide AuthProvider;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/vehicles/presentation/providers/vehicles_provider.dart';
import 'injectable_config.config.dart';

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies(GetIt getIt) async {
  print('📦 Starting injectable dependencies configuration...');

  try {
    await getIt.init();
    print('✅ Injectable dependencies configured successfully');

    // Note: AuthProvider was migrated to AuthNotifier (StateNotifier-based)
    // and is now managed via Riverpod providers instead of GetIt

    // Check if VehiclesProvider is registered
    if (getIt.isRegistered<VehiclesProvider>()) {
      print('✅ VehiclesProvider is registered in GetIt');
    } else {
      print('❌ VehiclesProvider is NOT registered in GetIt');
    }
  } catch (e, stackTrace) {
    print('❌ Error during injectable configuration: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

@module
abstract class RegisterModule {
  // External dependencies
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  GoogleSignIn get googleSignIn {
    if (kIsWeb) {
      // For web, we need to provide clientId or it will fail
      // TODO: Add proper OAuth client ID for web platform
      // For now, return a GoogleSignIn that won't be used for authentication
      return GoogleSignIn(
        signInOption: SignInOption.standard,
        // Disable for web until proper client ID is configured
      );
    }
    return GoogleSignIn();
  }

  @singleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @singleton
  ConnectivityService get connectivityService => ConnectivityService.instance;

  @singleton
  IAppRatingRepository get appRatingRepository => AppRatingService();
}
