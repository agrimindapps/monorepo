import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// Service responsible for validating authentication-related data
///
/// Following Single Responsibility Principle (SRP):
/// - Centralizes all validation logic for auth operations
/// - Prevents validation duplication across notifiers
/// - Provides consistent validation rules across the feature
@lazySingleton
class AuthValidationService {
  /// Validates email format
  ///
  /// Returns [Left] with error message if invalid
  /// Returns [Right] with Unit if valid
  Either<String, Unit> validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return const Left('Email é obrigatório');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return const Left('Email inválido');
    }
    return const Right(unit);
  }

  /// Validates password strength
  ///
  /// Returns [Left] with error message if invalid
  /// Returns [Right] with Unit if valid
  Either<String, Unit> validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return const Left('Senha é obrigatória');
    }
    if (password.length < 6) {
      return const Left('Senha deve ter pelo menos 6 caracteres');
    }
    return const Right(unit);
  }

  /// Validates user name
  ///
  /// Returns [Left] with error message if invalid
  /// Returns [Right] with Unit if valid
  Either<String, Unit> validateName(String? name) {
    if (name == null || name.isEmpty) {
      return const Left('Nome é obrigatório');
    }
    if (name.length < 2) {
      return const Left('Nome deve ter pelo menos 2 caracteres');
    }
    return const Right(unit);
  }

  /// Validates password confirmation
  ///
  /// Returns [Left] with error message if invalid
  /// Returns [Right] with Unit if valid
  Either<String, Unit> validateConfirmPassword(
    String? confirmPassword,
    String originalPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return const Left('Confirmação de senha é obrigatória');
    }
    if (confirmPassword != originalPassword) {
      return const Left('Senhas não coincidem');
    }
    return const Right(unit);
  }

  /// Validates login form data
  ///
  /// Returns [Left] with error message if any validation fails
  /// Returns [Right] with Unit if all validations pass
  Either<String, Unit> validateLoginForm({
    required String email,
    required String password,
  }) {
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return emailValidation;
    }

    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return passwordValidation;
    }

    return const Right(unit);
  }

  /// Validates signup form data
  ///
  /// Returns [Left] with error message if any validation fails
  /// Returns [Right] with Unit if all validations pass
  Either<String, Unit> validateSignupForm({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
  }) {
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return emailValidation;
    }

    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return passwordValidation;
    }

    final nameValidation = validateName(name);
    if (nameValidation.isLeft()) {
      return nameValidation;
    }

    final confirmPasswordValidation = validateConfirmPassword(
      confirmPassword,
      password,
    );
    if (confirmPasswordValidation.isLeft()) {
      return confirmPasswordValidation;
    }

    return const Right(unit);
  }
}
