import 'receituagro_storage_service.dart';

/// EMERGENCY FIX: Stub temporário para ReceitaAgroStorageService
/// Esta implementação retorna valores padrão/vazios para manter o app funcionando
/// durante a correção do sistema Hive
class ReceitaAgroStorageServiceStub extends ReceitaAgroStorageService {
  bool _isInitialized = false;
  
  ReceitaAgroStorageServiceStub() : super.stub();
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    // Simulação de inicialização bem-sucedida
    _isInitialized = true;
  }
  
  // Preferences - implementação stub
  @override
  Future<void> savePreference(String key, dynamic value) async {
    // Não faz nada - implementação stub
  }
  
  @override
  T? getPreference<T>(String key, {T? defaultValue}) {
    // Sempre retorna o valor padrão
    return defaultValue;
  }
  
  @override
  Future<void> removePreference(String key) async {
    // Não faz nada - implementação stub
  }
  
  @override
  Future<void> clearAllPreferences() async {
    // Não faz nada - implementação stub
  }
  
  // Cache - implementação stub
  @override
  Future<void> saveToCache(String key, dynamic value, {Duration? expiry}) async {
    // Não faz nada - implementação stub
  }
  
  @override
  T? getFromCache<T>(String key) {
    // Sempre retorna null
    return null;
  }
  
  @override
  Future<void> clearCache() async {
    // Não faz nada - implementação stub
  }
  
  // Favorites - implementação stub
  @override
  Future<void> addFavorite(String type, String id, Map<String, dynamic> data) async {
    // Não faz nada - implementação stub
  }
  
  @override
  Future<void> removeFavorite(String type, String id) async {
    // Não faz nada - implementação stub
  }
  
  @override
  bool isFavorite(String type, String id) {
    // Sempre retorna false
    return false;
  }
  
  @override
  List<Map<String, dynamic>> getFavoritesByType(String type) {
    // Sempre retorna lista vazia
    return [];
  }
  
  @override
  List<Map<String, dynamic>> getAllFavorites() {
    // Sempre retorna lista vazia
    return [];
  }
  
  // Offline Data - implementação stub
  @override
  Future<void> saveOfflineData(String collection, List<Map<String, dynamic>> data) async {
    // Não faz nada - implementação stub
  }
  
  @override
  List<Map<String, dynamic>>? getOfflineData(String collection) {
    // Sempre retorna lista vazia
    return [];
  }
  
  @override
  Future<void> updateOfflineDataItem(
    String collection,
    String itemId,
    Map<String, dynamic> updatedItem,
  ) async {
    // Não faz nada - implementação stub
  }
  
  @override
  Future<void> clearOfflineData(String collection) async {
    // Não faz nada - implementação stub
  }
  
  @override
  Future<void> clearAllOfflineData() async {
    // Não faz nada - implementação stub
  }
  
  // Notification Preferences - implementação stub
  @override
  Future<void> saveNotificationPreference(String type, bool enabled) async {
    // Não faz nada - implementação stub
  }
  
  @override
  bool getNotificationPreference(String type, {bool defaultValue = true}) {
    // Sempre retorna o valor padrão
    return defaultValue;
  }
  
  @override
  Map<String, bool> getAllNotificationPreferences() {
    // Retorna preferências padrão
    return {
      'pest_detected': true,
      'application_reminder': true,
      'new_recipes': true,
      'weather_alerts': true,
    };
  }
  
  // Search History - implementação stub
  @override
  Future<void> addSearchHistory(String query, String type) async {
    // Não faz nada - implementação stub
  }
  
  @override
  List<String> getSearchHistory(String type) {
    // Sempre retorna lista vazia
    return [];
  }
  
  @override
  Future<void> clearSearchHistory(String type) async {
    // Não faz nada - implementação stub
  }
  
  // App Statistics - implementação stub
  @override
  Future<void> incrementStatistic(String key) async {
    // Não faz nada - implementação stub
  }
  
  @override
  int getStatistic(String key) {
    // Sempre retorna 0
    return 0;
  }
  
  @override
  Map<String, int> getAllStatistics() {
    // Sempre retorna mapa vazio
    return {};
  }
  
  // Cleanup - implementação stub
  @override
  Future<void> dispose() async {
    // Não faz nada - implementação stub
  }
}