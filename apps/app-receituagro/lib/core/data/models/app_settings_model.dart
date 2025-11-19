// DEPRECATED: Legacy model - migrate to Drift AppSettings table
// Maintained for backward compatibility during migration phase
class AppSettingsModel {
  final String? theme; // 'light', 'dark', 'system'

  final String? language; // 'pt', 'en', 'es'

  final bool enableNotifications;

  final bool enableSync;

  final Map<String, bool> featureFlags;

  final String? userId;

  final bool syncSynchronized;

  final DateTime? syncSyncedAt;

  final DateTime syncCreatedAt;

  final DateTime? syncUpdatedAt;

  AppSettingsModel({
    this.theme = 'system',
    this.language = 'pt',
    this.enableNotifications = true,
    this.enableSync = true,
    this.featureFlags = const {},
    this.userId,
    this.syncSynchronized = false,
    this.syncSyncedAt,
    required this.syncCreatedAt,
    this.syncUpdatedAt,
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
      syncSynchronized: map['sync_synchronized'] == true,
      syncSyncedAt: map['sync_syncedAt'] != null
          ? DateTime.tryParse(map['sync_syncedAt'].toString())
          : null,
      syncCreatedAt:
          DateTime.tryParse(map['sync_createdAt']?.toString() ?? '') ??
          DateTime.now(),
      syncUpdatedAt: map['sync_updatedAt'] != null
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
      'sync_synchronized': syncSynchronized,
      'sync_syncedAt': syncSyncedAt?.toIso8601String(),
      'sync_createdAt': syncCreatedAt.toIso8601String(),
      'sync_updatedAt': syncUpdatedAt?.toIso8601String(),
    };
  }

  AppSettingsModel copyWith({
    String? theme,
    String? language,
    bool? enableNotifications,
    bool? enableSync,
    Map<String, bool>? featureFlags,
    String? userId,
    bool? syncSynchronized,
    DateTime? syncSyncedAt,
    DateTime? syncCreatedAt,
    DateTime? syncUpdatedAt,
  }) {
    return AppSettingsModel(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSync: enableSync ?? this.enableSync,
      featureFlags: featureFlags ?? this.featureFlags,
      userId: userId ?? this.userId,
      syncSynchronized: syncSynchronized ?? this.syncSynchronized,
      syncSyncedAt: syncSyncedAt ?? this.syncSyncedAt,
      syncCreatedAt: syncCreatedAt ?? this.syncCreatedAt,
      syncUpdatedAt: syncUpdatedAt ?? this.syncUpdatedAt,
    );
  }

  AppSettingsModel markAsDirty() {
    return copyWith(syncSynchronized: false, syncUpdatedAt: DateTime.now());
  }

  AppSettingsModel markAsSynchronized() {
    return copyWith(syncSynchronized: true, syncSyncedAt: DateTime.now());
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
