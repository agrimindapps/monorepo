import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/defensivo_model.dart';

/// Local data source for defensivos
///
/// Handles all local caching operations for defensivos using SharedPreferences
abstract class DefensivosLocalDataSource {
  /// Get cached defensivos from local storage
  Future<List<DefensivoModel>> getCachedDefensivos();

  /// Cache defensivos list to local storage
  Future<void> cacheDefensivos(List<DefensivoModel> defensivos);

  /// Get a cached defensivo by id
  Future<DefensivoModel?> getCachedDefensivoById(String id);

  /// Clear all cached defensivos
  Future<void> clearCache();
}

@LazySingleton(as: DefensivosLocalDataSource)
class DefensivosLocalDataSourceImpl implements DefensivosLocalDataSource {
  static const String _cachedDefensivosKey = 'cached_defensivos';
  static const String _cacheTimestampKey = 'defensivos_cache_timestamp';
  static const Duration _cacheValidDuration = Duration(days: 7);

  final SharedPreferences _preferences;

  const DefensivosLocalDataSourceImpl(this._preferences);

  @override
  Future<List<DefensivoModel>> getCachedDefensivos() async {
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

      final jsonString = _preferences.getString(_cachedDefensivosKey);
      if (jsonString == null) return [];

      final jsonDecoded = jsonDecode(jsonString) as List;
      return jsonDecoded
          .map((e) => DefensivoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Erro ao recuperar defensivos do cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheDefensivos(List<DefensivoModel> defensivos) async {
    try {
      final jsonString = jsonEncode(
        defensivos.map((e) => e.toJson()).toList(),
      );
      await _preferences.setString(_cachedDefensivosKey, jsonString);
      await _preferences.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Erro ao salvar defensivos no cache: ${e.toString()}');
    }
  }

  @override
  Future<DefensivoModel?> getCachedDefensivoById(String id) async {
    try {
      final defensivos = await getCachedDefensivos();
      try {
        return defensivos.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw CacheException('Erro ao buscar defensivo no cache: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_cachedDefensivosKey);
      await _preferences.remove(_cacheTimestampKey);
    } catch (e) {
      throw CacheException('Erro ao limpar cache: ${e.toString()}');
    }
  }
}
