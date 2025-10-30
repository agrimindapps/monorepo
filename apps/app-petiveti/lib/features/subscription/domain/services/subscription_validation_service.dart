import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

/// Service responsible for validating subscription-related data
///
/// Following Single Responsibility Principle (SRP):
/// - Centralizes all validation logic for subscription operations
/// - Prevents validation duplication across use cases
/// - Provides consistent validation rules across the feature
@lazySingleton
class SubscriptionValidationService {
  /// Validates user ID
  ///
  /// Returns [Left] with ValidationFailure if invalid
  /// Returns [Right] with Unit if valid
  Either<Failure, Unit> validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do usuário é obrigatório'),
      );
    }
    return const Right(unit);
  }

  /// Validates plan ID
  ///
  /// Returns [Left] with ValidationFailure if invalid
  /// Returns [Right] with Unit if valid
  Either<Failure, Unit> validatePlanId(String planId) {
    if (planId.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'ID do plano é obrigatório'),
      );
    }
    return const Right(unit);
  }

  /// Validates receipt data
  ///
  /// Returns [Left] with ValidationFailure if invalid
  /// Returns [Right] with Unit if valid
  Either<Failure, Unit> validateReceiptData(String receiptData) {
    if (receiptData.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Dados do recibo são obrigatórios'),
      );
    }
    return const Right(unit);
  }

  /// Validates subscription parameters for subscribing to a plan
  ///
  /// Returns [Left] with ValidationFailure if any validation fails
  /// Returns [Right] with Unit if all validations pass
  Either<Failure, Unit> validateSubscribeToPlanParams({
    required String userId,
    required String planId,
  }) {
    final userIdValidation = validateUserId(userId);
    if (userIdValidation.isLeft()) {
      return userIdValidation;
    }

    final planIdValidation = validatePlanId(planId);
    if (planIdValidation.isLeft()) {
      return planIdValidation;
    }

    return const Right(unit);
  }

  /// Validates subscription parameters for upgrading a plan
  ///
  /// Returns [Left] with ValidationFailure if any validation fails
  /// Returns [Right] with Unit if all validations pass
  Either<Failure, Unit> validateUpgradePlanParams({
    required String userId,
    required String newPlanId,
  }) {
    final userIdValidation = validateUserId(userId);
    if (userIdValidation.isLeft()) {
      return userIdValidation;
    }

    final planIdValidation = validatePlanId(newPlanId);
    if (planIdValidation.isLeft()) {
      return Left(
        ValidationFailure(message: 'ID do novo plano é obrigatório'),
      );
    }

    return const Right(unit);
  }
}
