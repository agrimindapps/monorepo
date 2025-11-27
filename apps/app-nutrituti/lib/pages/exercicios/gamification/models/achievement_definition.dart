import 'package:equatable/equatable.dart';

import '../enums/challenge_type.dart';

/// Definição de uma conquista no sistema FitQuest
class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.xpReward,
    this.emoji = '🏆',
  });

  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int target;
  final int xpReward;
  final String emoji;

  @override
  List<Object?> get props =>
      [id, title, description, type, target, xpReward, emoji];
}

/// Conquista com progresso do usuário
class AchievementWithProgress extends Equatable {
  const AchievementWithProgress({
    required this.definition,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final AchievementDefinition definition;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  /// Progresso percentual (0.0 - 1.0)
  double get progressPercent {
    if (definition.target <= 0) return 0.0;
    return (currentProgress / definition.target).clamp(0.0, 1.0);
  }

  /// Progresso como texto (ex: "7/10")
  String get progressText => '$currentProgress/${definition.target}';

  AchievementWithProgress copyWith({
    AchievementDefinition? definition,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementWithProgress(
      definition: definition ?? this.definition,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props =>
      [definition, currentProgress, isUnlocked, unlockedAt];
}
