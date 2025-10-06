import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
const int _defaultMaxSize = 100;
const Duration _defaultTtl = Duration(minutes: 30);
const int _maxMemoryUsageKB = 5 * 1024; // 5MB

/// Configuração de cache por camada
class CacheConfig {
  final int maxSize;
  final Duration ttl;
  final bool enableCompression;
  final bool enableSerialization;
  final int priority; // 1 = alta, 5 = baixa

  const CacheConfig({
    this.maxSize = _defaultMaxSize,
    this.ttl = _defaultTtl,
    this.enableCompression = false,
    this.enableSerialization = true,
    this.priority = 3,
  });
}

/// Entrada de cache com metadados
class CacheEntry<T> {
  final String key;
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final DateTime lastAccessed;
  final int sizeBytes;

  CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 1,
    required this.lastAccessed,
    required this.sizeBytes,
  });

  CacheEntry<T> copyWithAccess() {
    return CacheEntry<T>(
      key: key,
      value: value,
      createdAt: createdAt,
      expiresAt: expiresAt,
      accessCount: accessCount + 1,
      lastAccessed: DateTime.now(),
      sizeBytes: sizeBytes,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  double get score {
    final frequency = accessCount.toDouble();
    final recency = DateTime.now().difference(lastAccessed).inMinutes.toDouble();
    return frequency / (recency + 1);
  }
}

/// Camada de cache interna
class _CacheLayer<T> {
  final String name;
  final CacheConfig config;
  final LinkedHashMap<String, CacheEntry<T>> _data = LinkedHashMap();
  
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  _CacheLayer(this.name, this.config);

  CacheEntry<T>? get(String key) {
      final entry = _data[key];
      
      if (entry == null) {
        _misses++;
        return null;
      }

      if (entry.isExpired) {
        _data.remove(key);
        _misses++;
        return null;
      }
      _data.remove(key);
      final updatedEntry = entry.copyWithAccess();
      _data[key] = updatedEntry;
      
      _hits++;
      return updatedEntry;
    }

    void put(String key, T value) {
      final sizeBytes = _estimateSize(value);
      final expiresAt = DateTime.now().add(config.ttl);
      
      final entry = CacheEntry<T>(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        lastAccessed: DateTime.now(),
        sizeBytes: sizeBytes,
      );
      _data.remove(key);
      _evictIfNecessary();
      _data[key] = entry;
    }

    void remove(String key) {
      _data.remove(key);
    }

    void clear() {
      _data.clear();
    }

    void _evictIfNecessary() {
      _removeExpiredEntries();
      while (_data.length >= config.maxSize) {
        _evictLeastValuable();
      }
      while (_getTotalSizeKB() > _maxMemoryUsageKB && _data.isNotEmpty) {
        _evictLeastValuable();
      }
    }

    void _removeExpiredEntries() {
      final keysToRemove = <String>[];
      
      for (final entry in _data.values) {
        if (entry.isExpired) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        _data.remove(key);
        _evictions++;
      }
    }

    void _evictLeastValuable() {
      if (_data.isEmpty) return;
      CacheEntry<T>? leastValuable;
      String? keyToRemove;

      for (final entry in _data.entries) {
        if (leastValuable == null || entry.value.score < leastValuable.score) {
          leastValuable = entry.value;
          keyToRemove = entry.key;
        }
      }

      if (keyToRemove != null) {
        _data.remove(keyToRemove);
        _evictions++;
      }
    }

    double _getTotalSizeKB() {
      return _data.values.fold(0.0, (sum, entry) => sum + entry.sizeBytes) / 1024.0;
    }

    int _estimateSize(T value) {
      if (value is String) {
        return utf8.encode(value).length;
      } else if (value is List) {
        return value.length * 8; // Estimativa
      } else if (value is Map) {
        return value.length * 16; // Estimativa
      }
      return 64; // Estimativa padrão
    }

    Map<String, dynamic> getStats() {
      return {
        'name': name,
        'size': _data.length,
        'max_size': config.maxSize,
        'hits': _hits,
        'misses': _misses,
        'evictions': _evictions,
        'hit_rate': _hits / (_hits + _misses + 1),
        'total_size_kb': _getTotalSizeKB(),
        'avg_entry_size_bytes': _data.isEmpty ? 0 : _getTotalSizeKB() * 1024 / _data.length,
      };
    }
  }

/// Sistema de cache otimizado para high performance
/// 
/// Implementa múltiplas estratégias de cache:
/// - LRU (Least Recently Used)
/// - TTL (Time To Live)
/// - Size-based eviction
/// - Memory pressure aware
class OptimizedCacheManager extends ChangeNotifier {
  static final OptimizedCacheManager _instance = OptimizedCacheManager._internal();
  factory OptimizedCacheManager() => _instance;
  OptimizedCacheManager._internal();
  final Map<String, _CacheLayer<dynamic>> _cacheLayers = {};
  int _totalHits = 0;
  int _totalMisses = 0;
  int _totalEvictions = 0;

  /// Cria ou obtém uma camada de cache
  _CacheLayer<T> _getOrCreateLayer<T>(String layerName, CacheConfig config) {
    if (!_cacheLayers.containsKey(layerName)) {
      _cacheLayers[layerName] = _CacheLayer<T>(layerName, config);
    }
    return _cacheLayers[layerName] as _CacheLayer<T>;
  }

  /// Armazena um valor no cache
  void put<T>(
    String layerName, 
    String key, 
    T value, {
    CacheConfig? config,
  }) {
    final layer = _getOrCreateLayer<T>(layerName, config ?? const CacheConfig());
    layer.put(key, value);
    notifyListeners();
  }

  /// Obtém um valor do cache
  T? get<T>(String layerName, String key) {
    final layer = _cacheLayers[layerName] as _CacheLayer<T>?;
    if (layer == null) return null;

    final entry = layer.get(key);
    if (entry != null) {
      _totalHits++;
      return entry.value;
    }

    _totalMisses++;
    return null;
  }

  /// Obtém um valor ou executa factory se não encontrado
  Future<T> getOrPut<T>(
    String layerName,
    String key,
    Future<T> Function() factory, {
    CacheConfig? config,
  }) async {
    final cached = get<T>(layerName, key);
    if (cached != null) return cached;

    final value = await factory();
    put(layerName, key, value, config: config);
    return value;
  }

  /// Remove um valor específico
  void remove(String layerName, String key) {
    final layer = _cacheLayers[layerName];
    layer?.remove(key);
    notifyListeners();
  }

  /// Limpa uma camada inteira
  void clearLayer(String layerName) {
    final layer = _cacheLayers[layerName];
    layer?.clear();
    notifyListeners();
  }

  /// Limpa todo o cache
  void clearAll() {
    for (final layer in _cacheLayers.values) {
      layer.clear();
    }
    _totalHits = 0;
    _totalMisses = 0;
    _totalEvictions = 0;
    notifyListeners();
  }

  /// Força limpeza de entradas expiradas em todas as camadas
  void cleanupExpired() {
    for (final layer in _cacheLayers.values) {
      layer._removeExpiredEntries();
    }
    notifyListeners();
  }

  /// Obtém estatísticas gerais
  Map<String, dynamic> getGlobalStats() {
    final layerStats = _cacheLayers.values.map((layer) => layer.getStats()).toList();
    final totalSize = layerStats.fold<int>(0, (int sum, Map<String, dynamic> stats) => sum + (stats['size'] as int));
    final totalSizeKB = layerStats.fold<double>(0.0, (double sum, Map<String, dynamic> stats) => sum + (stats['total_size_kb'] as double));

    return {
      'total_layers': _cacheLayers.length,
      'total_entries': totalSize,
      'total_size_kb': totalSizeKB,
      'global_hits': _totalHits,
      'global_misses': _totalMisses,
      'global_hit_rate': _totalHits / (_totalHits + _totalMisses + 1),
      'global_evictions': _totalEvictions,
      'layers': layerStats,
    };
  }

  /// Otimiza automaticamente todas as camadas
  void optimize() {
    for (final layer in _cacheLayers.values) {
      layer._evictIfNecessary();
    }
    
    developer.log('Cache otimizado: ${getGlobalStats()}', name: 'CacheManager');
    notifyListeners();
  }

  /// Remove uma camada completamente
  void removeLayer(String layerName) {
    _cacheLayers.remove(layerName);
    notifyListeners();
  }
}

/// Camadas de cache pré-definidas para o app
class CacheLayers {
  CacheLayers._();
  static const String calculators = 'calculators';
  static const String livestock = 'livestock';
  static const String weather = 'weather';
  static const String news = 'news';
  static const String user = 'user';
  static const String settings = 'settings';
  static const String images = 'images';
  static const String api = 'api';

  /// Configurações otimizadas por tipo de dado
  static final Map<String, CacheConfig> configs = {
    calculators: const CacheConfig(
      maxSize: 50,
      ttl: Duration(hours: 2),
      priority: 2,
    ),
    livestock: const CacheConfig(
      maxSize: 200,
      ttl: Duration(hours: 6),
      priority: 1,
    ),
    weather: const CacheConfig(
      maxSize: 100,
      ttl: Duration(minutes: 15),
      priority: 2,
    ),
    news: const CacheConfig(
      maxSize: 50,
      ttl: Duration(hours: 1),
      priority: 3,
    ),
    user: const CacheConfig(
      maxSize: 10,
      ttl: Duration(hours: 24),
      priority: 1,
    ),
    settings: const CacheConfig(
      maxSize: 20,
      ttl: Duration(days: 7),
      priority: 1,
    ),
    images: const CacheConfig(
      maxSize: 30,
      ttl: Duration(hours: 4),
      priority: 4,
    ),
    api: const CacheConfig(
      maxSize: 100,
      ttl: Duration(minutes: 10),
      priority: 3,
    ),
  };
}

/// Mixin para facilitar uso do cache em providers
mixin CacheAwareMixin {
  final OptimizedCacheManager _cache = OptimizedCacheManager();

  /// Cache com configuração automática por layer
  Future<T> cached<T>(
    String layer,
    String key,
    Future<T> Function() factory,
  ) async {
    final config = CacheLayers.configs[layer] ?? const CacheConfig();
    return await _cache.getOrPut(layer, key, factory, config: config);
  }

  /// Cache simples
  void putCache<T>(String layer, String key, T value) {
    final config = CacheLayers.configs[layer] ?? const CacheConfig();
    _cache.put(layer, key, value, config: config);
  }

  /// Obtém do cache
  T? getCache<T>(String layer, String key) {
    return _cache.get<T>(layer, key);
  }

  /// Remove do cache
  void removeCache(String layer, String key) {
    _cache.remove(layer, key);
  }

  /// Limpa uma camada
  void clearCacheLayer(String layer) {
    _cache.clearLayer(layer);
  }
}