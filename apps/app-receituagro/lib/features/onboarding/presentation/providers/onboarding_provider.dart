import 'package:app_receituagro/core/di/injection.dart' as di;
import 'package:core/core.dart';

import '../../domain/domain.dart';

part 'onboarding_provider.g.dart';

// ==================== Use Case Providers (Dependency Injection) ====================

/// Provides [StartOnboardingUseCase] instance
@riverpod
StartOnboardingUseCase startOnboardingUseCase(
  StartOnboardingUseCaseRef ref,
) {
  return di.getIt<StartOnboardingUseCase>();
}

/// Provides [CompleteStepUseCase] instance
@riverpod
CompleteStepUseCase completeStepUseCase(
  CompleteStepUseCaseRef ref,
) {
  return di.getIt<CompleteStepUseCase>();
}

/// Provides [SkipStepUseCase] instance
@riverpod
SkipStepUseCase skipStepUseCase(SkipStepUseCaseRef ref) {
  return di.getIt<SkipStepUseCase>();
}

/// Provides [GetOnboardingProgressUseCase] instance
@riverpod
GetOnboardingProgressUseCase getOnboardingProgressUseCase(
  GetOnboardingProgressUseCaseRef ref,
) {
  return di.getIt<GetOnboardingProgressUseCase>();
}

/// Provides [ShowFeatureTooltipUseCase] instance
@riverpod
ShowFeatureTooltipUseCase showFeatureTooltipUseCase(
  ShowFeatureTooltipUseCaseRef ref,
) {
  return di.getIt<ShowFeatureTooltipUseCase>();
}

/// Provides [ResetOnboardingUseCase] instance
@riverpod
ResetOnboardingUseCase resetOnboardingUseCase(
  ResetOnboardingUseCaseRef ref,
) {
  return di.getIt<ResetOnboardingUseCase>();
}

// ==================== Configuration Providers ====================

/// Provides list of all onboarding steps configuration
@riverpod
List<OnboardingStep> onboardingSteps(OnboardingStepsRef ref) {
  final repository = di.getIt<IOnboardingRepository>();
  final result = repository.getOnboardingSteps();

  return result.fold(
    (failure) => [],
    (steps) => steps,
  );
}

/// Provides list of all feature discovery tooltips
@riverpod
List<FeatureTooltip> featureTooltips(FeatureTooltipsRef ref) {
  final repository = di.getIt<IOnboardingRepository>();
  final result = repository.getFeatureTooltips();

  return result.fold(
    (failure) => [],
    (tooltips) => tooltips,
  );
}

// ==================== Main State Notifier ====================

/// State notifier for onboarding flow management
///
/// Handles:
/// - Initial progress loading
/// - Step completion with validation
/// - Step skipping (optional steps only)
/// - Completion status tracking
/// - Failure handling
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<OnboardingProgress?> build() async {
    // Load current onboarding progress on initialization
    final useCase = ref.read(getOnboardingProgressUseCaseProvider);
    final result = await useCase.call(const NoParams());

    return result.fold(
      (failure) => null,
      (progress) => progress,
    );
  }

  /// Start onboarding flow
  /// Creates initial progress state and saves to storage
  Future<void> start() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(startOnboardingUseCaseProvider);
      final result = await useCase.call(const NoParams());

      return result.fold(
        (failure) => throw Exception(failure.message),
        (progress) => progress,
      );
    });
  }

  /// Complete a step with validation
  /// - Validates step exists
  /// - Checks dependencies are completed
  /// - Updates progress
  /// - Checks if onboarding is complete
  /// - Persists to storage
  Future<void> completeStep(String stepId) async {
    final currentProgress = state.value;
    if (currentProgress == null) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(completeStepUseCaseProvider);
      final result = await useCase.call(
        CompleteStepParams(
          stepId: stepId,
          currentProgress: currentProgress,
        ),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedProgress) => updatedProgress,
      );
    });
  }

  /// Skip a step (only for optional steps)
  /// - Validates step is optional
  /// - Marks as completed (same as completeStep)
  /// - Logs skip event
  Future<void> skipStep(String stepId) async {
    final currentProgress = state.value;
    if (currentProgress == null) return;

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(skipStepUseCaseProvider);
      final result = await useCase.call(
        SkipStepParams(
          stepId: stepId,
          currentProgress: currentProgress,
        ),
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (updatedProgress) => updatedProgress,
      );
    });
  }

  /// Reset onboarding (for testing/debug only)
  Future<void> reset() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(resetOnboardingUseCaseProvider);
      final result = await useCase.call(const NoParams());

      return result.fold(
        (failure) => throw Exception(failure.message),
        (_) => null,
      );
    });
  }
}

// ==================== Derived Providers ====================

/// Completion percentage (0-100)
/// Calculated from current progress and required steps
@riverpod
double completionPercentage(CompletionPercentageRef ref) {
  final progressAsync = ref.watch(onboardingNotifierProvider);
  final steps = ref.watch(onboardingStepsProvider);

  return progressAsync.when(
    data: (progress) {
      if (progress == null) return 0.0;
      final requiredSteps = steps.where((s) => s.isRequired).length;
      if (requiredSteps == 0) return 0.0;

      final completedCount = progress.completedSteps.values
          .where((isCompleted) => isCompleted)
          .length;

      return (completedCount / requiredSteps * 100).clamp(0.0, 100.0);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
}

/// Check if onboarding is completed
@riverpod
bool isOnboardingCompleted(IsOnboardingCompletedRef ref) {
  final progressAsync = ref.watch(onboardingNotifierProvider);

  return progressAsync.when(
    data: (progress) => progress?.isCompleted ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Get current step (for navigation/display)
@riverpod
OnboardingStep? currentStep(CurrentStepRef ref) {
  final progressAsync = ref.watch(onboardingNotifierProvider);
  final steps = ref.watch(onboardingStepsProvider);

  return progressAsync.when(
    data: (progress) {
      if (progress == null || progress.currentStep.isEmpty) return null;
      try {
        return steps.firstWhere((s) => s.id == progress.currentStep);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Get current step index for UI display
@riverpod
int currentStepIndex(CurrentStepIndexRef ref) {
  final current = ref.watch(currentStepProvider);
  final steps = ref.watch(onboardingStepsProvider);

  if (current == null) return 0;
  return steps.indexOf(current);
}
