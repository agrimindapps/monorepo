import 'package:core/core.dart' hide Column;

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
  final bool sync_synchronized;

  @HiveField(7)
  final DateTime? sync_syncedAt;

  @HiveField(8)
  final DateTime sync_createdAt;

  @HiveField(9)
  final DateTime? sync_updatedAt;

  AppSettingsModel({
    this.theme = 'system',
    this.language = 'pt',
    this.enableNotifications = true,
    this.enableSync = true,
    this.featureFlags = const {},
    this.userId,
    this.sync_synchronized = false,
    this.sync_syncedAt,
    required this.sync_createdAt,
    this.sync_updatedAt,
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
      sync_synchronized: map['sync_synchronized'] == true,
      sync_syncedAt: map['sync_syncedAt'] != null
          ? DateTime.tryParse(map['sync_syncedAt'].toString())
          : null,
      sync_createdAt: DateTime.tryParse(map['sync_createdAt']?.toString() ?? '') ?? DateTime.now(),
      sync_updatedAt: map['sync_updatedAt'] != null
          ? DateTime.tryParse(map['sync_updatedAt'].toString())
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
      'sync_synchronized': sync_synchronized,
      'sync_syncedAt': sync_syncedAt?.toIso8601String(),
      'sync_createdAt': sync_createdAt.toIso8601String(),
      'sync_updatedAt': sync_updatedAt?.toIso8601String(),
    };
  }

  AppSettingsModel copyWith({
    String? theme,
    String? language,
    bool? enableNotifications,
    bool? enableSync,
    Map<String, bool>? featureFlags,
    String? userId,
    bool? sync_synchronized,
    DateTime? sync_syncedAt,
    DateTime? sync_createdAt,
    DateTime? sync_updatedAt,
  }) {
    return AppSettingsModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSync: enableSync ?? this.enableSync,
      featureFlags: featureFlags ?? this.featureFlags,
      userId: userId ?? this.userId,
      sync_synchronized: sync_synchronized ?? this.sync_synchronized,
      sync_syncedAt: sync_syncedAt ?? this.sync_syncedAt,
      sync_createdAt: sync_createdAt ?? this.sync_createdAt,
      sync_updatedAt: sync_updatedAt ?? this.sync_updatedAt,
    );
  }

  AppSettingsModel markAsUnsynchronized() {
    return copyWith(
      sync_synchronized: false,
      sync_updatedAt: DateTime.now(),
    );
  }

  AppSettingsModel markAsSynchronized() {
    return copyWith(
      sync_synchronized: true,
      sync_syncedAt: DateTime.now(),
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
        'synchronized: $sync_synchronized'
        ')';
  }
}
