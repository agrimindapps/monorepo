/// Validation utilities
/// Provides common validation functions for forms and use cases
class Validators {
  Validators._();

  /// Validate required field
  static String? required(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Use required() for this check
    }
    if (value.trim().length < minLength) {
      return '$fieldName deve ter pelo menos $minLength caracteres';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > maxLength) {
      return '$fieldName deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Use required() for this check
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  /// Validate phone number (Brazilian format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Remove non-numeric characters
    final phoneNumber = value.replaceAll(RegExp(r'\D'), '');

    // Brazilian phone: 10 or 11 digits
    if (phoneNumber.length < 10 || phoneNumber.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  /// Validate number
  static String? number(String? value, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return '$fieldName deve ser um número válido';
    }
    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String fieldName = 'Valor'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final num = double.tryParse(value);
    if (num == null) {
      return '$fieldName deve ser um número válido';
    }
    if (num <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    return null;
  }

  /// Validate URL format
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'URL inválida';
    }
    return null;
  }

  /// Validate password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Use required() for this check
    }

    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }

    // Check for at least one letter
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Senha deve conter pelo menos uma letra';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validate if two fields match (e.g., password confirmation)
  static String? match(
    String? value,
    String? compareValue, {
    String fieldName = 'Campo',
  }) {
    if (value != compareValue) {
      return '$fieldName não corresponde';
    }
    return null;
  }
}
