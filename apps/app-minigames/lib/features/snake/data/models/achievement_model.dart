// Dart imports:
import 'dart:convert';

// Domain imports:
import '../../domain/entities/achievement.dart';

/// Data model for achievement persistence
class AchievementModel {
  final String id;
  final int currentProgress;
  final bool isUnlocked;
  final int? unlockedAtTimestamp;

  const AchievementModel({
    required this.id,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAtTimestamp,
  });

  /// Create from entity
  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      currentProgress: entity.currentProgress,
      isUnlocked: entity.isUnlocked,
      unlockedAtTimestamp: entity.unlockedAt?.millisecondsSinceEpoch,
    );
  }

  /// Convert to entity
  Achievement toEntity() {
    return Achievement(
      id: id,
      currentProgress: currentProgress,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAtTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(unlockedAtTimestamp!)
          : null,
    );
  }

  /// Create from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
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

  AchievementModel copyWith({
    String? id,
    int? currentProgress,
    bool? isUnlocked,
    int? unlockedAtTimestamp,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAtTimestamp: unlockedAtTimestamp ?? this.unlockedAtTimestamp,
    );
  }
}

/// Data model for all achievements persistence
class AchievementsDataModel {
  final List<AchievementModel> achievements;
  final int totalXpFromAchievements;
  final int lastUpdatedTimestamp;

  const AchievementsDataModel({
    required this.achievements,
    this.totalXpFromAchievements = 0,
    required this.lastUpdatedTimestamp,
  });

  /// Create empty model
  factory AchievementsDataModel.empty() {
    return AchievementsDataModel(
      achievements: const [],
      totalXpFromAchievements: 0,
      lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Create from list of entities
  factory AchievementsDataModel.fromEntities(List<Achievement> entities) {
    final models = entities.map(AchievementModel.fromEntity).toList();
    final totalXp = entities
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.definition.rarity.xpReward);

    return AchievementsDataModel(
      achievements: models,
      totalXpFromAchievements: totalXp,
      lastUpdatedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to list of entities
  List<Achievement> toEntities() {
    return achievements.map((m) => m.toEntity()).toList();
  }

  /// Create from JSON
  factory AchievementsDataModel.fromJson(Map<String, dynamic> json) {
    final achievementsList = (json['achievements'] as List<dynamic>?)
            ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AchievementsDataModel(
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
  factory AchievementsDataModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return AchievementsDataModel.fromJson(json);
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
  int get totalCount => AchievementDefinitions.totalCount;

  /// Get completion percentage
  double get completionPercent {
    if (totalCount == 0) return 0.0;
    return unlockedCount / totalCount;
  }

  /// Get completion percentage as int
  int get completionPercentInt => (completionPercent * 100).round();

  AchievementsDataModel copyWith({
    List<AchievementModel>? achievements,
    int? totalXpFromAchievements,
    int? lastUpdatedTimestamp,
  }) {
    return AchievementsDataModel(
      achievements: achievements ?? this.achievements,
      totalXpFromAchievements:
          totalXpFromAchievements ?? this.totalXpFromAchievements,
      lastUpdatedTimestamp:
          lastUpdatedTimestamp ?? this.lastUpdatedTimestamp,
    );
  }
}
