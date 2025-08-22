import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_agrihurbi/features/auth/data/models/user_model.dart';
import 'package:app_agrihurbi/core/constants/app_constants.dart';
import 'package:app_agrihurbi/core/utils/typedef.dart';
import 'dart:convert';

/// Abstract class for authentication local data source
abstract class AuthLocalDataSource {
  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Remove cached user
  Future<void> removeCachedUser();

  /// Store tokens
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Get access token
  Future<String?> getAccessToken();

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Remove tokens
  Future<void> removeTokens();

  /// Check if user is logged in
  Future<bool> isLoggedIn();
}

/// Implementation of AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(AppConstants.userDataKey, userJson);
    } catch (e) {
      throw Exception('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConstants.userDataKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as DataMap;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> removeCachedUser() async {
    try {
      await sharedPreferences.remove(AppConstants.userDataKey);
    } catch (e) {
      throw Exception('Failed to remove cached user: $e');
    }
  }

  @override
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: accessToken,
        ),
        secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: refreshToken,
        ),
      ]);
    } catch (e) {
      throw Exception('Failed to store tokens: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw Exception('Failed to get access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  @override
  Future<void> removeTokens() async {
    try {
      await Future.wait([
        secureStorage.delete(key: AppConstants.accessTokenKey),
        secureStorage.delete(key: AppConstants.refreshTokenKey),
      ]);
    } catch (e) {
      throw Exception('Failed to remove tokens: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final user = await getCachedUser();
      return accessToken != null && user != null;
    } catch (e) {
      return false;
    }
  }
}