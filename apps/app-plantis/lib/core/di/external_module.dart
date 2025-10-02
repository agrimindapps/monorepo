import 'package:core/core.dart';

/// Módulo para registrar dependências externas (Firebase, Hive, Connectivity)
/// IMPORTANTE: Não inclui IAuthRepository, ISubscriptionRepository, ILocalStorageRepository
/// pois estes são registrados em injection_container.dart para evitar loops
@module
abstract class ExternalModule {
  /// HiveInterface (required by SyncQueue)
  @lazySingleton
  HiveInterface get hiveInterface => Hive;

  /// Firebase Storage (required by BackupRepository)
  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  /// Connectivity (required by BackupScheduler)
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// ConnectivityService (required by SyncOperations)
  @lazySingleton
  ConnectivityService get connectivityService => ConnectivityService.instance;
}
