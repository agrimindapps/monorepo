import 'package:core/core.dart';

part 'app_settings_model.g.dart';

@HiveType(typeId: 20)
class AppSettingsModel extends HiveObject {
  @HiveField(0)
  final String? theme; // 'light', 'dark', 'system'
  
  @HiveField(1)
  final String? language; // 'pt', 'en', 'es'
  
  @HiveField(2)
  final bool enableNotifications;
  
  @HiveField(3)
  final bool enableSync;
  
  @HiveField(4)
  final Map<String, bool> featureFlags;
  
  @HiveField(5)
  final String? userId;
  
  @HiveField(6)
  final bool synchronized;
  
  @HiveField(7)
  final DateTime? syncedAt;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime? updatedAt;

  AppSettingsModel({
    this.theme = 'system',
    this.language = 'pt',
    this.enableNotifications = true,
    this.enableSync = true,
    this.featureFlags = const {},
    this.userId,
    this.synchronized = false,
    this.syncedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      theme: map['theme']?.toString() ?? 'system',
      language: map['language']?.toString() ?? 'pt',
      enableNotifications: map['enableNotifications'] == true,
      enableSync: map['enableSync'] == true,
      featureFlags: map['featureFlags'] != null 
          ? Map<String, bool>.from(map['featureFlags'] as Map)
          : const {},
      userId: map['userId']?.toString(),
      synchronized: map['synchronized'] == true,
      syncedAt: map['syncedAt'] != null 
          ? DateTime.tryParse(map['syncedAt'].toString())
          : null,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      'enableNotifications': enableNotifications,
      'enableSync': enableSync,
      'featureFlags': featureFlags,
      'userId': userId,
      'synchronized': synchronized,
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  AppSettingsModel copyWith({
    String? theme,
    String? language,
    bool? enableNotifications,
    bool? enableSync,
    Map<String, bool>? featureFlags,
    String? userId,
    bool? synchronized,
    DateTime? syncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettingsModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSync: enableSync ?? this.enableSync,
      featureFlags: featureFlags ?? this.featureFlags,
      userId: userId ?? this.userId,
      synchronized: synchronized ?? this.synchronized,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  AppSettingsModel markAsUnsynchronized() {
    return copyWith(
      synchronized: false,
      updatedAt: DateTime.now(),
    );
  }

  AppSettingsModel markAsSynchronized() {
    return copyWith(
      synchronized: true,
      syncedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettingsModel &&
        other.userId == userId &&
        other.theme == theme &&
        other.language == language &&
        other.enableNotifications == enableNotifications &&
        other.enableSync == enableSync;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      theme,
      language,
      enableNotifications,
      enableSync,
    );
  }

  @override
  String toString() {
    return 'AppSettingsModel('
        'userId: $userId, '
        'theme: $theme, '
        'language: $language, '
        'sync: $enableSync, '
        'synchronized: $synchronized'
        ')';
  }
}
