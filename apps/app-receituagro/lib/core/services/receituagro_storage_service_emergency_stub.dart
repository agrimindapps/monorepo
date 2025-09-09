/// EMERGENCY FIX: Implementação stub completa do ReceitaAgroStorageService
/// Esta versão funciona sem dependências do Core Package
class ReceitaAgroStorageServiceEmergencyStub {
  bool _isInitialized = false;
  
  ReceitaAgroStorageServiceEmergencyStub();
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }
  
  // Preferences
  Future<void> savePreference(String key, dynamic value) async {}
  
  T? getPreference<T>(String key, {T? defaultValue}) => defaultValue;
  
  Future<void> removePreference(String key) async {}
  
  Future<void> clearAllPreferences() async {}
  
  // Cache
  Future<void> saveToCache(String key, dynamic value, {Duration? expiry}) async {}
  
  T? getFromCache<T>(String key) => null;
  
  Future<void> clearCache() async {}
  
  // Favorites
  Future<void> addFavorite(String type, String id, Map<String, dynamic> data) async {}
  
  Future<void> removeFavorite(String type, String id) async {}
  
  bool isFavorite(String type, String id) => false;
  
  List<Map<String, dynamic>> getFavoritesByType(String type) => [];
  
  List<Map<String, dynamic>> getAllFavorites() => [];
  
  // Offline Data
  Future<void> saveOfflineData(String collection, List<Map<String, dynamic>> data) async {}
  
  List<Map<String, dynamic>>? getOfflineData(String collection) => [];
  
  Future<void> updateOfflineDataItem(
    String collection,
    String itemId,
    Map<String, dynamic> updatedItem,
  ) async {}
  
  Future<void> clearOfflineData(String collection) async {}
  
  Future<void> clearAllOfflineData() async {}
  
  // Notification Preferences
  Future<void> saveNotificationPreference(String type, bool enabled) async {}
  
  bool getNotificationPreference(String type, {bool defaultValue = true}) => defaultValue;
  
  Map<String, bool> getAllNotificationPreferences() => {
    'pest_detected': true,
    'application_reminder': true,
    'new_recipes': true,
    'weather_alerts': true,
  };
  
  // Search History
  Future<void> addSearchHistory(String query, String type) async {}
  
  List<String> getSearchHistory(String type) => [];
  
  Future<void> clearSearchHistory(String type) async {}
  
  // App Statistics
  Future<void> incrementStatistic(String key) async {}
  
  int getStatistic(String key) => 0;
  
  Map<String, int> getAllStatistics() => {};
  
  // Cleanup
  Future<void> dispose() async {}
}