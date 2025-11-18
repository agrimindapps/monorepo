import 'package:core/core.dart' hide Column;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'injectable_config.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();

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
      return GoogleSignIn(clientId: '');
    }
    return GoogleSignIn();
  }
}
