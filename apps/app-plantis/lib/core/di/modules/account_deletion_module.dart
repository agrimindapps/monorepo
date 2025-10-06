import 'package:core/core.dart';

/// Módulo de Dependency Injection para Account Deletion
/// Registra todos os serviços necessários para exclusão de conta segura
class AccountDeletionModule {
  static void init(GetIt sl) {
    sl.registerLazySingleton<FirestoreDeletionService>(
      () => FirestoreDeletionService(),
    );
    sl.registerLazySingleton<RevenueCatCancellationService>(
      () => RevenueCatCancellationService(),
    );
    sl.registerLazySingleton<AccountDeletionRateLimiter>(
      () => AccountDeletionRateLimiter(),
    );
    sl.registerLazySingleton<EnhancedAccountDeletionService>(
      () => EnhancedAccountDeletionService(
        authRepository: sl<IAuthRepository>(),
        appDataCleaner: sl<IAppDataCleaner>(),
        firestoreDeletion: sl<FirestoreDeletionService>(),
        revenueCatCancellation: sl<RevenueCatCancellationService>(),
        rateLimiter: sl<AccountDeletionRateLimiter>(),
      ),
    );
  }
}
