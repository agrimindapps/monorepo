// STUB - FASE 0.7
// TODO FASE 1: Implementar integração real com Firebase Analytics

class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService instance = FirebaseAnalyticsService._();
  FirebaseAnalyticsService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_isInitialized) return;
    // TODO: Implementar log real
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  void setUserId(String? userId) {
    // TODO: Implementar
  }
}
