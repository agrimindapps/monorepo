import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCachedUser();
  Future<bool> isFirstLaunch();
  Future<void> markFirstLaunchComplete();
  Future<Map<String, String>> getCachedCredentials();
  Future<void> cacheCredentials(String email, String hashedPassword);
  Future<void> clearCachedCredentials();
  Future<void> clearCachedCredentialsPreservingEmail();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  
  static const String _cachedUserKey = 'cached_user';
  static const String _firstLaunchKey = 'first_launch';
  static const String _cachedEmailKey = 'cached_email';
  static const String _cachedPasswordKey = 'cached_password_hash';

  AuthLocalDataSourceImpl(
    this._sharedPreferences,
    this._secureStorage,
  );

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _sharedPreferences.getString(_cachedUserKey);
      if (userJson == null) return null;

      final userMap = Map<String, dynamic>.from(
        // Parse JSON string to Map
        _parseJsonString(userJson),
      );
      
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = _jsonEncode(user.toJson());
      await _sharedPreferences.setString(_cachedUserKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _sharedPreferences.remove(_cachedUserKey);
    } catch (e) {
      throw CacheException('Failed to clear cached user: $e');
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return _sharedPreferences.getBool(_firstLaunchKey) ?? true;
    } catch (e) {
      throw CacheException('Failed to check first launch: $e');
    }
  }

  @override
  Future<void> markFirstLaunchComplete() async {
    try {
      await _sharedPreferences.setBool(_firstLaunchKey, false);
    } catch (e) {
      throw CacheException('Failed to mark first launch complete: $e');
    }
  }

  @override
  Future<Map<String, String>> getCachedCredentials() async {
    try {
      final email = await _secureStorage.read(key: _cachedEmailKey);
      final passwordHash = await _secureStorage.read(key: _cachedPasswordKey);
      
      return {
        if (email != null) 'email': email,
        if (passwordHash != null) 'passwordHash': passwordHash,
      };
    } catch (e) {
      throw CacheException('Failed to get cached credentials: $e');
    }
  }

  @override
  Future<void> cacheCredentials(String email, String hashedPassword) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _cachedEmailKey, value: email),
        _secureStorage.write(key: _cachedPasswordKey, value: hashedPassword),
      ]);
    } catch (e) {
      throw CacheException('Failed to cache credentials: $e');
    }
  }

  @override
  Future<void> clearCachedCredentials() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _cachedEmailKey),
        _secureStorage.delete(key: _cachedPasswordKey),
      ]);
    } catch (e) {
      throw CacheException('Failed to clear cached credentials: $e');
    }
  }

  @override
  Future<void> clearCachedCredentialsPreservingEmail() async {
    try {
      // SECURITY + UX: Clear only password, preserve email for better UX
      await _secureStorage.delete(key: _cachedPasswordKey);
    } catch (e) {
      throw CacheException('Failed to clear cached password: $e');
    }
  }

  // Helper methods for JSON parsing
  Map<String, dynamic> _parseJsonString(String jsonString) {
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  String _jsonEncode(Map<String, dynamic> data) {
    return json.encode(data);
  }
}