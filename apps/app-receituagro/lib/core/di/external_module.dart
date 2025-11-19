import 'package:core/core.dart' hide Column;

/// Módulo para registrar dependências externas do core package
@module
abstract class ExternalModule {
  /// Registra SharedPreferences como dependência injetável
  ///
  /// Usado por LocalSubscriptionProvider para cache offline
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;
}
