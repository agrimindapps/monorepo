import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
