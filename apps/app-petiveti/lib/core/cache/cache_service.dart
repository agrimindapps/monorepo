import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';

/// Serviço de cache inteligente para otimização de performance
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry<dynamic>> _memoryCache = {};
  SharedPreferences? _prefs;

  /// Duração padrão do cache (1 hora)
  static const Duration defaultCacheDuration = Duration(hours: 1);

  /// Tamanho máximo do cache em memória
  static const int maxMemoryEntries = 100;

  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Armazena dados no cache
  Future<void> put<T>(
    String key,
    T data, {
    Duration? duration,
    bool persistToDisk = false,
  }) async {
    final cacheDuration = duration ?? defaultCacheDuration;
    final entry = CacheEntry<T>(
      data: data,
      timestamp: DateTime.now(),
      duration: cacheDuration,
    );
    _memoryCache[key] = entry;
    if (_memoryCache.length > maxMemoryEntries) {
      _cleanOldestEntries();
    }
    if (persistToDisk) {
      await _saveToDisk(key, entry);
    }
  }

  /// Recupera dados do cache
  Future<T?> get<T>(String key) async {
    final memoryEntry = _memoryCache[key] as CacheEntry<T>?;
    if (memoryEntry != null && !memoryEntry.isExpired) {
      return memoryEntry.data;
    }
    if (memoryEntry != null && memoryEntry.isExpired) {
      _memoryCache.remove(key);
    }
    final diskEntry = await _loadFromDisk<T>(key);
    if (diskEntry != null && !diskEntry.isExpired) {
      _memoryCache[key] = diskEntry;
      return diskEntry.data;
    }
    if (diskEntry != null && diskEntry.isExpired) {
      await _removeFromDisk(key);
    }

    return null;
  }

  /// Verifica se existe uma entrada válida no cache
  Future<bool> has(String key) async {
    final data = await get<dynamic>(key);
    return data != null;
  }

  /// Remove uma entrada específica do cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _removeFromDisk(key);
  }

  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys().where((k) => k.startsWith(_cachePrefix));
      for (final key in keys) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Limpa entradas expiradas
  Future<void> clearExpired() async {
    final expiredKeys =
        _memoryCache.entries
            .where((entry) => entry.value.isExpired)
            .map((entry) => entry.key)
            .toList();

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
    if (_prefs != null) {
      final allKeys = _prefs!.getKeys().where(
        (k) => k.startsWith(_cachePrefix),
      );
      for (final diskKey in allKeys) {
        final key = diskKey.replaceFirst(_cachePrefix, '');
        final entry = await _loadFromDisk<dynamic>(key);
        if (entry != null && entry.isExpired) {
          await _prefs!.remove(diskKey);
        }
      }
    }
  }

  /// Obter estatísticas do cache
  CacheStatistics getStatistics() {
    final memoryEntries = _memoryCache.length;
    final expiredEntries =
        _memoryCache.values.where((entry) => entry.isExpired).length;
    final validEntries = memoryEntries - expiredEntries;

    return CacheStatistics(
      totalMemoryEntries: memoryEntries,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
      hitRatio: _hitRatio,
      memoryUsageEstimate: _estimateMemoryUsage(),
    );
  }

  /// Cache específico para listas com paginação
  Future<void> putList<T>(
    String baseKey,
    List<T> items, {
    int page = 1,
    int pageSize = 20,
    Duration? duration,
  }) async {
    final key = '${baseKey}_page_${page}_size_$pageSize';
    await put(key, items, duration: duration, persistToDisk: true);
  }

  /// Recupera lista paginada do cache
  Future<List<T>?> getList<T>(
    String baseKey, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final key = '${baseKey}_page_${page}_size_$pageSize';
    return await get<List<T>>(key);
  }

  /// Cache específico para queries com parâmetros
  String buildQueryKey(String baseKey, Map<String, dynamic> parameters) {
    final paramString = parameters.entries
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    return '${baseKey}_query_${paramString.hashCode}';
  }

  /// Cache com refresh automático em background
  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetchFunction, {
    Duration? duration,
    bool refreshInBackground = false,
  }) async {
    final cachedData = await get<T>(key);

    if (cachedData != null) {
      if (refreshInBackground) {
        _refreshInBackground(key, fetchFunction, duration);
      }
      return cachedData;
    }
    final freshData = await fetchFunction();
    await put(key, freshData, duration: duration, persistToDisk: true);

    _recordHit(false); // Cache miss
    return freshData;
  }

  static const String _cachePrefix = 'cache_';
  int _hits = 0;
  int _requests = 0;

  double get _hitRatio => _requests > 0 ? _hits / _requests : 0.0;

  void _recordHit(bool wasHit) {
    _requests++;
    if (wasHit) _hits++;
  }

  void _cleanOldestEntries() {
    final sortedEntries =
        _memoryCache.entries.toList()
          ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

    final toRemove = sortedEntries.take(
      _memoryCache.length - maxMemoryEntries + 10,
    );
    for (final entry in toRemove) {
      _memoryCache.remove(entry.key);
    }
  }

  Future<void> _saveToDisk<T>(String key, CacheEntry<T> entry) async {
    if (_prefs == null) return;

    try {
      final diskKey = '$_cachePrefix$key';
      final serializedEntry = {
        'data': _serializeData(entry.data),
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'duration': entry.duration.inMilliseconds,
        'type': T.toString(),
      };

      await _prefs!.setString(diskKey, jsonEncode(serializedEntry));
    } catch (e) {}
  }

  Future<CacheEntry<T>?> _loadFromDisk<T>(String key) async {
    if (_prefs == null) return null;

    try {
      final diskKey = '$_cachePrefix$key';
      final serializedData = _prefs!.getString(diskKey);

      if (serializedData == null) return null;

      final Map<String, dynamic> entryData =
          jsonDecode(serializedData) as Map<String, dynamic>;

      return CacheEntry<T>(
        data: _deserializeData<T>(entryData['data']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          entryData['timestamp'] as int,
        ),
        duration: Duration(milliseconds: entryData['duration'] as int),
      );
    } catch (e) {
      await _removeFromDisk(key);
      return null;
    }
  }

  Future<void> _removeFromDisk(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove('$_cachePrefix$key');
  }

  dynamic _serializeData(dynamic data) {
    if (data is String || data is num || data is bool) {
      return data;
    }
    if (data is Map || data is List) {
      return data; // JSON pode lidar com Maps e Lists básicos
    }
    return data.toString(); // Fallback
  }

  T _deserializeData<T>(dynamic data) {
    return data as T;
  }

  int _estimateMemoryUsage() {
    return _memoryCache.length * 1024; // 1KB por entrada (estimativa grosseira)
  }

  void _refreshInBackground<T>(
    String key,
    Future<T> Function() fetchFunction,
    Duration? duration,
  ) {
    Timer.run(() async {
      try {
        final freshData = await fetchFunction();
        await put(key, freshData, duration: duration, persistToDisk: true);
      } catch (e) {}
    });
  }
}

