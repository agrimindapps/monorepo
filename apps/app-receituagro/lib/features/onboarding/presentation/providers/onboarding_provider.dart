import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_receituagro/core/providers/core_providers.dart';
import 'package:app_receituagro/core/providers/domain_providers.dart'
    as domain_providers;
import 'package:core/core.dart' hide Column;

import '../../../analytics/analytics_providers.dart';
import '../../data/datasources/datasources.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/domain.dart';
import '../services/onboarding_error_message_service.dart';
import '../services/onboarding_ui_service.dart';

part 'onboarding_provider.g.dart';

// ==================== Data Source Providers ====================

/// Provides [OnboardingLocalDataSource] instance
@riverpod
OnboardingLocalDataSource onboardingLocalDataSource(
    Ref ref) {
  final localStorage = ref.watch(localStorageRepositoryProvider);
  return OnboardingLocalDataSource(localStorage);
}

/// Provides [OnboardingConfigDataSource] instance
@riverpod
OnboardingConfigDataSource onboardingConfigDataSource(
    Ref ref) {
  return OnboardingConfigDataSource();
}

// ==================== Repository Providers ====================

/// Provides [IOnboardingRepository] instance
@riverpod
IOnboardingRepository onboardingRepository(Ref ref) {
  final localDataSource = ref.watch(onboardingLocalDataSourceProvider);
  final configDataSource = ref.watch(onboardingConfigDataSourceProvider);
  return OnboardingRepositoryImpl(localDataSource, configDataSource);
}

// ==================== Use Case Providers (Dependency Injection) ====================

/// Provides [StartOnboardingUseCase] instance
@riverpod
StartOnboardingUseCase startOnboardingUseCase(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final analytics = ref.watch(analyticsRepositoryProvider);
  return StartOnboardingUseCase(repository, analytics);
}

/// Provides [CompleteStepUseCase] instance
@riverpod
CompleteStepUseCase completeStepUseCase(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final analytics = ref.watch(analyticsRepositoryProvider);
  return CompleteStepUseCase(repository, analytics);
}

/// Provides [SkipStepUseCase] instance
@riverpod
SkipStepUseCase skipStepUseCase(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final analytics = ref.watch(analyticsRepositoryProvider);
  final completeStepUseCase = ref.watch(completeStepUseCaseProvider);
  return SkipStepUseCase(repository, analytics, completeStepUseCase);
}

/// Provides [GetOnboardingProgressUseCase] instance
@riverpod
GetOnboardingProgressUseCase getOnboardingProgressUseCase(
  Ref ref,
) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return GetOnboardingProgressUseCase(repository);
}

/// Provides [ShowFeatureTooltipUseCase] instance
@riverpod
ShowFeatureTooltipUseCase showFeatureTooltipUseCase(
  Ref ref,
) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final analytics = ref.watch(analyticsRepositoryProvider);
  return ShowFeatureTooltipUseCase(repository, analytics);
}

/// Provides [ResetOnboardingUseCase] instance
@riverpod
ResetOnboardingUseCase resetOnboardingUseCase(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final analytics = ref.watch(analyticsRepositoryProvider);
  return ResetOnboardingUseCase(repository, analytics);
}

// ==================== UI Services ====================

/// Provides [OnboardingUIService] instance
@riverpod
OnboardingUIService onboardingUIService(Ref ref) {
  return OnboardingUIService();
}

/// Provides [OnboardingErrorMessageService] instance
@riverpod
OnboardingErrorMessageService onboardingErrorMessageService(
    Ref ref) {
  return OnboardingErrorMessageService();
}

/// Provides list of all onboarding steps configuration
@riverpod
List<OnboardingStep> onboardingSteps(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final result = repository.getOnboardingSteps();

  return result.fold((failure) => <OnboardingStep>[], (steps) => steps);
}

/// Provides list of all feature discovery tooltips
@riverpod
List<FeatureTooltip> featureTooltips(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  final result = repository.getFeatureTooltips();

  return result.fold((failure) => <FeatureTooltip>[], (tooltips) => tooltips);
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

    return result.fold((failure) => null, (progress) => progress);
  }

  /// Start onboarding flow
  /// Creates initial progress state and saves to storage
  Future<void> start() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(startOnboardingUseCaseProvider);
      final result = await useCase.call(const NoParams());

      return result.fold((failure) {
        final messageService =
            ref.watch(domain_providers.failureMessageServiceProvider);
        throw Exception(messageService.mapFailureToMessage(failure));
      }, (progress) => progress);
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
        CompleteStepParams(stepId: stepId, currentProgress: currentProgress),
      );

      return result.fold((failure) {
        final messageService =
            ref.watch(domain_providers.failureMessageServiceProvider);
        throw Exception(messageService.mapFailureToMessage(failure));
      }, (updatedProgress) => updatedProgress);
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
        SkipStepParams(stepId: stepId, currentProgress: currentProgress),
      );

      return result.fold((failure) {
        final messageService =
            ref.watch(domain_providers.failureMessageServiceProvider);
        throw Exception(messageService.mapFailureToMessage(failure));
      }, (updatedProgress) => updatedProgress);
    });
  }

  /// Reset onboarding (for testing/debug only)
  Future<void> reset() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(resetOnboardingUseCaseProvider);
      final result = await useCase.call(const NoParams());

      return result.fold((failure) {
        final messageService =
            ref.watch(domain_providers.failureMessageServiceProvider);
        throw Exception(messageService.mapFailureToMessage(failure));
      }, (_) => null);
    });
  }
}

// ==================== Derived Providers ====================

/// Completion percentage (0-100)
/// Calculated from current progress and required steps
@riverpod
double completionPercentage(Ref ref) {
  final progressAsync = ref.watch(onboardingProvider);
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
bool isOnboardingCompleted(Ref ref) {
  final progressAsync = ref.watch(onboardingProvider);

  return progressAsync.when(
    data: (progress) => progress?.isCompleted ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Get current step (for navigation/display)
@riverpod
OnboardingStep? currentStep(Ref ref) {
  final progressAsync = ref.watch(onboardingProvider);
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
int currentStepIndex(Ref ref) {
  final current = ref.watch(currentStepProvider);
  final steps = ref.watch(onboardingStepsProvider);

  if (current == null) return 0;
  return steps.indexOf(current);
}
