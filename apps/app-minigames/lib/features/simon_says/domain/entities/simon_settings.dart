enum SimonDifficulty {
  easy,
  normal,
  hard;

  String get label {
    switch (this) {
      case SimonDifficulty.easy:
        return 'Fácil';
      case SimonDifficulty.normal:
        return 'Normal';
      case SimonDifficulty.hard:
        return 'Difícil';
    }
  }

  int get sequenceDelayMs {
    switch (this) {
      case SimonDifficulty.easy:
        return 800;
      case SimonDifficulty.normal:
        return 600;
      case SimonDifficulty.hard:
        return 400;
    }
  }

  int get gapDelayMs {
    switch (this) {
      case SimonDifficulty.easy:
        return 300;
      case SimonDifficulty.normal:
        return 200;
      case SimonDifficulty.hard:
        return 100;
    }
  }
}

class SimonSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  final SimonDifficulty difficulty;
  final bool colorblindMode;
  final int colorCount;

  const SimonSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.7,
    this.musicVolume = 0.5,
    this.difficulty = SimonDifficulty.normal,
    this.colorblindMode = false,
    this.colorCount = 4,
  });

  SimonSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
    SimonDifficulty? difficulty,
    bool? colorblindMode,
    int? colorCount,
  }) {
    return SimonSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      difficulty: difficulty ?? this.difficulty,
      colorblindMode: colorblindMode ?? this.colorblindMode,
      colorCount: colorCount ?? this.colorCount,
    );
  }
}
