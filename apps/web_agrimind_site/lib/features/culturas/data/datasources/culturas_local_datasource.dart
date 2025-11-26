import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/cultura_model.dart';

/// Local data source for culturas
///
/// Handles all local caching operations for culturas using SharedPreferences
abstract class CulturasLocalDataSource {
  /// Get cached culturas from local storage
  Future<List<CulturaModel>> getCachedCulturas();

  /// Cache culturas list to local storage
  Future<void> cacheCulturas(List<CulturaModel> culturas);

  /// Get a cached cultura by id
  Future<CulturaModel?> getCachedCulturaById(String id);

  /// Clear all cached culturas
  Future<void> clearCache();
}

class CulturasLocalDataSourceImpl implements CulturasLocalDataSource {
  static const String _cachedCulturasKey = 'cached_culturas';
  static const String _cacheTimestampKey = 'culturas_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(days: 7);

  final SharedPreferences _preferences;

  const CulturasLocalDataSourceImpl(this._preferences);

  @override
  Future<List<CulturaModel>> getCachedCulturas() async {
    try {
      // Check if cache is still valid
      final timestamp = _preferences.getInt(_cacheTimestampKey);
      if (timestamp != null) {
        final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(cacheDate) > _cacheValidDuration) {
          // Cache expired
          await clearCache();
          return [];
        }
      }

      final jsonString = _preferences.getString(_cachedCulturasKey);
      if (jsonString == null) return [];

      final jsonDecoded = jsonDecode(jsonString) as List;
      return jsonDecoded
          .map((e) => CulturaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Erro ao recuperar culturas do cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheCulturas(List<CulturaModel> culturas) async {
    try {
      final jsonString = jsonEncode(
        culturas.map((e) => e.toJson()).toList(),
      );
      await _preferences.setString(_cachedCulturasKey, jsonString);
      await _preferences.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Erro ao salvar culturas no cache: ${e.toString()}');
    }
  }

  @override
  Future<CulturaModel?> getCachedCulturaById(String id) async {
    try {
      final culturas = await getCachedCulturas();
      try {
        return culturas.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheException('Erro ao buscar cultura no cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_cachedCulturasKey);
      await _preferences.remove(_cacheTimestampKey);
    } catch (e) {
      throw CacheException('Erro ao limpar cache: ${e.toString()}');
    }
  }
}
