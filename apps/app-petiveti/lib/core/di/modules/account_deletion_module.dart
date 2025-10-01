import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

/// Módulo de Dependency Injection para Account Deletion
/// Registra todos os serviços necessários para exclusão de conta segura
class AccountDeletionModule {
  static void init(GetIt sl) {
    // 1. FirestoreDeletionService
    sl.registerLazySingleton<FirestoreDeletionService>(
      () => FirestoreDeletionService(),
    );

    // 2. RevenueCatCancellationService
    sl.registerLazySingleton<RevenueCatCancellationService>(
      () => RevenueCatCancellationService(),
    );

    // 3. AccountDeletionRateLimiter
    sl.registerLazySingleton<AccountDeletionRateLimiter>(
      () => AccountDeletionRateLimiter(),
    );

    // 4. EnhancedAccountDeletionService
    // Depende de: IAuthRepository, IAppDataCleaner, e os serviços acima
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
