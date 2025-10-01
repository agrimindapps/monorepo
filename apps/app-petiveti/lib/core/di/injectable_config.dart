import 'package:core/core.dart';
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
  // External dependencies
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @singleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  GoogleSignIn get googleSignIn {
    // Para web em desenvolvimento, retorna uma instância que não será usada
    // Em produção, deve-se configurar o clientId via <meta> tag no index.html
    if (kIsWeb) {
      // Ignora a inicialização para evitar erro no desenvolvimento web
      // A autenticação web usa FirebaseAuth diretamente
      return GoogleSignIn(clientId: '');
    }
    return GoogleSignIn();
  }
}