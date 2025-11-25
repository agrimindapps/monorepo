import 'package:flutter_riverpod/flutter_riverpod.dart';
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
PromoErrorHandlingService promoErrorHandlingService(Ref ref) {
  return PromoErrorHandlingService();
}

@riverpod
PromoRepository promoRepository(Ref ref) {
  final errorHandlingService = ref.watch(promoErrorHandlingServiceProvider);
  return PromoRepositoryImpl(errorHandlingService);
}

@riverpod
PromoValidationService promoValidationService(Ref ref) {
  return PromoValidationService();
}

@riverpod
GetPromoContent getPromoContent(Ref ref) {
  return GetPromoContent(ref.watch(promoRepositoryProvider));
}

@riverpod
SubmitPreRegistration submitPreRegistration(Ref ref) {
  return SubmitPreRegistration(
    ref.watch(promoRepositoryProvider),
    ref.watch(promoValidationServiceProvider),
  );
}

@riverpod
TrackAnalytics trackAnalytics(Ref ref) {
  return TrackAnalytics(
    ref.watch(promoRepositoryProvider),
    ref.watch(promoValidationServiceProvider),
  );
}
