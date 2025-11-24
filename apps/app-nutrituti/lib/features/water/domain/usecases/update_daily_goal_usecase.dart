import 'package:app_nutrituti/core/error/failures.dart';
import 'package:app_nutrituti/features/water/domain/repositories/water_repository.dart';
import 'package:dartz/dartz.dart';

/// Parameters for updating daily water goal
class UpdateDailyGoalParams {
  final int goalAmount; // ml

  const UpdateDailyGoalParams({
    required this.goalAmount,
  });
}

/// Use case for updating the daily water intake goal
/// Implements validation and business rules
class UpdateDailyGoalUseCase {
  final WaterRepository _repository;

  const UpdateDailyGoalUseCase(this._repository);

  /// Execute the use case
  /// Returns Either Failure or int - the new goal amount
  Future<Either<Failure, int>> call(UpdateDailyGoalParams params) async {
    // Validation: Goal must be positive
    if (params.goalAmount <= 0) {
      return const Left(
        ValidationFailure('Meta diária deve ser maior que zero'),
      );
    }

    // Validation: Minimum recommended goal (500ml)
    if (params.goalAmount < 500) {
      return const Left(
        ValidationFailure('Meta diária mínima recomendada é 500ml'),
      );
    }

    // Validation: Maximum reasonable goal (10L = 10000ml)
    // Prevents accidental data entry errors
    if (params.goalAmount > 10000) {
      return const Left(
        ValidationFailure('Meta diária máxima é 10000ml (10L)'),
      );
    }

    // Validation: Goal should be in reasonable increments (multiple of 50ml)
    // Helps maintain consistency and reasonable values
    if (params.goalAmount % 50 != 0) {
      return const Left(
        ValidationFailure('Meta diária deve ser múltiplo de 50ml'),
      );
    }

    // Delegate to repository
    return await _repository.updateDailyGoal(params.goalAmount);
  }

  /// Helper method to suggest goal based on weight (optional)
  /// Common recommendation: 35ml per kg of body weight
  static int suggestGoalFromWeight(double weightKg) {
    final suggested = (weightKg * 35).round();

    // Round to nearest 250ml
    final rounded = (suggested / 250).round() * 250;

    // Clamp between min and max
    return rounded.clamp(500, 10000);
  }

  /// Helper method to suggest goal based on activity level
  static int suggestGoalFromActivity({
    required double weightKg,
    required ActivityLevel activityLevel,
  }) {
    final baseGoal = suggestGoalFromWeight(weightKg);

    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return baseGoal;
      case ActivityLevel.light:
        return ((baseGoal * 1.1).round() / 250).round() * 250;
      case ActivityLevel.moderate:
        return ((baseGoal * 1.25).round() / 250).round() * 250;
      case ActivityLevel.active:
        return ((baseGoal * 1.4).round() / 250).round() * 250;
      case ActivityLevel.veryActive:
        return ((baseGoal * 1.6).round() / 250).round() * 250;
    }
  }
}

/// Activity levels for goal calculation
enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive,
}
