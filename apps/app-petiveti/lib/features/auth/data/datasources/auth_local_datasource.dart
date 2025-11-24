import 'dart:convert';

import 'package:core/core.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<String?> getStoredToken();
  Future<void> storeToken(String token);
  Future<void> clearToken();
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchCompleted();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';
  static const String _firstLaunchKey = 'first_launch';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromMap(userMap);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Erro ao recuperar usuário do cache: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toMap());
      await sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      throw CacheException(message: 'Erro ao salvar usuário no cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_userKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao limpar cache do usuário: $e');
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao recuperar token: $e');
    }
  }

  @override
  Future<void> storeToken(String token) async {
    try {
      await sharedPreferences.setString(_tokenKey, token);
    } catch (e) {
      throw CacheException(message: 'Erro ao salvar token: $e');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await sharedPreferences.remove(_tokenKey);
    } catch (e) {
      throw CacheException(message: 'Erro ao limpar token: $e');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return sharedPreferences.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      throw CacheException(message: 'Erro ao verificar primeiro acesso: $e');
    }
  }

  @override
  Future<void> setFirstLaunchCompleted() async {
    try {
      await sharedPreferences.setBool(_firstLaunchKey, false);
    } catch (e) {
      throw CacheException(message: 'Erro ao marcar primeiro acesso: $e');
    }
  }
}
