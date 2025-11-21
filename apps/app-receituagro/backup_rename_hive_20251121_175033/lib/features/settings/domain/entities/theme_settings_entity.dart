/// Domain entity representing theme-related user settings.
/// Responsible for managing dark mode, language, and visual preferences.
///
/// Business Rules:
/// - Language must be a valid BCP 47 language tag (e.g., 'pt-BR', 'en-US')
/// - isDarkTheme can be toggled independently from other settings
/// - lastUpdated tracks when this specific setting was last changed
class ThemeSettingsEntity {
  final bool isDarkTheme;
  final String language;
  final DateTime lastUpdated;

  const ThemeSettingsEntity({
    required this.isDarkTheme,
    required this.language,
    required this.lastUpdated,
  });

  /// Creates a copy of this entity with the given fields replaced.
  /// If a field is not provided, the current value is retained.
  ThemeSettingsEntity copyWith({
    bool? isDarkTheme,
    String? language,
    DateTime? lastUpdated,
  }) {
    return ThemeSettingsEntity(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      language: language ?? this.language,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Creates default theme settings for new users.
  /// Defaults: Light theme, Portuguese (Brazil), current timestamp
  static ThemeSettingsEntity defaults() {
    return ThemeSettingsEntity(
      isDarkTheme: false,
      language: 'pt-BR',
      lastUpdated: DateTime.now(),
    );
  }

  /// Business rule: Check if theme settings are valid
  /// A valid theme setting must have a non-empty language code
  bool get isValid {
    return language.isNotEmpty;
  }

  /// Business rule: Check if language is right-to-left (RTL)
  /// Used for UI layout adjustments
  bool get isRtlLanguage {
    return language.startsWith('ar') || language.startsWith('he');
  }

  /// Business rule: Get language display name
  /// Maps language codes to human-readable names
  String get languageDisplayName {
    return _languageNames[language] ?? language;
  }

  /// Maps language codes to display names
  static const Map<String, String> _languageNames = {
    'pt-BR': 'Português (Brasil)',
    'pt-PT': 'Português (Portugal)',
    'en-US': 'English (US)',
    'en-GB': 'English (UK)',
    'es-ES': 'Español (España)',
    'es-MX': 'Español (México)',
    'fr-FR': 'Français',
    'de-DE': 'Deutsch',
    'it-IT': 'Italiano',
    'ja-JP': '日本語',
    'zh-CN': '简体中文',
    'zh-TW': '繁體中文',
  };

  /// Business rule: Check if theme changed
  bool hasThemeChanged(ThemeSettingsEntity other) {
    return isDarkTheme != other.isDarkTheme;
  }

  /// Business rule: Check if language changed
  bool hasLanguageChanged(ThemeSettingsEntity other) {
    return language != other.language;
  }

  @override
  String toString() {
    return 'ThemeSettingsEntity('
        'isDarkTheme: $isDarkTheme, '
        'language: $language, '
        'lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThemeSettingsEntity &&
        other.isDarkTheme == isDarkTheme &&
        other.language == language &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return isDarkTheme.hashCode ^ language.hashCode ^ lastUpdated.hashCode;
  }
}
