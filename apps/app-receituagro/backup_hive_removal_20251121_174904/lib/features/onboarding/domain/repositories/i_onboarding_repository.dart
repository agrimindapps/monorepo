import 'package:core/core.dart' hide Column;

import '../entities/entities.dart';

/// Repository interface for onboarding feature
///
/// Defines contracts for onboarding-related operations including:
/// - Step and tooltip configuration retrieval
/// - Progress management (CRUD)
/// - Tooltip state tracking
///
/// All operations return [Either]<[Failure], T> for type-safe error handling
abstract class IOnboardingRepository {
  // Steps & Configuration

  /// Get all onboarding steps configuration
  Either<Failure, List<OnboardingStep>> getOnboardingSteps();

  /// Get all feature discovery tooltips
  Either<Failure, List<FeatureTooltip>> getFeatureTooltips();

  // Progress Management

  /// Load user's current onboarding progress from persistent storage
  /// Returns null if no progress found (user hasn't started onboarding)
  Future<Either<Failure, OnboardingProgress?>> getProgress();

  /// Save user's onboarding progress to persistent storage
  Future<Either<Failure, void>> saveProgress(OnboardingProgress progress);

  /// Clear onboarding progress (used for testing/reset)
  Future<Either<Failure, void>> resetProgress();

  // Tooltip State

  /// Get set of tooltip IDs that have been shown to the user
  Future<Either<Failure, Set<String>>> getShownTooltips();

  /// Mark a tooltip as shown so it won't appear again
  Future<Either<Failure, void>> markTooltipShown(String tooltipId);

  /// Clear all shown tooltips (used for testing/reset)
  Future<Either<Failure, void>> resetTooltips();
}
