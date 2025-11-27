import 'package:equatable/equatable.dart';

/// Achievement types for gamification
enum WaterAchievementType {
  firstDrop('first_drop'),
  perfectWeek('perfect_week'),
  hydratedMonth('hydrated_month'),
  earlyBird('early_bird'),
  superHydrated('super_hydrated'),
  consistent('consistent'),
  master('master');

  final String value;
  const WaterAchievementType(this.value);

  static WaterAchievementType fromString(String value) {
    return WaterAchievementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WaterAchievementType.firstDrop,
    );
  }
}

/// Water Achievement entity
class WaterAchievementEntity extends Equatable {
  final String id;
  final WaterAchievementType type;
  final String title;
  final String description;
  final DateTime? unlockedAt;
  final String? iconName;
  final bool isUnlocked;
  final int? requiredValue;
  final int currentProgress;
  final String category;

  const WaterAchievementEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.unlockedAt,
    this.iconName,
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

  WaterAchievementEntity copyWith({
    String? id,
    WaterAchievementType? type,
    String? title,
    String? description,
    DateTime? unlockedAt,
    String? iconName,
    bool? isUnlocked,
    int? requiredValue,
    int? currentProgress,
    String? category,
  }) {
    return WaterAchievementEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconName: iconName ?? this.iconName,
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
        unlockedAt,
        iconName,
        isUnlocked,
        requiredValue,
        currentProgress,
        category,
      ];
}
