import 'package:core/core.dart';

/// Validador de formulários de autenticação
///
/// Responsabilidade: Validar entradas de formulários (email, senha, etc.)
/// Aplica SRP (Single Responsibility Principle)

class AuthFormValidator {
  /// Valida email
  Either<Failure, Unit> validateEmail(String email) {
    if (email.isEmpty) {
      return const Left(ValidationFailure('Email não pode ser vazio'));
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return const Left(ValidationFailure('Email inválido'));
    }

    return const Right(unit);
  }

  /// Valida senha
  Either<Failure, Unit> validatePassword(String password) {
    if (password.isEmpty) {
      return const Left(ValidationFailure('Senha não pode ser vazia'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure('Senha deve ter pelo menos 6 caracteres'),
      );
    }

    return const Right(unit);
  }

  /// Valida nome de exibição
  Either<Failure, Unit> validateDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return const Left(ValidationFailure('Nome não pode ser vazio'));
    }

    if (displayName.length < 2) {
      return const Left(
        ValidationFailure('Nome deve ter pelo menos 2 caracteres'),
      );
    }

    return const Right(unit);
  }

  /// Valida se duas senhas são iguais
  Either<Failure, Unit> validatePasswordsMatch(
    String password,
    String confirmPassword,
  ) {
    if (password != confirmPassword) {
      return const Left(ValidationFailure('Senhas não coincidem'));
    }

    return const Right(unit);
  }

  /// Valida formulário de login completo
  Either<Failure, Unit> validateLoginForm(String email, String password) {
    // Valida email
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return emailValidation;
    }

    // Valida senha
    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return passwordValidation;
    }

    return const Right(unit);
  }

  /// Valida formulário de registro completo
  Either<Failure, Unit> validateSignUpForm({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) {
    // Valida email
    final emailValidation = validateEmail(email);
    if (emailValidation.isLeft()) {
      return emailValidation;
    }

    // Valida senha
    final passwordValidation = validatePassword(password);
    if (passwordValidation.isLeft()) {
      return passwordValidation;
    }

    // Valida confirmação de senha
    final passwordMatchValidation = validatePasswordsMatch(
      password,
      confirmPassword,
    );
    if (passwordMatchValidation.isLeft()) {
      return passwordMatchValidation;
    }

    // Valida nome de exibição (opcional)
    if (displayName != null && displayName.isNotEmpty) {
      final nameValidation = validateDisplayName(displayName);
      if (nameValidation.isLeft()) {
        return nameValidation;
      }
    }

    return const Right(unit);
  }
}
