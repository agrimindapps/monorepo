class ExportData {
  final UserProfileData? userProfile;
  final List<FavoriteData> favorites;
  final List<CommentData> comments;
  final UserPreferencesData? preferences;
  final ExportMetadata metadata;

  const ExportData({
    this.userProfile,
    required this.favorites,
    required this.comments,
    this.preferences,
    required this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'user_profile': userProfile?.toJson(),
      'favorites': favorites.map((f) => f.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'preferences': preferences?.toJson(),
    };
  }
}

class UserProfileData {
  final String? name;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserProfileData({
    this.name,
    this.email,
    this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

class FavoriteData {
  final String productId;
  final String productName;
  final String? category;
  final DateTime createdAt;

  const FavoriteData({
    required this.productId,
    required this.productName,
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CommentData {
  final String id;
  final String productId;
  final String content;
  final double? rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CommentData({
    required this.id,
    required this.productId,
    required this.content,
    this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UserPreferencesData {
  final Map<String, dynamic> settings;
  final String? language;
  final String? theme;
  final bool notificationsEnabled;

  const UserPreferencesData({
    required this.settings,
    this.language,
    this.theme,
    required this.notificationsEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'settings': settings,
      'language': language,
      'theme': theme,
      'notifications_enabled': notificationsEnabled,
    };
  }
}

class ExportMetadata {
  final DateTime exportDate;
  final String userId;
  final String appVersion;
  final String dataVersion;
  final String format;
  final int totalRecords;

  const ExportMetadata({
    required this.exportDate,
    required this.userId,
    required this.appVersion,
    required this.dataVersion,
    required this.format,
    required this.totalRecords,
  });

  Map<String, dynamic> toJson() {
    return {
      'export_date': exportDate.toIso8601String(),
      'user_id': userId,
      'app_version': appVersion,
      'data_version': dataVersion,
      'format': format,
      'total_records': totalRecords,
    };
  }
}