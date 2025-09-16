import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/export_data.dart';

abstract class LocalDataExportDataSource {
  Future<DateTime?> getLastExportDate();
  Future<void> saveExportRecord(DateTime exportDate);
  Future<UserProfileData?> getUserProfileData();
  Future<List<FavoriteData>> getFavoritesData();
  Future<List<CommentData>> getCommentsData();
  Future<UserPreferencesData?> getPreferencesData();
}

class LocalDataExportDataSourceImpl implements LocalDataExportDataSource {
  static const String _lastExportKey = 'lgpd_last_export_date';
  static const String _userProfileKey = 'user_profile_data';
  static const String _favoritesKey = 'user_favorites_data';
  static const String _commentsKey = 'user_comments_data';
  static const String _preferencesKey = 'user_preferences_data';

  @override
  Future<DateTime?> getLastExportDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastExportKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  @override
  Future<void> saveExportRecord(DateTime exportDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastExportKey, exportDate.millisecondsSinceEpoch);
  }

  @override
  Future<UserProfileData?> getUserProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_userProfileKey);

    if (profileJson == null) return null;

    try {
      final data = json.decode(profileJson) as Map<String, dynamic>;
      return UserProfileData(
        name: data['name'] as String?,
        email: data['email'] as String?,
        createdAt: data['created_at'] != null
            ? DateTime.parse(data['created_at'] as String)
            : null,
        lastLoginAt: data['last_login_at'] != null
            ? DateTime.parse(data['last_login_at'] as String)
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<FavoriteData>> getFavoritesData() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null) return [];

    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.map((item) {
        final data = item as Map<String, dynamic>;
        return FavoriteData(
          productId: data['product_id'] as String,
          productName: data['product_name'] as String,
          category: data['category'] as String?,
          createdAt: DateTime.parse(data['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CommentData>> getCommentsData() async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);

    if (commentsJson == null) return [];

    try {
      final List<dynamic> commentsList = json.decode(commentsJson);
      return commentsList.map((item) {
        final data = item as Map<String, dynamic>;
        return CommentData(
          id: data['id'] as String,
          productId: data['product_id'] as String,
          content: data['content'] as String,
          rating: data['rating'] as double?,
          createdAt: DateTime.parse(data['created_at'] as String),
          updatedAt: data['updated_at'] != null
              ? DateTime.parse(data['updated_at'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserPreferencesData?> getPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);

    if (preferencesJson == null) return null;

    try {
      final data = json.decode(preferencesJson) as Map<String, dynamic>;
      return UserPreferencesData(
        settings: Map<String, dynamic>.from(data['settings'] ?? {}),
        language: data['language'] as String?,
        theme: data['theme'] as String?,
        notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      );
    } catch (e) {
      return null;
    }
  }
}