/// Centralized input validators for Plantis
/// Provides consistent validation across all forms
class Validators {
  Validators._(); // Private constructor to prevent instantiation

  // ========== TEXT VALIDATORS ==========

  /// Validates that a field is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} é obrigatório';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null; // Use with required() for mandatory fields

    if (value.length < min) {
      return '${fieldName ?? 'Este campo'} deve ter no mínimo $min caracteres';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return '${fieldName ?? 'Este campo'} deve ter no máximo $max caracteres';
    }
    return null;
  }

  /// Validates length range
  static String? lengthRange(String? value, int min, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min || value.length > max) {
      return '${fieldName ?? 'Este campo'} deve ter entre $min e $max caracteres';
    }
    return null;
  }

  // ========== PLANT-SPECIFIC VALIDATORS ==========

  /// Validates plant name
  static String? plantName(String? value) {
    // Required
    final requiredError = required(value, fieldName: 'Nome da planta');
    if (requiredError != null) return requiredError;

    // Length: 1-100 characters
    final lengthError = lengthRange(value, 1, 100, fieldName: 'Nome da planta');
    if (lengthError != null) return lengthError;

    // No special characters that could break database
    if (value!.contains(RegExp(r'[<>{}[\]\\]'))) {
      return 'Nome não pode conter caracteres especiais: < > { } [ ] \\';
    }

    return null;
  }

  /// Validates plant species (optional field)
  static String? plantSpecies(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    // Max length: 150 characters
    return maxLength(value, 150, fieldName: 'Espécie');
  }

  /// Validates plant location/space
  static String? plantLocation(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    return maxLength(value, 100, fieldName: 'Localização');
  }

  /// Validates plant notes
  static String? plantNotes(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    return maxLength(value, 1000, fieldName: 'Notas');
  }

  // ========== NUMERIC VALIDATORS ==========

  /// Validates that value is a positive integer
  static String? positiveInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null; // Use with required() for mandatory fields

    final parsed = int.tryParse(value);
    if (parsed == null) {
      return '${fieldName ?? 'Este campo'} deve ser um número inteiro';
    }

    if (parsed <= 0) {
      return '${fieldName ?? 'Este campo'} deve ser maior que zero';
    }

    return null;
  }

  /// Validates that value is a non-negative integer (0 or positive)
  static String? nonNegativeInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final parsed = int.tryParse(value);
    if (parsed == null) {
      return '${fieldName ?? 'Este campo'} deve ser um número inteiro';
    }

    if (parsed < 0) {
      return '${fieldName ?? 'Este campo'} não pode ser negativo';
    }

    return null;
  }

  /// Validates integer range
  static String? integerRange(String? value, int min, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final parsed = int.tryParse(value);
    if (parsed == null) {
      return '${fieldName ?? 'Este campo'} deve ser um número inteiro';
    }

    if (parsed < min || parsed > max) {
      return '${fieldName ?? 'Este campo'} deve estar entre $min e $max';
    }

    return null;
  }

  /// Validates watering interval (days)
  static String? wateringInterval(String? value) {
    if (value == null || value.isEmpty) return null; // Optional

    final rangeError = integerRange(value, 1, 365, fieldName: 'Intervalo de rega');
    if (rangeError != null) return rangeError;

    return null;
  }

  /// Validates fertilizing interval (days)
  static String? fertilizingInterval(String? value) {
    if (value == null || value.isEmpty) return null; // Optional

    final rangeError = integerRange(value, 1, 365, fieldName: 'Intervalo de adubação');
    if (rangeError != null) return rangeError;

    return null;
  }

  // ========== EMAIL VALIDATORS ==========

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null; // Use with required() for mandatory fields

    // Basic email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  // ========== PASSWORD VALIDATORS ==========

  /// Validates password strength
  static String? password(String? value) {
    // Required
    final requiredError = required(value, fieldName: 'Senha');
    if (requiredError != null) return requiredError;

    // Minimum 6 characters (Firebase minimum)
    if (value!.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }

    return null;
  }

  /// Validates password confirmation matches
  static String? passwordConfirmation(String? value, String? originalPassword) {
    // Required
    final requiredError = required(value, fieldName: 'Confirmação de senha');
    if (requiredError != null) return requiredError;

    if (value != originalPassword) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  // ========== TASK VALIDATORS ==========

  /// Validates task title
  static String? taskTitle(String? value) {
    // Required
    final requiredError = required(value, fieldName: 'Título da tarefa');
    if (requiredError != null) return requiredError;

    // Length: 1-200 characters
    return lengthRange(value, 1, 200, fieldName: 'Título da tarefa');
  }

  /// Validates task description
  static String? taskDescription(String? value) {
    if (value == null || value.isEmpty) return null; // Optional field

    return maxLength(value, 1000, fieldName: 'Descrição da tarefa');
  }

  // ========== COMPOSITE VALIDATORS ==========

  /// Combines multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  // ========== CONDITIONAL VALIDATORS ==========

  /// Validates only if condition is true
  static String? Function(String?) when(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (!condition) return null;
      return validator(value);
    };
  }
}
