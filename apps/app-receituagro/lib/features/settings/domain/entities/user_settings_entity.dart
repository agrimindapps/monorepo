/// Domain entity representing user settings preferences.
/// This is the core business entity used throughout the domain layer.
class UserSettingsEntity {
  final String userId;
  final bool isDarkTheme;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language;
  final bool isDevelopmentMode;
  final bool speechToTextEnabled;
  final bool analyticsEnabled;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const UserSettingsEntity({
    required this.userId,
    required this.isDarkTheme,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.language,
    required this.isDevelopmentMode,
    required this.speechToTextEnabled,
    required this.analyticsEnabled,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Creates a copy of this entity with the given fields replaced.
  UserSettingsEntity copyWith({
    String? userId,
    bool? isDarkTheme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
    bool? isDevelopmentMode,
    bool? speechToTextEnabled,
    bool? analyticsEnabled,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return UserSettingsEntity(
      userId: userId ?? this.userId,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
      isDevelopmentMode: isDevelopmentMode ?? this.isDevelopmentMode,
      speechToTextEnabled: speechToTextEnabled ?? this.speechToTextEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      lastUpdated: lastUpdated ?? DateTime.now(),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Business rule: Get default settings for new users
  static UserSettingsEntity createDefault(String userId) {
    final now = DateTime.now();
    return UserSettingsEntity(
      userId: userId,
      isDarkTheme: false,
      notificationsEnabled: true,
      soundEnabled: true,
      language: 'pt-BR',
      isDevelopmentMode: false,
      speechToTextEnabled: false,
      analyticsEnabled: true,
      lastUpdated: now,
      createdAt: now,
    );
  }

  /// Business rule: Check if settings are valid
  bool get isValid {
    return userId.isNotEmpty &&
           language.isNotEmpty &&
           createdAt.isBefore(DateTime.now().add(const Duration(seconds: 1)));
  }

  /// Business rule: Check if user has premium features enabled
  bool get hasPremiumFeatures {
    return speechToTextEnabled; // This would be controlled by subscription
  }

  /// Business rule: Get accessibility level
  String get accessibilityLevel {
    int score = 0;
    if (soundEnabled) score++;
    if (speechToTextEnabled) score++;
    if (!isDarkTheme) score++; // Light theme might be more accessible for some
    
    if (score >= 3) return 'high';
    if (score >= 2) return 'medium';
    return 'basic';
  }

  /// Business rule: Check if settings need migration (old versions)
  bool get needsMigration {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > 365 && language.isEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettingsEntity &&
        other.userId == userId &&
        other.isDarkTheme == isDarkTheme &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.language == language &&
        other.isDevelopmentMode == isDevelopmentMode &&
        other.speechToTextEnabled == speechToTextEnabled &&
        other.analyticsEnabled == analyticsEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      userId,
      isDarkTheme,
      notificationsEnabled,
      soundEnabled,
      language,
      isDevelopmentMode,
      speechToTextEnabled,
      analyticsEnabled,
    );
  }

  @override
  String toString() {
    return 'UserSettingsEntity(userId: $userId, isDark: $isDarkTheme, lang: $language)';
  }
}