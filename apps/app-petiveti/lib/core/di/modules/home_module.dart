import 'package:core/core.dart' show GetIt;

import '../../../features/home/domain/repositories/home_aggregation_repository.dart';
import '../../../features/home/domain/repositories/notification_repository.dart';
import '../../../features/home/domain/repositories/dashboard_repository.dart';
import '../../../features/home/data/repositories/home_aggregation_repository_impl.dart';
import '../../../features/home/data/repositories/notification_repository_impl.dart';
import '../../../features/home/data/repositories/dashboard_repository_impl.dart';
import '../di_module.dart';

/// Home feature DI module
///
/// Follows DIP: Registers all home repositories and providers
/// Follows SRP: Only responsible for home feature dependency configuration
class HomeModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Register repositories as interfaces (DIP)
    getIt.registerLazySingleton<HomeAggregationRepository>(
      () => HomeAggregationRepositoryImpl(),
    );

    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(),
    );

    getIt.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(),
    );
  }
}
