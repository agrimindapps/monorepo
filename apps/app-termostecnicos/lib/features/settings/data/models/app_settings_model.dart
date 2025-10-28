import '../../domain/entities/app_settings.dart';

/// Data model for AppSettings
/// Extends domain entity and adds serialization capabilities
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    super.isDarkMode,
    super.ttsSpeed,
    super.ttsPitch,
    super.ttsVolume,
    super.ttsLanguage,
  });

  /// Create from domain entity
  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      isDarkMode: settings.isDarkMode,
      ttsSpeed: settings.ttsSpeed,
      ttsPitch: settings.ttsPitch,
      ttsVolume: settings.ttsVolume,
      ttsLanguage: settings.ttsLanguage,
    );
  }

  /// Create from JSON map (SharedPreferences)
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      ttsSpeed: (json['ttsSpeed'] as num?)?.toDouble() ?? 0.5,
      ttsPitch: (json['ttsPitch'] as num?)?.toDouble() ?? 1.0,
      ttsVolume: (json['ttsVolume'] as num?)?.toDouble() ?? 1.0,
      ttsLanguage: json['ttsLanguage'] as String? ?? 'pt-BR',
    );
  }

  /// Convert to JSON map (SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'ttsSpeed': ttsSpeed,
      'ttsPitch': ttsPitch,
      'ttsVolume': ttsVolume,
      'ttsLanguage': ttsLanguage,
    };
  }

  /// Convert to domain entity
  AppSettings toEntity() {
    return AppSettings(
      isDarkMode: isDarkMode,
      ttsSpeed: ttsSpeed,
      ttsPitch: ttsPitch,
      ttsVolume: ttsVolume,
      ttsLanguage: ttsLanguage,
    );
  }

  @override
  AppSettingsModel copyWith({
    bool? isDarkMode,
    double? ttsSpeed,
    double? ttsPitch,
    double? ttsVolume,
    String? ttsLanguage,
  }) {
    return AppSettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
    );
  }
}
