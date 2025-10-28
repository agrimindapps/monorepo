import '../error/failures.dart';

/// Validation utility class
class Validators {
  /// Validates that a value is not null or empty
  static ValidationFailure? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationFailure('$fieldName é obrigatório');
    }
    return null;
  }

  /// Validates minimum length
  static ValidationFailure? validateMinLength(
    String value,
    int minLength,
    String fieldName,
  ) {
    if (value.trim().length < minLength) {
      return ValidationFailure(
        '$fieldName deve ter pelo menos $minLength caracteres',
      );
    }
    return null;
  }

  /// Validates maximum length
  static ValidationFailure? validateMaxLength(
    String value,
    int maxLength,
    String fieldName,
  ) {
    if (value.trim().length > maxLength) {
      return ValidationFailure(
        '$fieldName deve ter no máximo $maxLength caracteres',
      );
    }
    return null;
  }

  /// Validates email format
  static ValidationFailure? validateEmail(String value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return const ValidationFailure('Email inválido');
    }
    return null;
  }

  /// Validates that a value is numeric
  static ValidationFailure? validateNumeric(String value, String fieldName) {
    if (num.tryParse(value.trim()) == null) {
      return ValidationFailure('$fieldName deve ser um número válido');
    }
    return null;
  }

  /// Validates positive number
  static ValidationFailure? validatePositive(num value, String fieldName) {
    if (value <= 0) {
      return ValidationFailure('$fieldName deve ser maior que zero');
    }
    return null;
  }

  /// Validates value within range
  static ValidationFailure? validateRange(
    num value,
    num min,
    num max,
    String fieldName,
  ) {
    if (value < min || value > max) {
      return ValidationFailure(
        '$fieldName deve estar entre $min e $max',
      );
    }
    return null;
  }

  /// Validates URL format
  static ValidationFailure? validateUrl(String value) {
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.hasScheme || !uri.hasAuthority) {
        return const ValidationFailure('URL inválida');
      }
      return null;
    } catch (_) {
      return const ValidationFailure('URL inválida');
    }
  }

  /// Validates date is not in the future
  static ValidationFailure? validateNotFuture(DateTime date, String fieldName) {
    if (date.isAfter(DateTime.now())) {
      return ValidationFailure('$fieldName não pode ser no futuro');
    }
    return null;
  }

  /// Validates date is not in the past
  static ValidationFailure? validateNotPast(DateTime date, String fieldName) {
    if (date.isBefore(DateTime.now())) {
      return ValidationFailure('$fieldName não pode ser no passado');
    }
    return null;
  }

  /// Combines multiple validation failures
  static ValidationFailure? combineValidations(
    List<ValidationFailure?> validations,
  ) {
    final failures = validations.whereType<ValidationFailure>().toList();
    if (failures.isEmpty) return null;

    final combinedMessage = failures.map((f) => f.message).join('; ');
    return ValidationFailure(combinedMessage);
  }
}
