import '../../domain/entities/entities.dart';

/// Model for [OnboardingProgress] with JSON serialization
/// Extends entity with serialization logic (toJson/fromJson)
class OnboardingProgressModel extends OnboardingProgress {
  const OnboardingProgressModel({
    required super.completedSteps,
    super.startedAt,
    super.completedAt,
    required super.currentStep,
    required super.isCompleted,
  });

  /// Create model from JSON (from storage/network)
  factory OnboardingProgressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OnboardingProgressModel(
      completedSteps:
          ((json['completed_steps'] as Map<String, dynamic>?) ?? {})
              .cast<String, bool>(),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      currentStep: (json['current_step'] as String?) ?? '',
      isCompleted: (json['is_completed'] as bool?) ?? false,
    );
  }

  /// Convert model to JSON (for storage/network)
  Map<String, dynamic> toJson() => {
        'completed_steps': completedSteps,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'current_step': currentStep,
        'is_completed': isCompleted,
      };

  /// Convert model to domain entity
  OnboardingProgress toEntity() => OnboardingProgress(
        completedSteps: completedSteps,
        startedAt: startedAt,
        completedAt: completedAt,
        currentStep: currentStep,
        isCompleted: isCompleted,
      );

  /// Create model from domain entity
  factory OnboardingProgressModel.fromEntity(
    OnboardingProgress entity,
  ) {
    return OnboardingProgressModel(
      completedSteps: entity.completedSteps,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      currentStep: entity.currentStep,
      isCompleted: entity.isCompleted,
    );
  }
}
