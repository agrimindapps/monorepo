import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../interfaces/i_premium_service.dart';
import '../services/mock_premium_service.dart';

part 'premium_providers.g.dart';

@riverpod
IPremiumService premiumService(Ref ref) {
  return MockPremiumService();
}
