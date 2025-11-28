import 'dart:convert';
import '../../domain/entities/achievement.dart';

/// Data model for Sudoku achievement persistence
class SudokuAchievementModel {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final int? unlockedAtTimestamp;

  const SudokuAchievementModel({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAtTimestamp,
  });

  /// Create from entity
  factory SudokuAchievementModel.fromEntity(SudokuAchievement entity) {
    return SudokuAchievementModel(
      id: entity.id,
      currentProgress: entity.currentProgress,
      isUnlocked: entity.isUnlocked,
      unlockedAtTimestamp: entity.unlockedAt?.millisecondsSinceEpoch,
    );
  }

  /// Convert to entity
  SudokuAchievement toEntity() {
    return SudokuAchievement(
      id: id,
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(unlockedAtTimestamp!)
          : null,
    );
  }

  /// Create from JSON
  factory SudokuAchievementModel.fromJson(Map<String, dynamic> json) {
    return SudokuAchievementModel(
      id: json['id'] as String,
      currentProgress: json['currentProgress'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAtTimestamp: json['unlockedAtTimestamp'] as int?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAtTimestamp': unlockedAtTimestamp,
    };
  }

  SudokuAchievementModel copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    int? unlockedAtTimestamp,
  }) {
    return SudokuAchievementModel(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAtTimestamp: unlockedAtTimestamp ?? this.unlockedAtTimestamp,
    );
  }
}

/// Data model for all Sudoku achievements persistence
class SudokuAchievementsDataModel {
  final List<SudokuAchievementModel> achievements;
  final int totalXpFromAchievements;
  final int lastUpdatedTimestamp;

  const SudokuAchievementsDataModel({
    required this.achievements,
    this.totalXpFromAchievements = 0,
    required this.lastUpdatedTimestamp,
  });

  /// Create empty model
  factory SudokuAchievementsDataModel.empty() {
    return SudokuAchievementsDataModel(
      achievements: const [],
      totalXpFromAchievements: 0,
      lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Create from list of entities
  factory SudokuAchievementsDataModel.fromEntities(
    List<SudokuAchievement> entities,
  ) {
    final models = entities.map(SudokuAchievementModel.fromEntity).toList();
    final totalXp = entities
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.definition.rarity.xpReward);

    return SudokuAchievementsDataModel(
      achievements: models,
      totalXpFromAchievements: totalXp,
      lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to list of entities
  List<SudokuAchievement> toEntities() {
    return achievements.map((m) => m.toEntity()).toList();
  }

  /// Create from JSON
  factory SudokuAchievementsDataModel.fromJson(Map<String, dynamic> json) {
    final achievementsList = (json['achievements'] as List<dynamic>?)
            ?.map((e) =>
                SudokuAchievementModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SudokuAchievementsDataModel(
      achievements: achievementsList,
      totalXpFromAchievements: json['totalXpFromAchievements'] as int? ?? 0,
      lastUpdatedTimestamp: json['lastUpdatedTimestamp'] as int? ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'totalXpFromAchievements': totalXpFromAchievements,
      'lastUpdatedTimestamp': lastUpdatedTimestamp,
    };
  }

  /// Create from JSON string
  factory SudokuAchievementsDataModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return SudokuAchievementsDataModel.fromJson(json);
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Get last updated DateTime
  DateTime get lastUpdated =>
      DateTime.fromMillisecondsSinceEpoch(lastUpdatedTimestamp);

  /// Get unlocked count
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  /// Get total count
  int get totalCount => SudokuAchievementDefinitions.totalCount;

  /// Get completion percentage
  double get completionPercent {
    if (totalCount == 0) return 0.0;
    return unlockedCount / totalCount;
  }

  /// Get completion percentage as int
  int get completionPercentInt => (completionPercent * 100).round();

  SudokuAchievementsDataModel copyWith({
    List<SudokuAchievementModel>? achievements,
    int? totalXpFromAchievements,
    int? lastUpdatedTimestamp,
  }) {
    return SudokuAchievementsDataModel(
      achievements: achievements ?? this.achievements,
      totalXpFromAchievements:
          totalXpFromAchievements ?? this.totalXpFromAchievements,
      lastUpdatedTimestamp: lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
    );
  }
}
