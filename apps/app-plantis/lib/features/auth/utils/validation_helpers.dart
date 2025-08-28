import 'package:flutter/material.dart';

/// Real-time validation helpers for form fields
class ValidationHelpers {
  /// Validates name field in real-time
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu nome completo';
    }
    if (value.trim().length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'Nome não pode ter mais de 100 caracteres';
    }
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value.trim())) {
      return 'Nome deve conter apenas letras';
    }
    return null;
  }

  /// Validates email field in real-time
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu email';
    }
    
    final email = value.trim().toLowerCase();
    
    // Basic email format validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Por favor, insira um email válido';
    }
    
    // More comprehensive email validation
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return 'Formato de email inválido';
    }
    
    // Length validation
    if (email.length > 254) {
      return 'Email muito longo';
    }
    
    return null;
  }

  /// Validates password field in real-time
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    if (value.length > 128) {
      return 'Senha muito longa';
    }
    
    // Check for at least one letter and one number for better security
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra e um número';
    }
    
    return null;
  }

  /// Validates password confirmation field in real-time
  static String? validatePasswordConfirmation(String? value, String? originalPassword) {
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
    
    // Remove all non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');
    
    // Brazilian phone numbers: 10-11 digits (with area code)
    if (digits.length < 10 || digits.length > 11) {
      return 'Número de telefone inválido';
    }
    
    // Check area code (first two digits should be valid Brazilian area codes)
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
  static Widget? getValidationIcon(String? value, String? Function(String?) validator) {
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
  static Color getBorderColor(String? value, String? Function(String?) validator) {
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
}