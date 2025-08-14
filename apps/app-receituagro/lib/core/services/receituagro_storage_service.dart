import 'package:hive_flutter/hive_flutter.dart';

class ReceitaAgroStorageService {
  static const String _preferencesBox = 'receituagro_preferences';
  static const String _cacheBox = 'receituagro_cache';
  static const String _favoritesBox = 'receituagro_favorites';
  static const String _offlineDataBox = 'receituagro_offline_data';
  
  late Box _preferencesBox_;
  late Box _cacheBox_;
  late Box _favoritesBox_;
  late Box _offlineDataBox_;
  
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _preferencesBox_ = await Hive.openBox(_preferencesBox);
    _cacheBox_ = await Hive.openBox(_cacheBox);
    _favoritesBox_ = await Hive.openBox(_favoritesBox);
    _offlineDataBox_ = await Hive.openBox(_offlineDataBox);
  }
  
  // Preferences
  Future<void> savePreference(String key, dynamic value) async {
    await _preferencesBox_.put(key, value);
  }
  
  T? getPreference<T>(String key, {T? defaultValue}) {
    return _preferencesBox_.get(key, defaultValue: defaultValue) as T?;
  }
  
  Future<void> removePreference(String key) async {
    await _preferencesBox_.delete(key);
  }
  
  Future<void> clearAllPreferences() async {
    await _preferencesBox_.clear();
  }
  
  // Cache
  Future<void> saveToCache(String key, dynamic value, {Duration? expiry}) async {
    final data = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _cacheBox_.put(key, data);
  }
  
  T? getFromCache<T>(String key) {
    final data = _cacheBox_.get(key);
    if (data == null) return null;
    
    final timestamp = data['timestamp'] as int;
    final expiry = data['expiry'] as int?;
    
    if (expiry != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > expiry) {
        _cacheBox_.delete(key);
        return null;
      }
    }
    
    return data['value'] as T?;
  }
  
  Future<void> clearCache() async {
    await _cacheBox_.clear();
  }
  
  // Favorites
  Future<void> addFavorite(String type, String id, Map<String, dynamic> data) async {
    final key = '${type}_$id';
    final favoriteData = {
      'id': id,
      'type': type,
      'data': data,
      'addedAt': DateTime.now().toIso8601String(),
    };
    await _favoritesBox_.put(key, favoriteData);
  }
  
  Future<void> removeFavorite(String type, String id) async {
    final key = '${type}_$id';
    await _favoritesBox_.delete(key);
  }
  
  bool isFavorite(String type, String id) {
    final key = '${type}_$id';
    return _favoritesBox_.containsKey(key);
  }
  
  List<Map<String, dynamic>> getFavoritesByType(String type) {
    final favorites = <Map<String, dynamic>>[];
    for (var key in _favoritesBox_.keys) {
      if (key.toString().startsWith('${type}_')) {
        final data = _favoritesBox_.get(key);
        if (data != null) {
          favorites.add(Map<String, dynamic>.from(data));
        }
      }
    }
    favorites.sort((a, b) => b['addedAt'].compareTo(a['addedAt']));
    return favorites;
  }
  
  List<Map<String, dynamic>> getAllFavorites() {
    final favorites = <Map<String, dynamic>>[];
    for (var value in _favoritesBox_.values) {
      if (value != null) {
        favorites.add(Map<String, dynamic>.from(value));
      }
    }
    favorites.sort((a, b) => b['addedAt'].compareTo(a['addedAt']));
    return favorites;
  }
  
  // Offline Data
  Future<void> saveOfflineData(String collection, List<Map<String, dynamic>> data) async {
    await _offlineDataBox_.put(collection, data);
  }
  
  List<Map<String, dynamic>>? getOfflineData(String collection) {
    final data = _offlineDataBox_.get(collection);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<void> updateOfflineDataItem(
    String collection,
    String itemId,
    Map<String, dynamic> updatedItem,
  ) async {
    final data = getOfflineData(collection);
    if (data == null) return;
    
    final index = data.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      data[index] = updatedItem;
      await saveOfflineData(collection, data);
    }
  }
  
  Future<void> clearOfflineData(String collection) async {
    await _offlineDataBox_.delete(collection);
  }
  
  Future<void> clearAllOfflineData() async {
    await _offlineDataBox_.clear();
  }
  
  // Notification Preferences
  Future<void> saveNotificationPreference(String type, bool enabled) async {
    await _preferencesBox_.put('notification_$type', enabled);
  }
  
  bool getNotificationPreference(String type, {bool defaultValue = true}) {
    return _preferencesBox_.get('notification_$type', defaultValue: defaultValue) as bool;
  }
  
  Map<String, bool> getAllNotificationPreferences() {
    final preferences = <String, bool>{};
    final keys = ['pest_detected', 'application_reminder', 'new_recipes', 'weather_alerts'];
    
    for (final key in keys) {
      preferences[key] = getNotificationPreference(key);
    }
    
    return preferences;
  }
  
  // Search History
  Future<void> addSearchHistory(String query, String type) async {
    final history = getSearchHistory(type);
    history.remove(query);
    history.insert(0, query);
    
    if (history.length > 10) {
      history.removeLast();
    }
    
    await _preferencesBox_.put('search_history_$type', history);
  }
  
  List<String> getSearchHistory(String type) {
    final history = _preferencesBox_.get('search_history_$type');
    if (history == null) return [];
    return List<String>.from(history);
  }
  
  Future<void> clearSearchHistory(String type) async {
    await _preferencesBox_.delete('search_history_$type');
  }
  
  // App Statistics
  Future<void> incrementStatistic(String key) async {
    final current = _preferencesBox_.get('stat_$key', defaultValue: 0) as int;
    await _preferencesBox_.put('stat_$key', current + 1);
  }
  
  int getStatistic(String key) {
    return _preferencesBox_.get('stat_$key', defaultValue: 0) as int;
  }
  
  Map<String, int> getAllStatistics() {
    final stats = <String, int>{};
    for (var key in _preferencesBox_.keys) {
      if (key.toString().startsWith('stat_')) {
        final statKey = key.toString().replaceFirst('stat_', '');
        stats[statKey] = _preferencesBox_.get(key) as int;
      }
    }
    return stats;
  }
  
  // Cleanup
  Future<void> dispose() async {
    await _preferencesBox_.close();
    await _cacheBox_.close();
    await _favoritesBox_.close();
    await _offlineDataBox_.close();
  }
}