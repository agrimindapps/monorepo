/// Immutable entity representing user onboarding progress
class OnboardingProgress {
  final Map<String, bool> completedSteps;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String currentStep;
  final bool isCompleted;

  const OnboardingProgress({
    required this.completedSteps,
    this.startedAt,
    this.completedAt,
    required this.currentStep,
    required this.isCompleted,
  });

  /// Create a copy with optional field updates
  OnboardingProgress copyWith({
    Map<String, bool>? completedSteps,
    DateTime? startedAt,
    DateTime? completedAt,
    String? currentStep,
    bool? isCompleted,
  }) {
    return OnboardingProgress(
      completedSteps: completedSteps ?? this.completedSteps,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingProgress &&
          runtimeType == other.runtimeType &&
          completedSteps == other.completedSteps &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          currentStep == other.currentStep &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      completedSteps.hashCode ^
      startedAt.hashCode ^
      completedAt.hashCode ^
      currentStep.hashCode ^
      isCompleted.hashCode;

  @override
  String toString() =>
      'OnboardingProgress(currentStep: $currentStep, isCompleted: $isCompleted, completedSteps: ${completedSteps.length})';
}
