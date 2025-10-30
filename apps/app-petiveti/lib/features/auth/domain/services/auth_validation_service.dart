import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

/// Service responsible for authentication-related validations
/// Follows Single Responsibility Principle - only handles validation logic
@lazySingleton
class AuthValidationService {
  const AuthValidationService();

  /// Validates email format
  Either<Failure, String> validateEmail(String email) {
    if (email.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Email é obrigatório'));
    }

    if (!_isValidEmail(email)) {
      return const Left(ValidationFailure(message: 'Email inválido'));
    }

    return Right(email.trim());
  }

  /// Validates password requirements
  Either<Failure, String> validatePassword(String password) {
    if (password.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Senha é obrigatória'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Senha deve ter pelo menos 6 caracteres'),
      );
    }

    return Right(password);
  }

  /// Validates name requirements
  Either<Failure, String> validateName(String name) {
    if (name.trim().length < 2) {
      return const Left(
        ValidationFailure(message: 'Nome deve ter pelo menos 2 caracteres'),
      );
    }

    return Right(name.trim());
  }

  /// Validates email and password together for sign in
  Either<Failure, ({String email, String password})> validateSignInCredentials(
    String email,
    String password,
  ) {
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return Left(
        emailValidation.fold(
            (failure) => failure, (_) => throw UnimplementedError()),
      );
    }

    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return Left(
        passwordValidation.fold(
            (failure) => failure, (_) => throw UnimplementedError()),
      );
    }

    return Right((
      email: emailValidation.getOrElse(() => ''),
      password: passwordValidation.getOrElse(() => ''),
    ));
  }

  /// Validates all sign up credentials
  Either<Failure, ({String email, String password, String? name})>
      validateSignUpCredentials(
    String email,
    String password,
    String? name,
  ) {
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return Left(
        emailValidation.fold(
            (failure) => failure, (_) => throw UnimplementedError()),
      );
    }

    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return Left(
        passwordValidation.fold(
            (failure) => failure, (_) => throw UnimplementedError()),
      );
    }

    if (name != null && name.isNotEmpty) {
      final nameValidation = validateName(name);
      if (nameValidation.isLeft()) {
        return Left(
          nameValidation.fold(
              (failure) => failure, (_) => throw UnimplementedError()),
        );
      }
    }

    return Right((
      email: emailValidation.getOrElse(() => ''),
      password: passwordValidation.getOrElse(() => ''),
      name: name?.trim(),
    ));
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
