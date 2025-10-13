import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/utils/secure_logger.dart';

/// Serviço de cache para otimizar performance e reduzir requisições
///
/// Implementa cache em memória e disco com TTL configurável.
/// Usado para melhorar performance e reduzir chamadas de rede.
class CacheService {
  static const String _cachePrefix = 'app_cache_';
  static const String _timestampSuffix = '_timestamp';

  /// TTL padrão para cache (30 minutos)
  static const Duration _defaultTtl = Duration(minutes: 30);

  /// TTL para dados críticos (5 minutos)
  static const Duration _criticalTtl = Duration(minutes: 5);

  /// TTL para dados estáticos (24 horas)
  static const Duration _staticTtl = Duration(hours: 24);

  /// Cache em memória para acesso rápido
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _memoryCacheTimestamp = {};

  /// Metrics para monitoramento
  static int _hitCount = 0;
  static int _missCount = 0;

  /// Singleton
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  CacheService._();

  /// Salva dados no cache com TTL configurável
  static Future<void> set<T>(
    String key,
    T data, {
    Duration? ttl,
    bool useMemoryCache = true,
  }) async {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      if (useMemoryCache) {
        _memoryCache[cacheKey] = data;
        _memoryCacheTimestamp[cacheKey] = DateTime.now();
      }
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(data);

      await Future.wait([
        prefs.setString(cacheKey, jsonData),
        prefs.setInt(timestampKey, timestamp),
      ]);

      SecureLogger.debug('Cache set para key: $key');
    } catch (e) {
      SecureLogger.error('Erro ao salvar cache', error: e);
    }
  }

  /// Recupera dados do cache
  static Future<T?> get<T>(
    String key, {
    Duration? ttl,
    bool useMemoryCache = true,
    T Function(dynamic)? deserializer,
  }) async {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;
      final cacheTtl = ttl ?? _defaultTtl;
      if (useMemoryCache && _memoryCache.containsKey(cacheKey)) {
        final cacheTime = _memoryCacheTimestamp[cacheKey];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < cacheTtl) {
          _hitCount++;
          SecureLogger.debug('Cache hit (memory) para key: $key');
          return _memoryCache[cacheKey] as T;
        } else {
          _memoryCache.remove(cacheKey);
          _memoryCacheTimestamp.remove(cacheKey);
        }
      }
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt(timestampKey);

      if (cachedData != null && timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final isExpired = DateTime.now().difference(cacheTime) > cacheTtl;

        if (!isExpired) {
          _hitCount++;
          final data =
              deserializer != null
                  ? deserializer(jsonDecode(cachedData))
                  : jsonDecode(cachedData) as T;
          if (useMemoryCache) {
            _memoryCache[cacheKey] = data;
            _memoryCacheTimestamp[cacheKey] = cacheTime;
          }

          SecureLogger.debug('Cache hit (disk) para key: $key');
          return data;
        } else {
          await remove(key);
        }
      }

      _missCount++;
      SecureLogger.debug('Cache miss para key: $key');
      return null;
    } catch (e) {
      SecureLogger.error('Erro ao recuperar cache', error: e);
      _missCount++;
      return null;
    }
  }

  /// Remove item do cache
  static Future<void> remove(String key) async {
    try {
      final cacheKey = _cachePrefix + key;
      final timestampKey = cacheKey + _timestampSuffix;
      _memoryCache.remove(cacheKey);
      _memoryCacheTimestamp.remove(cacheKey);
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([prefs.remove(cacheKey), prefs.remove(timestampKey)]);

      SecureLogger.debug('Cache removido para key: $key');
    } catch (e) {
      SecureLogger.error('Erro ao remover cache', error: e);
    }
  }

  /// Limpa todo o cache
  static Future<void> clear() async {
    try {
      _memoryCache.clear();
      _memoryCacheTimestamp.clear();

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      SecureLogger.info('Cache limpo completamente');
    } catch (e) {
      SecureLogger.error('Erro ao limpar cache', error: e);
    }
  }

  /// Verifica se um item existe no cache e não está expirado
  static Future<bool> exists(String key, {Duration? ttl}) async {
    final data = await get(key, ttl: ttl);
    return data != null;
  }

  /// Atualiza cache em background sem impactar UX
  static Future<void> refreshInBackground<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    unawaited(
      fetcher()
          .then((data) async {
            await set(key, data, ttl: ttl);
          })
          .catchError((e) {
            SecureLogger.error(
              'Erro ao atualizar cache em background',
              error: e,
            );
          }),
    );
  }

  /// Obtém dados com estratégia cache-first
  static Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
    bool useMemoryCache = true,
    T Function(dynamic)? deserializer,
  }) async {
    final cachedData = await get<T>(
      key,
      ttl: ttl,
      useMemoryCache: useMemoryCache,
      deserializer: deserializer,
    );

    if (cachedData != null) {
      return cachedData;
    }
    final data = await fetcher();
    await set(key, data, ttl: ttl, useMemoryCache: useMemoryCache);

    return data;
  }

  /// TTL específicos para diferentes tipos de dados
  static Duration getTtlForType(CacheDataType type) {
    switch (type) {
      case CacheDataType.critical:
        return _criticalTtl;
      case CacheDataType.static:
        return _staticTtl;
      case CacheDataType.normal:
        return _defaultTtl;
    }
  }

  /// Métricas de cache
  static Map<String, dynamic> getMetrics() {
    final total = _hitCount + _missCount;
    final hitRate =
        total > 0 ? (_hitCount / total * 100).toStringAsFixed(1) : '0.0';

    return {
      'hits': _hitCount,
      'misses': _missCount,
      'total': total,
      'hit_rate': '$hitRate%',
      'memory_cache_size': _memoryCache.length,
    };
  }

  /// Reseta métricas
  static void resetMetrics() {
    _hitCount = 0;
    _missCount = 0;
  }

  /// Invalidar cache por padrão
  static Future<void> invalidatePattern(String pattern) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_cachePrefix) && key.contains(pattern),
      );

      for (final key in keys) {
        await prefs.remove(key);
      }
      _memoryCache.removeWhere((key, value) => key.contains(pattern));
      _memoryCacheTimestamp.removeWhere((key, value) => key.contains(pattern));

      SecureLogger.debug('Cache invalidado para padrão: $pattern');
    } catch (e) {
      SecureLogger.error('Erro ao invalidar cache por padrão', error: e);
    }
  }
}

/// Tipos de dados para cache com TTL específico
enum CacheDataType {
  critical, // 5 minutos
  normal, // 30 minutos
  static, // 24 horas
}

/// Extension para facilitar uso do cache
extension CacheExtension on String {
  Future<void> cacheSet<T>(T data, {Duration? ttl}) async {
    await CacheService.set(this, data, ttl: ttl);
  }

  Future<T?> cacheGet<T>({Duration? ttl}) async {
    return await CacheService.get<T>(this, ttl: ttl);
  }

  Future<void> cacheRemove() async {
    await CacheService.remove(this);
  }
}

/// Função para evitar warning do unawaited
void unawaited(Future<void> future) {}
