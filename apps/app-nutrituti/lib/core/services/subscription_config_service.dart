// STUB - FASE 0.7
// TODO FASE 1: Implementar integração real com RevenueCat

class SubscriptionConfigService {
  static final SubscriptionConfigService instance = SubscriptionConfigService._();
  SubscriptionConfigService._();

  // Entitlement ID (premium feature access)
  String get entitlementId => 'premium';

  // Product IDs disponíveis
  List<String> get productIds => [
    'nutrituti_monthly_premium',
    'nutrituti_yearly_premium',
    'nutrituti_lifetime_premium',
  ];

  // Product ID mensal
  String get monthlyProductId => 'nutrituti_monthly_premium';

  // Product ID anual
  String get yearlyProductId => 'nutrituti_yearly_premium';

  // Product ID vitalício
  String get lifetimeProductId => 'nutrituti_lifetime_premium';

  // API Key RevenueCat (stub - configurar em FASE 1)
  String get apiKey => 'STUB_API_KEY';

  // App User ID (stub)
  String? get appUserId => null;

  // Verificar se é premium (sempre false no stub)
  Future<bool> isPremium() async => false;

  // Inicializar para app específico
  Future<void> initializeForApp(String appId) async {
    // TODO FASE 1: Implementar inicialização por app
  }

  // TODO FASE 1: Métodos para premium_page
  List<Map<String, dynamic>> get inappProductIds => [
    {'id': monthlyProductId, 'title': 'Mensal', 'price': 'R\$ 9,90'},
    {'id': yearlyProductId, 'title': 'Anual', 'price': 'R\$ 89,90'},
  ];

  List<Map<String, dynamic>> get inappVantagens => [
    {'icon': '✓', 'text': 'Acesso ilimitado a todas as funcionalidades'},
    {'icon': '✓', 'text': 'Sem anúncios'},
    {'icon': '✓', 'text': 'Suporte prioritário'},
  ];

  List<Map<String, dynamic>> getCurrentProducts() => inappProductIds;
  List<Map<String, dynamic>> getCurrentAdvantages() => inappVantagens;
  String getCurrentAppName() => 'Nutrituti';
  bool hasValidApiKeys() => true; // Stub
  List<String> getCurrentConfigErrors() => [];
}
