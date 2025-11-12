import 'package:core/core.dart' hide Column;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Módulo para registrar dependências externas (Firebase, Connectivity)
/// IMPORTANTE: Não inclui IAuthRepository, ISubscriptionRepository, ILocalStorageRepository
/// pois estes são registrados em injection_container.dart para evitar loops
@module
abstract class ExternalModule {
  /// Firebase Storage (required by BackupRepository)
  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  /// Connectivity (required by BackupScheduler)
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// ConnectivityService (required by SyncOperations)
  @lazySingleton
  ConnectivityService get connectivityService => ConnectivityService.instance;

  /// SharedPreferences (required by LocalSubscriptionProvider)
  ///
  /// Usado para cache offline de subscription status,
  /// garantindo que plant limits funcionem sem internet.
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// IAuthRepository - registered manually in injection_container.dart, but needs to be
  /// accessible via Injectable for module dependencies
  @lazySingleton
  IAuthRepository get authRepository => FirebaseAuthService();

  /// ISubscriptionRepository - registered manually in injection_container.dart, but needs to be
  /// accessible via Injectable for module dependencies
  @lazySingleton
  ISubscriptionRepository get subscriptionRepository => RevenueCatService();

  /// FirebaseFirestore instance for Firebase providers
  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
}
