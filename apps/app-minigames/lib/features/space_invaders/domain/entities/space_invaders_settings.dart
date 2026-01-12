enum SpaceInvadersDifficulty {
  easy,
  normal,
  hard;

  String get label {
    switch (this) {
      case SpaceInvadersDifficulty.easy:
        return 'Fácil';
      case SpaceInvadersDifficulty.normal:
        return 'Normal';
      case SpaceInvadersDifficulty.hard:
        return 'Difícil';
    }
  }

  double get invaderSpeedMultiplier {
    switch (this) {
      case SpaceInvadersDifficulty.easy:
        return 0.7;
      case SpaceInvadersDifficulty.normal:
        return 1.0;
      case SpaceInvadersDifficulty.hard:
        return 1.5;
    }
  }

  double get shootFrequency {
    switch (this) {
      case SpaceInvadersDifficulty.easy:
        return 2.0;
      case SpaceInvadersDifficulty.normal:
        return 1.5;
      case SpaceInvadersDifficulty.hard:
        return 1.0;
    }
  }
}

class SpaceInvadersSettings {
  final bool soundEnabled;
  final bool musicEnabled;
  final double soundVolume;
  final double musicVolume;
  final SpaceInvadersDifficulty difficulty;
  final bool showFPS;

  const SpaceInvadersSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.soundVolume = 0.7,
    this.musicVolume = 0.5,
    this.difficulty = SpaceInvadersDifficulty.normal,
    this.showFPS = false,
  });

  SpaceInvadersSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    double? soundVolume,
    double? musicVolume,
    SpaceInvadersDifficulty? difficulty,
    bool? showFPS,
  }) {
    return SpaceInvadersSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      difficulty: difficulty ?? this.difficulty,
      showFPS: showFPS ?? this.showFPS,
    );
  }
}
