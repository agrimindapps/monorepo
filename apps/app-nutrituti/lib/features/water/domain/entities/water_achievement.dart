import 'package:equatable/equatable.dart';

/// Achievement types for water intake milestones
enum AchievementType {
  firstRecord,
  threeDayStreak,
  sevenDayStreak,
  monthlyGoal,
  perfectWeek,
  hydrationHero,
}

/// Pure Dart entity for water intake achievements
class WaterAchievement extends Equatable {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final DateTime unlockedAt;
  final String? iconName;

  const WaterAchievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.unlockedAt,
    this.iconName,
  });

  /// Factory methods for predefined achievements
  factory WaterAchievement.firstRecord({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.firstRecord,
      title: 'Primeiro Registro',
      description: 'Você registrou seu primeiro copo de água!',
      unlockedAt: unlockedAt,
      iconName: 'water_drop',
    );
  }

  factory WaterAchievement.threeDayStreak({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.threeDayStreak,
      title: 'Sequência de 3 Dias',
      description: 'Você atingiu sua meta por 3 dias consecutivos!',
      unlockedAt: unlockedAt,
      iconName: 'streak_3',
    );
  }

  factory WaterAchievement.sevenDayStreak({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.sevenDayStreak,
      title: 'Semana Perfeita',
      description: 'Você atingiu sua meta por 7 dias seguidos!',
      unlockedAt: unlockedAt,
      iconName: 'streak_7',
    );
  }

  factory WaterAchievement.monthlyGoal({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.monthlyGoal,
      title: 'Meta Mensal',
      description: 'Você atingiu sua meta diária 20+ vezes neste mês!',
      unlockedAt: unlockedAt,
      iconName: 'monthly_champion',
    );
  }

  factory WaterAchievement.perfectWeek({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.perfectWeek,
      title: 'Semana Impecável',
      description: 'Você superou sua meta todos os dias da semana!',
      unlockedAt: unlockedAt,
      iconName: 'perfect_week',
    );
  }

  factory WaterAchievement.hydrationHero({
    required String id,
    required DateTime unlockedAt,
  }) {
    return WaterAchievement(
      id: id,
      type: AchievementType.hydrationHero,
      title: 'Herói da Hidratação',
      description: 'Você registrou 100+ copos de água!',
      unlockedAt: unlockedAt,
      iconName: 'hero_badge',
    );
  }

  WaterAchievement copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? description,
    DateTime? unlockedAt,
    String? iconName,
  }) {
    return WaterAchievement(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [id, type, title, description, unlockedAt, iconName];

  @override
  String toString() {
    return 'WaterAchievement(id: $id, type: $type, title: $title)';
  }
}
