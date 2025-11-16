import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/fitossanitario_model.dart';

abstract class FitossanitariosLocalDataSource {
  Future<List<FitossanitarioModel>> getCachedFitossanitarios();
  Future<void> cacheFitossanitarios(List<FitossanitarioModel> fitossanitarios);
  Future<void> clearCache();
}

class FitossanitariosLocalDataSourceImpl
    implements FitossanitariosLocalDataSource {
  static const String _cachingKey = 'cached_fitossanitarios';
  final SharedPreferences _preferences;

  const FitossanitariosLocalDataSourceImpl(this._preferences);

  @override
  Future<List<FitossanitarioModel>> getCachedFitossanitarios() async {
    try {
      final jsonString = _preferences.getString(_cachingKey);
      if (jsonString == null) return [];

      final jsonDecoded = jsonDecode(jsonString) as List;
      return jsonDecoded
          .map((e) => FitossanitarioModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException( e.toString());
    }
  }

  @override
  Future<void> cacheFitossanitarios(
      List<FitossanitarioModel> fitossanitarios) async {
    try {
      final jsonString = jsonEncode(
        fitossanitarios.map((e) => e.toJson()).toList(),
      );
      await _preferences.setString(_cachingKey, jsonString);
    } catch (e) {
      throw CacheException( e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_cachingKey);
    } catch (e) {
      throw CacheException( e.toString());
    }
  }
}
