import 'package:core/core.dart';

import '../../../features/promo/data/repositories/promo_repository_impl.dart';
import '../../../features/promo/data/services/promo_error_handling_service.dart';
import '../../../features/promo/domain/repositories/promo_repository.dart';
import '../../../features/promo/domain/services/promo_validation_service.dart';
import '../../../features/promo/domain/usecases/get_promo_content.dart';
import '../../../features/promo/domain/usecases/submit_pre_registration.dart';
import '../../../features/promo/domain/usecases/track_analytics.dart';
import '../di_module.dart';

/// Promo module responsible for promotional content dependencies
///
/// Follows SRP: Single responsibility of promo services registration
/// Follows DIP: Depends on abstractions via DIModule interface
class PromoModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    getIt.registerLazySingleton<PromoValidationService>(
      () => PromoValidationService(),
    );

    getIt.registerLazySingleton<PromoErrorHandlingService>(
      () => PromoErrorHandlingService(),
    );

    // Repository
    getIt.registerLazySingleton<PromoRepository>(
      () => PromoRepositoryImpl(
        getIt<PromoErrorHandlingService>(),
      ),
    );

    // Use Cases
    getIt.registerLazySingleton<GetPromoContent>(
      () => GetPromoContent(getIt<PromoRepository>()),
    );

    getIt.registerLazySingleton<SubmitPreRegistration>(
      () => SubmitPreRegistration(
        getIt<PromoRepository>(),
        getIt<PromoValidationService>(),
      ),
    );

    getIt.registerLazySingleton<TrackAnalytics>(
      () => TrackAnalytics(
        getIt<PromoRepository>(),
        getIt<PromoValidationService>(),
      ),
    );
  }
}
