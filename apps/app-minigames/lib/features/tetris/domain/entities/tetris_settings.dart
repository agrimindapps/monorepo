import 'package:equatable/equatable.dart';

/// Tema visual do Tetris
enum TetrisTheme {
  classic('Clássico'),
  neon('Neon'),
  pastel('Pastel'),
  retro('Retro');

  const TetrisTheme(this.displayName);
  final String displayName;
}

/// Entidade que representa as configurações do Tetris
class TetrisSettings extends Equatable {
  /// Som habilitado
  final bool soundEnabled;
  
  /// Música de fundo habilitada
  final bool musicEnabled;
  
  /// Ghost piece (sombra) habilitada
  final bool ghostPieceEnabled;
  
  /// Tema visual
  final TetrisTheme theme;
  
  /// Volume do som (0.0 a 1.0)
  final double soundVolume;
  
  /// Volume da música (0.0 a 1.0)
  final double musicVolume;

  const TetrisSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.ghostPieceEnabled = true,
    this.theme = TetrisTheme.classic,
    this.soundVolume = 0.7,
    this.musicVolume = 0.5,
  });

  /// Factory para settings padrão
  factory TetrisSettings.defaults() {
    return const TetrisSettings();
  }

  /// Cria cópia com campos modificados
  TetrisSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? ghostPieceEnabled,
    TetrisTheme? theme,
    double? soundVolume,
    double? musicVolume,
  }) {
    return TetrisSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      ghostPieceEnabled: ghostPieceEnabled ?? this.ghostPieceEnabled,
      theme: theme ?? this.theme,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }

  @override
  List<Object?> get props => [
        soundEnabled,
        musicEnabled,
        ghostPieceEnabled,
        theme,
        soundVolume,
        musicVolume,
      ];

  @override
  String toString() {
    return 'TetrisSettings(sound: $soundEnabled, music: $musicEnabled, ghost: $ghostPieceEnabled, theme: ${theme.displayName})';
  }
}
