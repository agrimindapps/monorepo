import 'package:core/core.dart' hide Column;

/// Classe para representar falhas no sistema
class Failure {
  final String message;
  const Failure(this.message);
}

/// EMERGENCY FIX: Interface mínima para stub do storage
abstract class _IStorageStub {
  Future<Either<String, void>> initialize();
  Future<Either<String, void>> save({
    required String key,
    required dynamic data,
    String? box,
  });
  Future<Either<String, void>> saveWithTTL({
    required String key,
    required dynamic data,
    required Duration ttl,
    String? box,
  });
  Future<Either<String, void>> remove({required String key, String? box});
  Future<Either<String, void>> clear({String? box});
  Future<Either<String, void>> saveOfflineData({
    required String key,
    required List<Map<String, dynamic>> data,
  });
  Future<void> dispose();
}

/// EMERGENCY FIX: Implementação stub mínima do StorageService
class _StubStorageService implements _IStorageStub {
  @override
  Future<Either<String, void>> initialize() async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> save({
    required String key,
    required dynamic data,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> saveWithTTL({
    required String key,
    required dynamic data,
    required Duration ttl,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> remove({
    required String key,
    String? box,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> clear({String? box}) async {
    return const Right(null);
  }

  @override
  Future<Either<String, void>> saveOfflineData({
    required String key,
    required List<Map<String, dynamic>> data,
  }) async {
    return const Right(null);
  }

  @override
  Future<void> dispose() async {}
}

/// Preserva a interface existente enquanto migra para o serviço padronizado
class ReceitaAgroStorageService {
  static const String _preferencesBox = 'receituagro_preferences';
  static const String _cacheBox = 'receituagro_cache';
  static const String _favoritesBox = 'receituagro_favorites';
  static const String _offlineDataBox = 'receituagro_offline_data';
  final dynamic _storage;
  bool _isInitialized = false;

  ReceitaAgroStorageService(this._storage);

  /// EMERGENCY FIX: Constructor stub para uso sem Core Package
  /// Permite criar o service sem dependências externas durante correções
  ReceitaAgroStorageService.stub() : _storage = _StubStorageService();

  Future<void> initialize() async {
    if (_isInitialized) return;
    final result = await _storage.initialize();

    result.fold(
      (String failure) =>
          throw Exception('Erro ao inicializar storage: $failure'),
      (_) => _isInitialized = true,
    );
  }

  Future<void> savePreference(String key, dynamic value) async {
    final result = await _storage.save(
      key: key,
      data: value,
      box: _preferencesBox,
    );
    result.fold(
      (String failure) =>
          throw Exception('Erro ao salvar preferência: $failure'),
      (_) {},
    );
  }

  T? getPreference<T>(String key, {T? defaultValue}) {
    try {
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Future<void> removePreference(String key) async {
    final result = await _storage.remove(key: key, box: _preferencesBox);
    result.fold(
      (String failure) =>
          throw Exception('Erro ao remover preferência: $failure'),
      (_) {},
    );
  }

  Future<void> clearAllPreferences() async {
    final result = await _storage.clear(box: _preferencesBox);
    result.fold(
      (String failure) =>
          throw Exception('Erro ao limpar preferências: $failure'),
      (_) {},
    );
  }

  Future<void> saveToCache(
    String key,
    dynamic value, {
    Duration? expiry,
  }) async {
    Either<String, void> result;

    if (expiry != null) {
      result =
          (await _storage.saveWithTTL(
                key: key,
                data: value,
                ttl: expiry,
                box: _cacheBox,
              ))
              as Either<String, void>;
    } else {
      result =
          (await _storage.save(key: key, data: value, box: _cacheBox))
              as Either<String, void>;
    }

    result.fold(
      (String failure) => throw Exception('Erro ao salvar no cache: $failure'),
      (_) {},
    );
  }

  T? getFromCache<T>(String key) {
    try {
      return null; // Implementação temporária
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final result = await _storage.clear(box: _cacheBox);
    result.fold(
      (String failure) => throw Exception('Erro ao limpar cache: $failure'),
      (_) {},
    );
  }

  Future<void> addFavorite(
    String type,
    String id,
    Map<String, dynamic> data,
  ) async {
    final key = '${type}_$id';
    final favoriteData = {
      'id': id,
      'type': type,
      'data': data,
      'addedAt': DateTime.now().toIso8601String(),
    };
    final result = await _storage.save(
      key: key,
      data: favoriteData,
      box: _favoritesBox,
    );
    result.fold(
      (String failure) =>
          throw Exception('Erro ao adicionar favorito: $failure'),
      (_) {},
    );
  }

  Future<void> removeFavorite(String type, String id) async {
    final key = '${type}_$id';
    final result = await _storage.remove(key: key, box: _favoritesBox);
    result.fold(
      (String failure) => throw Exception('Erro ao remover favorito: $failure'),
      (_) {},
    );
  }

  bool isFavorite(String type, String id) {
    try {
      return false; // Por enquanto retorna false
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> getFavoritesByType(String type) {
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getAllFavorites() {
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }

  Future<void> saveOfflineData(
    String collection,
    List<Map<String, dynamic>> data,
  ) async {
    final result = await _storage.saveOfflineData(key: collection, data: data);
    result.fold(
      (String failure) =>
          throw Exception('Erro ao salvar dados offline: $failure'),
      (_) {},
    );
  }

  List<Map<String, dynamic>>? getOfflineData(String collection) {
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
    final data = getOfflineData(collection);
    if (data == null) return;

    final index = data.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      data[index] = updatedItem;
      await saveOfflineData(collection, data);
    }
  }

  Future<void> clearOfflineData(String collection) async {
    final result = await _storage.remove(key: collection, box: _offlineDataBox);
    result.fold(
      (String failure) =>
          throw Exception('Erro ao limpar dados offline: $failure'),
      (_) {},
    );
  }

  Future<void> clearAllOfflineData() async {
    final result = await _storage.clear(box: _offlineDataBox);
    result.fold(
      (String failure) =>
          throw Exception('Erro ao limpar todos os dados offline: $failure'),
      (_) {},
    );
  }

  Future<void> saveNotificationPreference(String type, bool enabled) async {
    final result = await _storage.save(
      key: 'notification_$type',
      data: enabled,
      box: _preferencesBox,
    );
    result.fold(
      (String failure) => throw Exception(
        'Erro ao salvar preferência de notificação: $failure',
      ),
      (_) {},
    );
  }

  bool getNotificationPreference(String type, {bool defaultValue = true}) {
    try {
      return defaultValue; // Por enquanto retorna valor padrão
    } catch (e) {
      return defaultValue;
    }
  }

  Map<String, bool> getAllNotificationPreferences() {
    final preferences = <String, bool>{};
    final keys = [
      'pest_detected',
      'application_reminder',
      'new_recipes',
      'weather_alerts',
    ];

    for (final key in keys) {
      preferences[key] = getNotificationPreference(key);
    }

    return preferences;
  }

  Future<void> addSearchHistory(String query, String type) async {
    final history = getSearchHistory(type);
    history.remove(query);
    history.insert(0, query);

    if (history.length > 10) {
      history.removeLast();
    }

    final result = await _storage.save(
      key: 'search_history_$type',
      data: history,
      box: _preferencesBox,
    );
    result.fold(
      (String failure) =>
          throw Exception('Erro ao adicionar ao histórico de busca: $failure'),
      (_) {},
    );
  }

  List<String> getSearchHistory(String type) {
    try {
      return []; // Por enquanto retorna lista vazia
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSearchHistory(String type) async {
    final result = await _storage.remove(
      key: 'search_history_$type',
      box: _preferencesBox,
    );
    result.fold(
      (String failure) =>
          throw Exception('Erro ao limpar histórico de busca: $failure'),
      (_) {},
    );
  }

  Future<void> incrementStatistic(String key) async {
    int current = 0; // Por enquanto começa com 0

    final result = await _storage.save(
      key: 'stat_$key',
      data: current + 1,
      box: _preferencesBox,
    );
    result.fold(
      (String failure) =>
          throw Exception('Erro ao incrementar estatística: $failure'),
      (_) {},
    );
  }

  int getStatistic(String key) {
    try {
      return 0; // Por enquanto retorna 0
    } catch (e) {
      return 0;
    }
  }

  Map<String, int> getAllStatistics() {
    try {
      return {}; // Por enquanto retorna mapa vazio
    } catch (e) {
      return {};
    }
  }

  Future<void> dispose() async {
    await _storage.dispose();
  }
}
