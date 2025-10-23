// STUB - FASE 0.7
// TODO FASE 1: Implementar integração real com in_app_purchase

class InAppPurchaseService {
  static final InAppPurchaseService instance = InAppPurchaseService._();
  InAppPurchaseService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<bool> purchaseProduct(String productId) async {
    if (!_isInitialized) return false;
    return false;
  }

  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;
    return false;
  }

  Future<bool> isPremium() async {
    return false;
  }

  Future<void> inAppLoadDataSignature() async {
    // TODO FASE 1: Implementar carregamento de dados de signature
  }

  // TODO FASE 1: Métodos adicionais para subscription_page
  Future<void> init() async {
    await initialize();
  }

  Future<List<Map<String, dynamic>>> getVantagens() async {
    return [
      {'text': 'Acesso ilimitado'},
      {'text': 'Sem anúncios'},
      {'text': 'Suporte premium'},
    ];
  }

  Future<String> getTermosUso() async {
    return 'https://example.com/terms';
  }

  Future<void> launchTermoUso() async {
    // TODO: Implementar abertura de URL
  }

  Future<void> launchPoliticaPrivacidade() async {
    // TODO: Implementar abertura de URL
  }
}
