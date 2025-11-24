import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/promo_repository_impl.dart';
import '../../data/services/promo_error_handling_service.dart';
import '../../domain/repositories/promo_repository.dart';
import '../../domain/services/promo_validation_service.dart';
import '../../domain/usecases/get_promo_content.dart';
import '../../domain/usecases/submit_pre_registration.dart';
import '../../domain/usecases/track_analytics.dart';

part 'promo_providers.g.dart';

@riverpod
PromoErrorHandlingService promoErrorHandlingService(PromoErrorHandlingServiceRef ref) {
  return PromoErrorHandlingService();
}

@riverpod
PromoRepository promoRepository(PromoRepositoryRef ref) {
  final errorHandlingService = ref.watch(promoErrorHandlingServiceProvider);
  return PromoRepositoryImpl(errorHandlingService);
}

@riverpod
PromoValidationService promoValidationService(PromoValidationServiceRef ref) {
  return PromoValidationService();
}

@riverpod
GetPromoContent getPromoContent(GetPromoContentRef ref) {
  return GetPromoContent(ref.watch(promoRepositoryProvider));
}

@riverpod
SubmitPreRegistration submitPreRegistration(SubmitPreRegistrationRef ref) {
  return SubmitPreRegistration(
    ref.watch(promoRepositoryProvider),
    ref.watch(promoValidationServiceProvider),
  );
}

@riverpod
TrackAnalytics trackAnalytics(TrackAnalyticsRef ref) {
  return TrackAnalytics(
    ref.watch(promoRepositoryProvider),
    ref.watch(promoValidationServiceProvider),
  );
}
