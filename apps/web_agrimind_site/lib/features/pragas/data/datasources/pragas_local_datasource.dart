import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/praga_model.dart';

abstract class PragasLocalDataSource {
  Future<List<PragaModel>> getCachedPragas();
  Future<void> cachePragas(List<PragaModel> pragas);
  Future<void> clearCache();
}

class PragasLocalDataSourceImpl implements PragasLocalDataSource {
  static const String _cachingKey = 'cached_pragas';
  final SharedPreferences _preferences;

  const PragasLocalDataSourceImpl(this._preferences);

  @override
  Future<List<PragaModel>> getCachedPragas() async {
    try {
      final jsonString = _preferences.getString(_cachingKey);
      if (jsonString == null) return [];

      final jsonDecoded = jsonDecode(jsonString) as List;
      return jsonDecoded
          .map((e) => PragaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cachePragas(List<PragaModel> pragas) async {
    try {
      final jsonString = jsonEncode(
        pragas.map((e) => e.toJson()).toList(),
      );
      await _preferences.setString(_cachingKey, jsonString);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_cachingKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
