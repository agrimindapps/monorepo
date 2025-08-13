import 'package:get_it/get_it.dart';
import 'package:core/core.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Analytics Repository
  sl.registerLazySingleton<IAnalyticsRepository>(
    () => FirebaseAnalyticsService(),
  );

  // Crashlytics Repository
  sl.registerLazySingleton<ICrashlyticsRepository>(
    () => FirebaseCrashlyticsService(),
  );

  // Subscription Repository (RevenueCat)
  sl.registerLazySingleton<ISubscriptionRepository>(
    () => RevenueCatService(),
  );

  // App Rating Repository
  sl.registerLazySingleton<IAppRatingRepository>(() => AppRatingService(
    appStoreId: '123456789', // TODO: Replace with actual App Store ID for ReceitaAgro
    googlePlayId: 'br.com.agrimind.pragassoja', // Using the correct package ID
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  ));
}