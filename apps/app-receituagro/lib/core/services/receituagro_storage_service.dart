import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

/// Adapter para ReceitaAgroStorageService que usa HiveStorageService do core
/// Preserva a interface existente enquanto migra para o serviço padronizado
class ReceitaAgroStorageService {
  // Nomes das boxes específicas do ReceitaAgro
  static const String _preferencesBox = 'receituagro_preferences';
  static const String _cacheBox = 'receituagro_cache';
  static const String _favoritesBox = 'receituagro_favorites';
  static const String _offlineDataBox = 'receituagro_offline_data';
  
  // Usando o HiveStorageService do core package
  final HiveStorageService _hiveStorage = HiveStorageService();
  bool _isInitialized = false;
  
  /// Expõe o HiveStorageService interno para compatibilidade com DI
  HiveStorageService get hiveStorage => _hiveStorage;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Inicializa o HiveStorageService do core
    final result = await _hiveStorage.initialize();
    
    result.fold(
      (failure) => throw Exception('Erro ao inicializar storage: ${failure.message}'),
      (_) => _isInitialized = true,
    );
  }
  
  // Preferences - usando HiveStorageService
  Future<void> savePreference(String key, dynamic value) async {
    final result = await _hiveStorage.save(key: key, data: value, box: _preferencesBox);
    result.fold(
      (failure) => throw Exception('Erro ao salvar preferência: ${failure.message}'),
      (_) {},
    );
  }
  
  T? getPreference<T>(String key, {T? defaultValue}) {
    // Implementação temporária - deve ser async no futuro
    // Por enquanto retorna valor padrão para manter compatibilidade
    try {
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
  
  Future<void> removePreference(String key) async {
    final result = await _hiveStorage.remove(key: key, box: _preferencesBox);
    result.fold(
      (failure) => throw Exception('Erro ao remover preferência: ${failure.message}'),
      (_) {},
    );
  }
  
  Future<void> clearAllPreferences() async {
    final result = await _hiveStorage.clear(box: _preferencesBox);
    result.fold(
      (failure) => throw Exception('Erro ao limpar preferências: ${failure.message}'),
      (_) {},
    );
  }
  
  // Cache - usando HiveStorageService com TTL
  Future<void> saveToCache(String key, dynamic value, {Duration? expiry}) async {
    Either<Failure, void> result;
    
    if (expiry != null) {
      // Usar TTL do HiveStorageService
      result = await _hiveStorage.saveWithTTL(
        key: key,
        data: value,
        ttl: expiry,
        box: _cacheBox,
      );
    } else {
      // Salvar sem expiração
      result = await _hiveStorage.save(key: key, data: value, box: _cacheBox);
    }
    
    result.fold(
      (failure) => throw Exception('Erro ao salvar no cache: ${failure.message}'),
      (_) {},
    );
  }
  
  T? getFromCache<T>(String key) {
    // Por enquanto, retorna null e implementaremos versão async posteriormente
    // Mantemos compatibilidade com interface existente
    try {
      return null; // Implementação temporária
    } catch (e) {
      return null;
    }
  }
  
  Future<void> clearCache() async {
    final result = await _hiveStorage.clear(box: _cacheBox);
    result.fold(
      (failure) => throw Exception('Erro ao limpar cache: ${failure.message}'),
      (_) {},
    );
  }
  
  // Favorites - usando HiveStorageService
  Future<void> addFavorite(String type, String id, Map<String, dynamic> data) async {
    final key = '${type}_$id';
    final favoriteData = {
      'id': id,
      'type': type,
      'data': data,
      'addedAt': DateTime.now().toIso8601String(),
    };
    final result = await _hiveStorage.save(
      key: key,
      data: favoriteData,
      box: _favoritesBox,
    );
    result.fold(
      (failure) => throw Exception('Erro ao adicionar favorito: ${failure.message}'),
      (_) {},
    );
  }
  
  Future<void> removeFavorite(String type, String id) async {
    final key = '${type}_$id';
    final result = await _hiveStorage.remove(key: key, box: _favoritesBox);
    result.fold(
      (failure) => throw Exception('Erro ao remover favorito: ${failure.message}'),
      (_) {},
    );
  }
  
  bool isFavorite(String type, String id) {
    // Implementação temporária - deve ser async no futuro
    try {
      return false; // Por enquanto retorna false
    } catch (e) {
      return false;
    }
  }
  
  List<Map<String, dynamic>> getFavoritesByType(String type) {
    // Implementação temporária - deve ser async no futuro
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }
  
  List<Map<String, dynamic>> getAllFavorites() {
    // Implementação temporária - deve ser async no futuro
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }
  
  // Offline Data - usando HiveStorageService
  Future<void> saveOfflineData(String collection, List<Map<String, dynamic>> data) async {
    final result = await _hiveStorage.saveOfflineData(
      key: collection,
      data: data,
    );
    result.fold(
      (failure) => throw Exception('Erro ao salvar dados offline: ${failure.message}'),
      (_) {},
    );
  }
  
  List<Map<String, dynamic>>? getOfflineData(String collection) {
    // Implementação temporária - deve ser async no futuro
    try {
      return null; // Por enquanto retorna null
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateOfflineDataItem(
    String collection,
    String itemId,
    Map<String, dynamic> updatedItem,
  ) async {
    // Implementação temporária - mantém lógica básica
    final data = getOfflineData(collection);
    if (data == null) return;
    
    final index = data.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      data[index] = updatedItem;
      await saveOfflineData(collection, data);
    }
  }
  
  Future<void> clearOfflineData(String collection) async {
    final result = await _hiveStorage.remove(key: collection, box: _offlineDataBox);
    result.fold(
      (failure) => throw Exception('Erro ao limpar dados offline: ${failure.message}'),
      (_) {},
    );
  }
  
  Future<void> clearAllOfflineData() async {
    final result = await _hiveStorage.clear(box: _offlineDataBox);
    result.fold(
      (failure) => throw Exception('Erro ao limpar todos os dados offline: ${failure.message}'),
      (_) {},
    );
  }
  
  // Notification Preferences - usando HiveStorageService
  Future<void> saveNotificationPreference(String type, bool enabled) async {
    final result = await _hiveStorage.save(
      key: 'notification_$type',
      data: enabled,
      box: _preferencesBox,
    );
    result.fold(
      (failure) => throw Exception('Erro ao salvar preferência de notificação: ${failure.message}'),
      (_) {},
    );
  }
  
  bool getNotificationPreference(String type, {bool defaultValue = true}) {
    // Implementação temporária - deve ser async no futuro
    try {
      return defaultValue; // Por enquanto retorna valor padrão
    } catch (e) {
      return defaultValue;
    }
  }
  
  Map<String, bool> getAllNotificationPreferences() {
    final preferences = <String, bool>{};
    final keys = ['pest_detected', 'application_reminder', 'new_recipes', 'weather_alerts'];
    
    for (final key in keys) {
      preferences[key] = getNotificationPreference(key);
    }
    
    return preferences;
  }
  
  // Search History - usando HiveStorageService
  Future<void> addSearchHistory(String query, String type) async {
    final history = getSearchHistory(type);
    history.remove(query);
    history.insert(0, query);
    
    if (history.length > 10) {
      history.removeLast();
    }
    
    final result = await _hiveStorage.save(
      key: 'search_history_$type',
      data: history,
      box: _preferencesBox,
    );
    result.fold(
      (failure) => throw Exception('Erro ao adicionar ao histórico de busca: ${failure.message}'),
      (_) {},
    );
  }
  
  List<String> getSearchHistory(String type) {
    // Implementação temporária - deve ser async no futuro
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }
  
  Future<void> clearSearchHistory(String type) async {
    final result = await _hiveStorage.remove(
      key: 'search_history_$type',
      box: _preferencesBox,
    );
    result.fold(
      (failure) => throw Exception('Erro ao limpar histórico de busca: ${failure.message}'),
      (_) {},
    );
  }
  
  // App Statistics - usando HiveStorageService
  Future<void> incrementStatistic(String key) async {
    // Busca valor atual (implementação temporária)
    int current = 0; // Por enquanto começa com 0
    
    final result = await _hiveStorage.save(
      key: 'stat_$key',
      data: current + 1,
      box: _preferencesBox,
    );
    result.fold(
      (failure) => throw Exception('Erro ao incrementar estatística: ${failure.message}'),
      (_) {},
    );
  }
  
  int getStatistic(String key) {
    // Implementação temporária - deve ser async no futuro
    try {
      return 0; // Por enquanto retorna 0
    } catch (e) {
      return 0;
    }
  }
  
  Map<String, int> getAllStatistics() {
    // Implementação temporária - deve ser async no futuro
    try {
      return {}; // Por enquanto retorna mapa vazio
    } catch (e) {
      return {};
    }
  }
  
  // Cleanup - usando HiveStorageService
  Future<void> dispose() async {
    await _hiveStorage.dispose();
  }
}