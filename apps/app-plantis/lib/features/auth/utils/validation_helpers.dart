import 'package:flutter/material.dart';

/// Real-time validation helpers for form fields with enhanced security
class ValidationHelpers {
  /// Validates name field in real-time with enhanced security
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu nome completo';
    }

    final trimmedName = value.trim();

    if (trimmedName.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (trimmedName.length > 100) {
      return 'Nome não pode ter mais de 100 caracteres';
    }
    if (RegExp(r'[<>"\\\n\r\t]').hasMatch(trimmedName)) {
      return 'Nome contém caracteres não permitidos';
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(trimmedName)) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }

  /// Validates email field in real-time with enhanced security
  /// Uses AuthValidators for consistent security standards
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu email';
    }

    final email = value.trim().toLowerCase();
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email)) {
      return 'Por favor, insira um email válido';
    }
    if (email.split('@').length != 2) {
      return 'Email contém formato inválido';
    }
    if (email.contains('..') ||
        email.startsWith('.') ||
        email.endsWith('.') ||
        email.contains('@.') ||
        email.contains('.@')) {
      return 'Email contém caracteres não permitidos';
    }
    if (email.length > 320) {
      return 'Email muito longo';
    }

    return null;
  }

  /// Validates password field in real-time with enhanced security requirements
  /// Consistent with AuthValidators.validatePassword for security uniformity
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }

    if (value.length > 128) {
      return 'Senha muito longa';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'A senha deve conter letras e números';
    }
    final commonWeakPatterns = [
      r'12345',
      r'abcde',
      r'qwert',
      r'password',
      r'senha',
    ];

    for (final pattern in commonWeakPatterns) {
      if (value.toLowerCase().contains(pattern)) {
        return 'Senha muito simples. Evite sequências comuns';
      }
    }

    return null;
  }

  /// Validates password confirmation field in real-time
  static String? validatePasswordConfirmation(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != originalPassword) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  /// Validates phone number field in real-time (Brazilian format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional in most cases
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Número de telefone inválido';
    }
    final areaCode = digits.substring(0, 2);
    final validAreaCodes = [
      '11', '12', '13', '14', '15', '16', '17', '18', '19', // São Paulo
      '21', '22', '24', // Rio de Janeiro
      '27', '28', // Espírito Santo
      '31', '32', '33', '34', '35', '37', '38', // Minas Gerais
      '41', '42', '43', '44', '45', '46', // Paraná
      '47', '48', '49', // Santa Catarina
      '51', '53', '54', '55', // Rio Grande do Sul
      '61', // Distrito Federal
      '62', '64', // Goiás
      '63', // Tocantins
      '65', '66', // Mato Grosso
      '67', // Mato Grosso do Sul
      '68', // Acre
      '69', // Rondônia
      '71', '73', '74', '75', '77', // Bahia
      '79', // Sergipe
      '81', '87', // Pernambuco
      '82', // Alagoas
      '83', // Paraíba
      '84', // Rio Grande do Norte
      '85', '88', // Ceará
      '86', '89', // Piauí
      '91', '93', '94', // Pará
      '92', '97', // Amazonas
      '95', // Roraima
      '96', // Amapá
      '98', '99', // Maranhão
    ];

    if (!validAreaCodes.contains(areaCode)) {
      return 'Código de área inválido';
    }

    return null;
  }

  /// Gets validation status icon for form fields
  static Widget? getValidationIcon(
    String? value,
    String? Function(String?) validator,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final error = validator(value);
    if (error == null) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else {
      return const Icon(Icons.error, color: Colors.red, size: 20);
    }
  }

  /// Formats phone number as user types (Brazilian format)
  static String formatPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length <= 2) {
      return digits;
    } else if (digits.length <= 6) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    } else if (digits.length <= 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    }
  }

  /// Checks if a value meets minimum requirements for real-time feedback
  static bool hasMinimumInput(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Gets color for form field border based on validation state
  static Color getBorderColor(
    String? value,
    String? Function(String?) validator,
  ) {
    if (value == null || value.isEmpty) {
      return Colors.grey.shade400;
    }

    final error = validator(value);
    if (error == null) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  /// Determines if real-time validation should be shown
  static bool shouldShowValidation(String? value, bool hasBeenFocused) {
    return hasBeenFocused && hasMinimumInput(value);
  }

  /// Sanitizes text input to prevent injection attacks
  /// Removes or escapes potentially dangerous characters while preserving spaces
  static String sanitizeTextInput(String input) {
    if (input.isEmpty) return input;
    String sanitized = input
        .replaceAll(
          RegExp(r'[<>"\\]'),
          '',
        ) // Remove HTML/script injection chars
        .replaceAll(RegExp(r'[\n\r\t]'), ' ') // Replace line breaks with spaces
        .replaceAll(RegExp(r' +'), ' '); // Clean up multiple spaces
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500);
    }

    return sanitized.trim();
  }

  /// Sanitizes plant name input with specific rules
  static String sanitizePlantName(String input) {
    if (input.isEmpty) return input;
    String sanitized = input
        .replaceAll(
          RegExp(r'[<>"\\]'),
          '',
        ) // Remove dangerous HTML/script chars
        .replaceAll(RegExp(r'[\r\t]'), ' '); // Replace tabs/returns with spaces
    sanitized = sanitized.replaceAll(
      RegExp(r'[^a-zA-Z\u00C0-\u00FF0-9 \-.,()]'),
      '',
    );
    sanitized = sanitized.replaceAll(RegExp(r' +'), ' ');
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized.trim();
  }

  /// Sanitizes notes/description input
  static String sanitizeNotes(String input) {
    if (input.isEmpty) return input;

    String sanitized = input
        .replaceAll(RegExp(r'[<>"\\]'), '') // Remove dangerous chars
        .replaceAll(RegExp(r'[\r\t]'), ' ') // Replace tabs with spaces
        .replaceAll(RegExp(r'\n{3,}'), '\n\n'); // Limit consecutive newlines
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }

    return sanitized.trim();
  }
}
