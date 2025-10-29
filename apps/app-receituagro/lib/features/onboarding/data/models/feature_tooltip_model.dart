import '../../domain/entities/entities.dart';

/// Model for [FeatureTooltip] with JSON serialization
/// Extends entity with serialization logic (toJson/fromJson)
class FeatureTooltipModel extends FeatureTooltip {
  const FeatureTooltipModel({
    required super.id,
    required super.title,
    required super.description,
    required super.targetWidget,
    super.config = const {},
    super.priority = 1,
    super.triggers = const [],
  });

  /// Create model from JSON (from storage/network)
  factory FeatureTooltipModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeatureTooltipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetWidget: json['target_widget'] as String,
      config: (json['config'] as Map<String, dynamic>?) ?? {},
      priority: (json['priority'] as int?) ?? 1,
      triggers:
          ((json['triggers'] as List<dynamic>?) ?? [])
              .cast<String>(),
    );
  }

  /// Convert model to JSON (for storage/network)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'target_widget': targetWidget,
        'config': config,
        'priority': priority,
        'triggers': triggers,
      };

  /// Convert model to domain entity
  FeatureTooltip toEntity() => FeatureTooltip(
        id: id,
        title: title,
        description: description,
        targetWidget: targetWidget,
        config: config,
        priority: priority,
        triggers: triggers,
      );

  /// Create model from domain entity
  factory FeatureTooltipModel.fromEntity(
    FeatureTooltip entity,
  ) {
    return FeatureTooltipModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      targetWidget: entity.targetWidget,
      config: entity.config,
      priority: entity.priority,
      triggers: entity.triggers,
    );
  }
}
