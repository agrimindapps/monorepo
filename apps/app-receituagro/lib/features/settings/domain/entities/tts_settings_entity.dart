import 'package:equatable/equatable.dart';

class TTSSettingsEntity extends Equatable {
  final bool enabled;
  final double rate; // 0.5 - 2.0 (default: 0.8)
  final double pitch; // 0.5 - 2.0 (default: 1.0)
  final double volume; // 0.0 - 1.0 (default: 0.8)
  final String language; // 'pt-BR'
  final bool autoPlay; // false (not implemented yet)

  const TTSSettingsEntity({
    required this.enabled,
    required this.rate,
    required this.pitch,
    required this.volume,
    required this.language,
    required this.autoPlay,
  });

  /// Default settings with sensible values
  factory TTSSettingsEntity.defaults() {
    return const TTSSettingsEntity(
      enabled: false,
      rate: 0.8, // Comfortable speed
      pitch: 1.0, // Neutral tone
      volume: 0.8, // High but not max
      language: 'pt-BR',
      autoPlay: false,
    );
  }

  /// Copy with method for immutability
  TTSSettingsEntity copyWith({
    bool? enabled,
    double? rate,
    double? pitch,
    double? volume,
    String? language,
    bool? autoPlay,
  }) {
    return TTSSettingsEntity(
      enabled: enabled ?? this.enabled,
      rate: rate ?? this.rate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      autoPlay: autoPlay ?? this.autoPlay,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'rate': rate,
      'pitch': pitch,
      'volume': volume,
      'language': language,
      'autoPlay': autoPlay,
    };
  }

  /// Deserialize from JSON
  factory TTSSettingsEntity.fromJson(Map<String, dynamic> json) {
    return TTSSettingsEntity(
      enabled: json['enabled'] as bool? ?? false,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.8,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      language: json['language'] as String? ?? 'pt-BR',
      autoPlay: json['autoPlay'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [enabled, rate, pitch, volume, language, autoPlay];
}
