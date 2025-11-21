import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/mock_premium_service.dart';
import '../interfaces/i_premium_service.dart';

part 'premium_providers.g.dart';

@Riverpod(keepAlive: true)
IPremiumService premiumService(PremiumServiceRef ref) {
  return MockPremiumService();
}
