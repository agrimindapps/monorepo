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

  // Core Services bridging
  // These services are registered manually in CorePackageIntegration
  // but need to be exposed to Injectable for dependency resolution

  @lazySingleton
  ISubscriptionRepository get subscriptionRepository =>
      GetIt.I<ISubscriptionRepository>();

  @lazySingleton
  IAuthRepository get authRepository => GetIt.I<IAuthRepository>();

  @lazySingleton
  ConnectivityService get connectivityService => GetIt.I<ConnectivityService>();

  @lazySingleton
  FirebaseDeviceService get firebaseDeviceService =>
      GetIt.I<FirebaseDeviceService>();

  @lazySingleton
  ILocalStorageRepository get localStorageRepository =>
      GetIt.I<ILocalStorageRepository>();
}
