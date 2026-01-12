enum ArkanoidDifficulty { easy, normal, hard;
  String get label {
    switch (this) {
      case ArkanoidDifficulty.easy: return 'Fácil';
      case ArkanoidDifficulty.normal: return 'Normal';
      case ArkanoidDifficulty.hard: return 'Difícil';
    }
  }
  double get ballSpeedMultiplier {
    switch (this) {
      case ArkanoidDifficulty.easy: return 0.7;
      case ArkanoidDifficulty.normal: return 1.0;
      case ArkanoidDifficulty.hard: return 1.3;
    }
  }
}

class ArkanoidSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  final ArkanoidDifficulty difficulty;

  const ArkanoidSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.7,
    this.musicVolume = 0.5,
    this.difficulty = ArkanoidDifficulty.normal,
  });

  ArkanoidSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
    ArkanoidDifficulty? difficulty,
  }) {
    return ArkanoidSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
