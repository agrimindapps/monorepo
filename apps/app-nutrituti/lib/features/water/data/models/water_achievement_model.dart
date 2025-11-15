import '../../domain/entities/water_achievement.dart';

/// Data model for water achievements with persistence support
/// Extends pure domain entity with serialization capabilities
class WaterAchievementModel extends WaterAchievement {
  @override
  final String id;

  @override
  final AchievementType type;

  @override
  final String title;

  @override
  final String description;

  @override
  final DateTime unlockedAt;

  @override
  final String? iconName;

  const WaterAchievementModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.unlockedAt,
    this.iconName,
  }) : super(
         id: id,
         type: type,
         title: title,
         description: description,
         unlockedAt: unlockedAt,
         iconName: iconName,
       );

  /// Create model from domain entity
  factory WaterAchievementModel.fromEntity(WaterAchievement entity) {
    return WaterAchievementModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      description: entity.description,
      unlockedAt: entity.unlockedAt,
      iconName: entity.iconName,
    );
  }

  /// Convert model to domain entity
  WaterAchievement toEntity() {
    return WaterAchievement(
      id: id,
      type: type,
      title: title,
      description: description,
      unlockedAt: unlockedAt,
      iconName: iconName,
    );
  }

  /// Serialize to Firebase Firestore map
  Map<String, dynamic> toFirebaseMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt.toIso8601String(),
      'iconName': iconName,
    };
  }

  /// Deserialize from Firebase Firestore map
  factory WaterAchievementModel.fromFirebaseMap(Map<String, dynamic> map) {
    return WaterAchievementModel(
      id: map['id'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.firstRecord,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      unlockedAt: DateTime.parse(map['unlockedAt'] as String),
      iconName: map['iconName'] as String?,
    );
  }

  /// Deserialize from map (for manual operations)
  factory WaterAchievementModel.fromMap(Map<dynamic, dynamic> map) {
    return WaterAchievementModel(
      id: map['id'] as String,
      type: map['type'] as AchievementType,
      title: map['title'] as String,
      description: map['description'] as String,
      unlockedAt: map['unlockedAt'] as DateTime,
      iconName: map['iconName'] as String?,
    );
  }

  @override
  WaterAchievementModel copyWith({
    String? id,
    AchievementType? type,
    String? title,
    String? description,
    DateTime? unlockedAt,
    String? iconName,
  }) {
    return WaterAchievementModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      iconName: iconName ?? this.iconName,
    );
  }
}
