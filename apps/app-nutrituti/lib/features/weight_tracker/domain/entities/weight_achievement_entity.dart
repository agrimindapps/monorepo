import 'package:equatable/equatable.dart';

/// Achievement types for weight tracking gamification
enum WeightAchievementType {
  firstWeigh('first_weigh'),
  consistent7('consistent_7'),
  monthComplete('month_complete'),
  lost2kg('lost_2kg'),
  lost5kg('lost_5kg'),
  lost10kg('lost_10kg'),
  healthyBmi('healthy_bmi'),
  goalReached('goal_reached'),
  halfway('halfway'),
  earlyRiser('early_riser');

  final String value;
  const WeightAchievementType(this.value);

  static WeightAchievementType fromString(String value) {
    return WeightAchievementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WeightAchievementType.firstWeigh,
    );
  }
}

/// Weight Achievement entity
class WeightAchievementEntity extends Equatable {
  final String id;
  final WeightAchievementType type;
  final String title;
  final String description;
  final String emoji;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final int? requiredValue;
  final int currentProgress;
  final String category;

  const WeightAchievementEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlockedAt,
    this.isUnlocked = false,
    this.requiredValue,
    this.currentProgress = 0,
    this.category = 'general',
  });

  /// Progress percentage (0-100)
  double get progressPercentage {
    if (requiredValue == null || requiredValue == 0) return isUnlocked ? 100 : 0;
    return (currentProgress / requiredValue! * 100).clamp(0, 100);
  }

  /// Remaining value to unlock
  int get remainingToUnlock {
    if (requiredValue == null) return 0;
    return (requiredValue! - currentProgress).clamp(0, requiredValue!);
  }

  WeightAchievementEntity copyWith({
    String? id,
    WeightAchievementType? type,
    String? title,
    String? description,
    String? emoji,
    DateTime? unlockedAt,
    bool? isUnlocked,
    int? requiredValue,
    int? currentProgress,
    String? category,
  }) {
    return WeightAchievementEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredValue: requiredValue ?? this.requiredValue,
      currentProgress: currentProgress ?? this.currentProgress,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        description,
        emoji,
        unlockedAt,
        isUnlocked,
        requiredValue,
        currentProgress,
        category,
      ];
}
