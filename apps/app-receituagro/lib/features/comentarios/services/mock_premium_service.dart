import 'comentarios_service.dart';

class MockPremiumService implements IPremiumService {
  bool _isPremium;

  MockPremiumService({bool isPremium = true}) : _isPremium = isPremium;

  @override
  bool get isPremium => _isPremium;

  void setPremiumStatus(bool status) {
    _isPremium = status;
  }
}