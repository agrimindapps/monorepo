import 'package:equatable/equatable.dart';

/// Domain entity representing app settings
/// Immutable and contains only business logic
class AppSettings extends Equatable {
  final bool isDarkMode;
  final double ttsSpeed;
  final double ttsPitch;
  final double ttsVolume;
  final String ttsLanguage;

  const AppSettings({
    this.isDarkMode = false,
    this.ttsSpeed = 0.5,
    this.ttsPitch = 1.0,
    this.ttsVolume = 1.0,
    this.ttsLanguage = 'pt-BR',
  });

  /// Create a copy of this AppSettings with modified fields
  AppSettings copyWith({
    bool? isDarkMode,
    double? ttsSpeed,
    double? ttsPitch,
    double? ttsVolume,
    String? ttsLanguage,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      ttsLanguage: ttsLanguage ?? this.ttsLanguage,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        ttsSpeed,
        ttsPitch,
        ttsVolume,
        ttsLanguage,
      ];

  @override
  bool get stringify => true;
}
