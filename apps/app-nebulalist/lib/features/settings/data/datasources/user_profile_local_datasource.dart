import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_profile_model.dart';

part 'user_profile_local_datasource.g.dart';

abstract class LocalUserProfileDataSource {
  Future<UserProfileModel?> getProfile();
  Future<void> saveProfile(UserProfileModel profile);
  Future<void> clearProfile();
}

class UserProfileLocalDataSource implements LocalUserProfileDataSource {
  static const String _profileKey = 'user_profile';

  @override
  Future<UserProfileModel?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson == null) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(profileJson);
      return UserProfileModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      throw Exception('Erro ao salvar perfil: $e');
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      throw Exception('Erro ao limpar perfil: $e');
    }
  }
}

@riverpod
LocalUserProfileDataSource localUserProfileDataSource(Ref ref) {
  return UserProfileLocalDataSource();
}
