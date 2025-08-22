import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<String?> getStoredToken();
  Future<void> storeToken(String token);
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';
  
  UserModel? _cachedUser;
  String? _cachedToken;

  @override
  Future<UserModel?> getCachedUser() async {
    return _cachedUser;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    _cachedUser = user;
  }

  @override
  Future<void> clearCache() async {
    _cachedUser = null;
  }

  @override
  Future<String?> getStoredToken() async {
    return _cachedToken;
  }

  @override
  Future<void> storeToken(String token) async {
    _cachedToken = token;
  }

  @override
  Future<void> clearToken() async {
    _cachedToken = null;
  }
}