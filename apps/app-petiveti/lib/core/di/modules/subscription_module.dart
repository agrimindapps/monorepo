import 'package:core/core.dart';

import '../../../features/subscription/data/datasources/subscription_local_datasource.dart';
import '../../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../../features/subscription/domain/usecases/subscription_usecases.dart';
import '../di_module.dart';

/// Subscription module responsible for subscription-related dependencies
///
/// Follows SRP: Single responsibility of subscription services registration
/// Follows DIP: Depends on abstractions via DIModule interface
class SubscriptionModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<SubscriptionLocalDataSource>(
      () => SubscriptionLocalDataSourceImpl(),
    );

    getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
        subscriptionRepository: getIt<ISubscriptionRepository>(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(
        localDataSource: getIt<SubscriptionLocalDataSource>(),
        remoteDataSource: getIt<SubscriptionRemoteDataSource>(),
      ),
    );

    // Use cases
    getIt.registerLazySingleton<GetAvailablePlans>(
      () => GetAvailablePlans(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<GetCurrentSubscription>(
      () => GetCurrentSubscription(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<SubscribeToPlan>(
      () => SubscribeToPlan(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<CancelSubscription>(
      () => CancelSubscription(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<PauseSubscription>(
      () => PauseSubscription(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<ResumeSubscription>(
      () => ResumeSubscription(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<UpgradePlan>(
      () => UpgradePlan(getIt<SubscriptionRepository>()),
    );

    getIt.registerLazySingleton<RestorePurchases>(
      () => RestorePurchases(getIt<SubscriptionRepository>()),
    );
  }
}
