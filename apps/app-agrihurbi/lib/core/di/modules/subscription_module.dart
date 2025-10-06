import 'package:core/core.dart';

import '../../../features/subscription/data/datasources/subscription_local_datasource.dart';
import '../../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../../features/subscription/domain/usecases/subscription_usecases.dart';

void initSubscriptionModule(GetIt sl) {
    sl.registerLazySingleton<SubscriptionLocalDataSource>(
      () => SubscriptionLocalDataSourceImpl(),
    );

    sl.registerLazySingleton<SubscriptionRemoteDataSource>(
      () => SubscriptionRemoteDataSourceImpl(
        firestore: sl<FirebaseFirestore>(),
        subscriptionRepository: sl<ISubscriptionRepository>(),
      ),
    );
    sl.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(
        localDataSource: sl<SubscriptionLocalDataSource>(),
        remoteDataSource: sl<SubscriptionRemoteDataSource>(),
      ),
    );
    sl.registerLazySingleton(() => GetAvailablePlans(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => GetCurrentSubscription(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => SubscribeToPlan(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => CancelSubscription(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => PauseSubscription(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => ResumeSubscription(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => UpgradePlan(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => RestorePurchases(sl<SubscriptionRepository>()));
    sl.registerLazySingleton(() => ValidateReceipt(sl<SubscriptionRepository>()));
}
