import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/interfaces/usecase.dart';
import '../repositories/promo_repository.dart';
import '../services/promo_validation_service.dart';

/// Use case for submitting pre-registration email
///
/// **SOLID Principles Applied:**
/// - **Single Responsibility**: Only handles pre-registration submission flow
/// - **Dependency Inversion**: Depends on abstractions (repository, validation service)
///
/// **Dependencies:**
/// - PromoRepository: For data submission
/// - PromoValidationService: For email validation
class SubmitPreRegistration implements UseCase<void, String> {
  final PromoRepository _repository;
  final PromoValidationService _validationService;

  SubmitPreRegistration(this._repository, this._validationService);

  @override
  Future<Either<Failure, void>> call(String email) async {
    // Validate email
    final validationResult = _validationService.validateEmail(email);

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Validation should not return Right'),
      );
    }

    // Submit pre-registration
    return await _repository.submitPreRegistration(email);
  }
}
