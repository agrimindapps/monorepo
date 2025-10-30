import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

/// Service responsible for validating promo-related data
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles promo data validation
/// - **Open/Closed**: New validation rules can be added without modifying existing code
/// - **Dependency Inversion**: Use cases depend on this abstraction
///
/// **Features:**
/// - Email validation for pre-registration
/// - Event name validation for analytics
@lazySingleton
class PromoValidationService {
  /// Validates email address for pre-registration
  ///
  /// Returns ValidationFailure if:
  /// - Email is empty or contains only whitespace
  /// - Email format is invalid (no @ or domain)
  ///
  /// Example:
  /// ```dart
  /// validateEmail('user@example.com') // Returns Right(null)
  /// validateEmail('invalid') // Returns Left(ValidationFailure)
  /// ```
  Either<Failure, void> validateEmail(String email) {
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure(message: 'Email inválido'));
    }

    return const Right(null);
  }

  /// Validates analytics event name
  ///
  /// Returns ValidationFailure if:
  /// - Event name is empty or contains only whitespace
  ///
  /// Example:
  /// ```dart
  /// validateEventName('page_view') // Returns Right(null)
  /// validateEventName('') // Returns Left(ValidationFailure)
  /// ```
  Either<Failure, void> validateEventName(String event) {
    if (event.trim().isEmpty) {
      return const Left(
          ValidationFailure(message: 'Nome do evento é obrigatório'));
    }

    return const Right(null);
  }
}
