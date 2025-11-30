import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';

abstract class IProfileLocalDataSource {
  Future<UserProfileModel> getCachedProfile();
  Future<void> cacheProfile(UserProfileModel profile);
  Future<void> clearProfile();
}

class ProfileLocalDataSource implements IProfileLocalDataSource {

  ProfileLocalDataSource({required this.sharedPreferences});
  static const String _cachedProfileKey = 'CACHED_USER_PROFILE';

  final SharedPreferences sharedPreferences;

  @override
  Future<UserProfileModel> getCachedProfile() async {
    final jsonString = sharedPreferences.getString(_cachedProfileKey);

    if (jsonString == null) {
      throw CacheException();
    }

    return UserProfileModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    await sharedPreferences.setString(
      _cachedProfileKey,
      json.encode(profile.toJson()),
    );
  }

  @override
  Future<void> clearProfile() async {
    await sharedPreferences.remove(_cachedProfileKey);
  }
}

class CacheException implements Exception {}
