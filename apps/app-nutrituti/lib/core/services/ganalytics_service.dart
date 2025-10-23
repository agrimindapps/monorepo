// STUB - FASE 0.7
// TODO FASE 1: Implementar integração real com Google Analytics

class GAnalyticsService {
  static final GAnalyticsService instance = GAnalyticsService._();
  GAnalyticsService._();

  bool _isInitialized = false;

  // Inicializar Analytics
  Future<void> initialize() async {
    // TODO: Implementar inicialização do GA
    _isInitialized = true;
  }

  // Log de evento
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_isInitialized) return;
    // TODO: Implementar log real
    // debugPrint('GA Event: $name - $parameters');
  }

  // Log de screen view
  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  // Log de compra
  void logPurchase({
    required String productId,
    required double value,
    String? currency,
  }) {
    logEvent('purchase', parameters: {
      'product_id': productId,
      'value': value,
      'currency': currency ?? 'BRL',
    });
  }

  // Setar user ID
  void setUserId(String? userId) {
    // TODO: Implementar
  }

  // Setar user property
  void setUserProperty(String name, String? value) {
    // TODO: Implementar
  }

  // Log de evento customizado (alias para logEvent)
  void logCustomEvent(String name, {Map<String, dynamic>? parameters}) {
    logEvent(name, parameters: parameters);
  }
}
