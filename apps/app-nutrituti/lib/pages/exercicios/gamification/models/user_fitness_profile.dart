import 'package:equatable/equatable.dart';

import 'weekly_challenge.dart';

/// Perfil fitness do usuário com XP, níveis e estatísticas
class UserFitnessProfile extends Equatable {
  const UserFitnessProfile({
    required this.id,
    required this.totalXp,
    required this.currentLevel,
    required this.streakDays,
    required this.bestStreak,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.unlockedAchievements,
    this.weeklyChallenge,
    this.lastWorkoutDate,
    this.categoriesUsed = const {},
    this.earlyBirdCount = 0,
    this.nightOwlCount = 0,
    this.weekendWarriorCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int totalXp;
  final int currentLevel;
  final int streakDays;
  final int bestStreak;
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final List<String> unlockedAchievements;
  final WeeklyChallenge? weeklyChallenge;
  final DateTime? lastWorkoutDate;
  final Set<String> categoriesUsed;
  final int earlyBirdCount;
  final int nightOwlCount;
  final int weekendWarriorCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// XP necessário para cada nível
  static const Map<int, int> levelXpThresholds = {
    1: 0,
    2: 100,
    3: 300,
    4: 600,
    5: 1000,
    6: 1500,
    7: 2100,
    8: 2800,
    9: 3600,
    10: 4500,
  };

  /// Títulos para cada nível
  static const Map<int, String> levelTitles = {
    1: 'Iniciante',
    2: 'Aprendiz',
    3: 'Praticante',
    4: 'Dedicado',
    5: 'Guerreiro',
    6: 'Atleta',
    7: 'Veterano',
    8: 'Mestre',
    9: 'Campeão',
    10: 'Lenda Fitness',
  };

  /// Título do nível atual
  String get levelTitle => levelTitles[currentLevel] ?? 'Iniciante';

  /// XP do nível atual (progresso dentro do nível)
  int get currentLevelXp {
    final currentThreshold = levelXpThresholds[currentLevel] ?? 0;
    return totalXp - currentThreshold;
  }

  /// XP necessário para o próximo nível
  int get xpForNextLevel {
    if (currentLevel >= 10) return 0;
    final nextThreshold = levelXpThresholds[currentLevel + 1] ?? 0;
    final currentThreshold = levelXpThresholds[currentLevel] ?? 0;
    return nextThreshold - currentThreshold;
  }

  /// Progresso percentual para o próximo nível (0.0 - 1.0)
  double get levelProgressPercent {
    if (currentLevel >= 10) return 1.0;
    if (xpForNextLevel <= 0) return 0.0;
    return (currentLevelXp / xpForNextLevel).clamp(0.0, 1.0);
  }

  /// Verifica se atingiu o nível máximo
  bool get isMaxLevel => currentLevel >= 10;

  /// Cria um perfil vazio para novo usuário
  factory UserFitnessProfile.empty({String? id}) => UserFitnessProfile(
        id: id ?? 'default',
        totalXp: 0,
        currentLevel: 1,
        streakDays: 0,
        bestStreak: 0,
        totalWorkouts: 0,
        totalMinutes: 0,
        totalCalories: 0,
        unlockedAchievements: const [],
        categoriesUsed: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  UserFitnessProfile copyWith({
    String? id,
    int? totalXp,
    int? currentLevel,
    int? streakDays,
    int? bestStreak,
    int? totalWorkouts,
    int? totalMinutes,
    int? totalCalories,
    List<String>? unlockedAchievements,
    WeeklyChallenge? weeklyChallenge,
    DateTime? lastWorkoutDate,
    Set<String>? categoriesUsed,
    int? earlyBirdCount,
    int? nightOwlCount,
    int? weekendWarriorCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFitnessProfile(
      id: id ?? this.id,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      streakDays: streakDays ?? this.streakDays,
      bestStreak: bestStreak ?? this.bestStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      totalCalories: totalCalories ?? this.totalCalories,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      weeklyChallenge: weeklyChallenge ?? this.weeklyChallenge,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      categoriesUsed: categoriesUsed ?? this.categoriesUsed,
      earlyBirdCount: earlyBirdCount ?? this.earlyBirdCount,
      nightOwlCount: nightOwlCount ?? this.nightOwlCount,
      weekendWarriorCount: weekendWarriorCount ?? this.weekendWarriorCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'totalXp': totalXp,
        'currentLevel': currentLevel,
        'streakDays': streakDays,
        'bestStreak': bestStreak,
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'totalCalories': totalCalories,
        'unlockedAchievements': unlockedAchievements,
        'weeklyChallenge': weeklyChallenge?.toJson(),
        'lastWorkoutDate': lastWorkoutDate?.millisecondsSinceEpoch,
        'categoriesUsed': categoriesUsed.toList(),
        'earlyBirdCount': earlyBirdCount,
        'nightOwlCount': nightOwlCount,
        'weekendWarriorCount': weekendWarriorCount,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  factory UserFitnessProfile.fromJson(Map<String, dynamic> json) {
    return UserFitnessProfile(
      id: json['id'] as String,
      totalXp: json['totalXp'] as int,
      currentLevel: json['currentLevel'] as int,
      streakDays: json['streakDays'] as int,
      bestStreak: json['bestStreak'] as int,
      totalWorkouts: json['totalWorkouts'] as int,
      totalMinutes: json['totalMinutes'] as int,
      totalCalories: json['totalCalories'] as int,
      unlockedAchievements:
          (json['unlockedAchievements'] as List).cast<String>(),
      weeklyChallenge: json['weeklyChallenge'] != null
          ? WeeklyChallenge.fromJson(
              json['weeklyChallenge'] as Map<String, dynamic>)
          : null,
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastWorkoutDate'] as int)
          : null,
      categoriesUsed: json['categoriesUsed'] != null
          ? (json['categoriesUsed'] as List).cast<String>().toSet()
          : {},
      earlyBirdCount: json['earlyBirdCount'] as int? ?? 0,
      nightOwlCount: json['nightOwlCount'] as int? ?? 0,
      weekendWarriorCount: json['weekendWarriorCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        totalXp,
        currentLevel,
        streakDays,
        bestStreak,
        totalWorkouts,
        totalMinutes,
        totalCalories,
        unlockedAchievements,
        weeklyChallenge,
        lastWorkoutDate,
        categoriesUsed,
        earlyBirdCount,
        nightOwlCount,
        weekendWarriorCount,
        createdAt,
        updatedAt,
      ];
}
