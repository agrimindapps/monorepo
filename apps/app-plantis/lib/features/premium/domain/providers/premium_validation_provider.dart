import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/premium_validation_service.dart';

part 'premium_validation_provider.g.dart';

@riverpod
PremiumValidationService premiumValidationService(Ref ref) {
  return PremiumValidationService();
}
