import '../../domain/entities/entities.dart';

/// Model for [OnboardingStep] with JSON serialization
/// Extends entity with serialization logic (toJson/fromJson)
class OnboardingStepModel extends OnboardingStep {
  const OnboardingStepModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageAsset,
    super.config = const {},
    super.isRequired = true,
    super.dependencies = const [],
  });

  /// Create model from JSON (from storage/network)
  factory OnboardingStepModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStepModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageAsset: json['image_asset'] as String?,
      config: (json['config'] as Map<String, dynamic>?) ?? {},
      isRequired: (json['is_required'] as bool?) ?? true,
      dependencies:
          ((json['dependencies'] as List<dynamic>?) ?? [])
              .cast<String>(),
    );
  }

  /// Convert model to JSON (for storage/network)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image_asset': imageAsset,
        'config': config,
        'is_required': isRequired,
        'dependencies': dependencies,
      };

  /// Convert model to domain entity
  OnboardingStep toEntity() => OnboardingStep(
        id: id,
        title: title,
        description: description,
        imageAsset: imageAsset,
        config: config,
        isRequired: isRequired,
        dependencies: dependencies,
      );

  /// Create model from domain entity
  factory OnboardingStepModel.fromEntity(
    OnboardingStep entity,
  ) {
    return OnboardingStepModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageAsset: entity.imageAsset,
      config: entity.config,
      isRequired: entity.isRequired,
      dependencies: entity.dependencies,
    );
  }
}
