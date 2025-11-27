import 'dart:convert';

// Domain imports:
import '../../domain/entities/player_level.dart';

/// Model for PlayerLevel (extends entity, adds JSON serialization)
class PlayerLevelModel extends PlayerLevel {
  const PlayerLevelModel({super.totalXp});

  /// Create from JSON
  factory PlayerLevelModel.fromJson(Map<String, dynamic> json) {
    return PlayerLevelModel(
      totalXp: json['totalXp'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
    };
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory PlayerLevelModel.fromJsonString(String jsonString) {
    return PlayerLevelModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  /// Create from entity
  factory PlayerLevelModel.fromEntity(PlayerLevel entity) {
    return PlayerLevelModel(totalXp: entity.totalXp);
  }

  /// Empty level
  factory PlayerLevelModel.empty() => const PlayerLevelModel();
}
