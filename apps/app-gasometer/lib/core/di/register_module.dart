import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  GoogleSignIn get googleSignIn {
    if (kIsWeb) {
      return GoogleSignIn(
        signInOption: SignInOption.standard,
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
