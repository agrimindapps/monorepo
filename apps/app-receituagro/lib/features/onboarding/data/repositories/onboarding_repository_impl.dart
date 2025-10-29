import 'package:core/core.dart';

import '../../domain/domain.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Implementation of [IOnboardingRepository] using local and config datasources
///
/// Combines:
/// - [OnboardingLocalDataSource]: Persistent storage operations (Hive/LocalStorage)
/// - [OnboardingConfigDataSource]: Static configuration (hardcoded steps/tooltips)
///
/// All repository operations return [Either]<[Failure], T> for type-safe error handling.
/// Failures are wrapped as:
/// - [UnexpectedFailure]: Unexpected runtime errors
/// - [CacheFailure]: LocalStorage failures
class OnboardingRepositoryImpl implements IOnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;
  final OnboardingConfigDataSource _configDataSource;

  OnboardingRepositoryImpl(
    this._localDataSource,
    this._configDataSource,
  );

  // ==================== Configuration Methods ====================

  @override
  Either<Failure, List<OnboardingStep>> getOnboardingSteps() {
    try {
      final models = _configDataSource.getSteps();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to get onboarding steps: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Either<Failure, List<FeatureTooltip>> getFeatureTooltips() {
    try {
      final models = _configDataSource.getTooltips();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          'Failed to get feature tooltips: ${e.toString()}',
        ),
      );
    }
  }

  // ==================== Progress Management ====================

  @override
  Future<Either<Failure, OnboardingProgress?>> getProgress() async {
    try {
      final model = await _localDataSource.getProgress();
      final entity = model?.toEntity();
      return Right(entity);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to get progress: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(
    OnboardingProgress progress,
  ) async {
    try {
      final model = OnboardingProgressModel.fromEntity(progress);
      await _localDataSource.saveProgress(model);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to save progress: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetProgress() async {
    try {
      await _localDataSource.deleteProgress();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to reset progress: ${e.toString()}',
        ),
      );
    }
  }

  // ==================== Tooltip State Management ====================

  @override
  Future<Either<Failure, Set<String>>> getShownTooltips() async {
    try {
      final tooltips = await _localDataSource.getShownTooltips();
      return Right(tooltips);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to get shown tooltips: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markTooltipShown(
    String tooltipId,
  ) async {
    try {
      await _localDataSource.markTooltipShown(tooltipId);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to mark tooltip shown: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetTooltips() async {
    try {
      await _localDataSource.clearShownTooltips();
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(
          'Failed to reset tooltips: ${e.toString()}',
        ),
      );
    }
  }
}