/// Entrada do cache com timestamp e duração
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration duration;

  const CacheEntry({
    required this.data,
    required this.timestamp,
    required this.duration,
  });

  /// Verifica se a entrada está expirada
  bool get isExpired {
    return DateTime.now().isAfter(timestamp.add(duration));
  }

  /// Tempo restante até a expiração
  Duration get timeToExpiry {
    final expiry = timestamp.add(duration);
    final now = DateTime.now();
    return expiry.isAfter(now) ? expiry.difference(now) : Duration.zero;
  }
}

/// Estatísticas do cache
class CacheStatistics {
  final int totalMemoryEntries;
  final int validEntries;
  final int expiredEntries;
  final double hitRatio;
  final int memoryUsageEstimate;

  const CacheStatistics({
    required this.totalMemoryEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hitRatio,
    required this.memoryUsageEstimate,
  });

  /// Taxa de hit em porcentagem
  String get hitRatePercentage => '${(hitRatio * 100).toStringAsFixed(1)}%';

  /// Uso de memória formatado
  String get formattedMemoryUsage {
    if (memoryUsageEstimate < 1024) return '${memoryUsageEstimate}B';
    if (memoryUsageEstimate < 1024 * 1024) {
      return '${(memoryUsageEstimate / 1024).toStringAsFixed(1)}KB';
    }
    return '${(memoryUsageEstimate / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Keys padronizadas para cache
class CacheKeys {
  static const String animals = 'animals';
  static const String appointments = 'appointments';
  static const String medications = 'medications';
  static const String vaccines = 'vaccines';
  static const String weights = 'weights';
  static const String expenses = 'expenses';
  static const String reminders = 'reminders';
  static const String calculators = 'calculators';
  static const String userProfile = 'user_profile';
  static String animalById(String id) => 'animal_$id';
  static String animalsByUser(String userId) => 'animals_user_$userId';
  static String appointmentsByAnimal(String animalId) =>
      'appointments_animal_$animalId';
  static String medicationsByAnimal(String animalId) =>
      'medications_animal_$animalId';
  static String weightsByAnimal(String animalId) => 'weights_animal_$animalId';
  static String expensesByAnimal(String animalId) =>
      'expenses_animal_$animalId';
  static String calculationHistory(String calculatorId) =>
      'calc_history_$calculatorId';
}
