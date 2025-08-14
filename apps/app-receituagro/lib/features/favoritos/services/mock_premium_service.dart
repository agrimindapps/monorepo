import 'favoritos_data_service.dart';

class MockPremiumService implements IPremiumService {
  @override
  bool get isPremium => true; // Mock implementation - always premium for testing
}