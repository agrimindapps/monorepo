import 'dart:core';

/// Security-focused input validators for the AgriHurbi application
/// 
/// This class provides robust validation methods to prevent security vulnerabilities
/// related to input validation, including email, phone, password, and name validation.
class InputValidators {
  InputValidators._();

  /// Validates email addresses with a more secure regex pattern
  /// 
  /// Security improvements:
  /// - Prevents acceptance of invalid emails like "test@.com"
  /// - Uses a more restrictive pattern that follows RFC 5322 guidelines
  /// - Prevents potential injection attacks through email validation bypass
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu e-mail';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Por favor, digite seu e-mail';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Digite um e-mail válido';
    }
    if (trimmedValue.length > 254) {
      return 'E-mail muito longo';
    }
    if (trimmedValue.contains('..')) {
      return 'E-mail inválido';
    }
    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.') ||
        trimmedValue.startsWith('@') || trimmedValue.endsWith('@')) {
      return 'E-mail inválido';
    }

    return null;
  }

  /// Validates phone numbers with enhanced security
  /// 
  /// Security improvements:
  /// - More restrictive pattern that prevents bypass
  /// - Validates Brazilian phone number formats
  /// - Prevents potential injection through phone field
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return null; // Phone is optional
    }
    final cleanPhone = trimmedValue.replaceAll(RegExp(r'[^\d\+]'), '');
    final phoneRegex = RegExp(r'^(\+55)?(\d{2})(\d{8,9})$');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Digite um telefone válido (ex: (11) 99999-9999)';
    }
    if (cleanPhone.length > 15) { // E.164 format maximum
      return 'Número de telefone muito longo';
    }
    final digitsOnly = cleanPhone.replaceAll(RegExp(r'[\+]'), '');
    if (RegExp(r'^(\d)\1+$').hasMatch(digitsOnly)) {
      return 'Digite um telefone válido';
    }

    return null;
  }

  /// Validates full names with enhanced security
  /// 
  /// Security improvements:
  /// - More rigorous validation that requires meaningful names
  /// - Prevents injection through name fields
  /// - Ensures both first and last name with minimum length requirements
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu nome';
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Por favor, digite seu nome';
    }
    if (trimmedValue.length > 100) {
      return 'Nome muito longo';
    }
    if (RegExp(r'''[<>"'&\$@#%^*()[\]{}|\\\/`~]''').hasMatch(trimmedValue)) {
      return 'Nome contém caracteres inválidos';
    }
    final nameParts = trimmedValue.split(RegExp(r'\s+'));
    
    if (nameParts.length < 2) {
      return 'Por favor, digite seu nome completo';
    }
    for (final part in nameParts) {
      if (part.length < 2) {
        return 'Digite um nome completo válido';
      }
    }
    if (nameParts.first.length == 1 || nameParts.last.length == 1) {
      return 'Digite seu nome completo (nome e sobrenome)';
    }
    if (RegExp(r'\d').hasMatch(trimmedValue)) {
      return 'Nome não pode conter números';
    }

    return null;
  }
}

/// Enhanced password validator with security-focused requirements
/// 
/// Implements secure password policies to prevent weak password vulnerabilities
class PasswordValidator {
  PasswordValidator._();

  /// Minimum password length for security
  static const int minPasswordLength = 8;

  /// Validates password with comprehensive security requirements
  /// 
  /// Security requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character
  /// - No common weak patterns
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite sua senha';
    }
    if (value.length < minPasswordLength) {
      return 'A senha deve ter pelo menos $minPasswordLength caracteres';
    }
    if (value.length > 128) {
      return 'Senha muito longa (máximo 128 caracteres)';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos 1 letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos 1 letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos 1 número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos 1 símbolo (!@#\$%^&*(),.?":{}|<>)';
    }
    final lowercasePassword = value.toLowerCase();
    final commonWeakPasswords = [
      'password', 'senha123', '12345678', 'qwerty123', 'abc123456',
      'admin123', 'user123', 'test123', '123456789', 'password123'
    ];

    for (final weak in commonWeakPasswords) {
      if (lowercasePassword.contains(weak)) {
        return 'Senha muito comum, escolha uma mais segura';
      }
    }
    if (RegExp(r'(.)\1{2,}').hasMatch(value)) {
      return 'Evite repetir o mesmo caractere consecutivamente';
    }
    final keyboardSequences = ['qwerty', 'asdfgh', 'zxcvbn', '123456', '654321'];
    for (final sequence in keyboardSequences) {
      if (lowercasePassword.contains(sequence)) {
        return 'Evite sequências de teclado na senha';
      }
    }

    return null;
  }

  /// Validates password confirmation
  /// 
  /// Ensures passwords match exactly
  static String? validatePasswordConfirmation(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }

    if (value != originalPassword) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  /// Gets password strength score (0-100)
  /// 
  /// Useful for providing user feedback on password security
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 15;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 15;
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 10;
    if (RegExp(r'123|abc|qwe').hasMatch(password.toLowerCase())) score -= 15;

    return score.clamp(0, 100);
  }

  /// Gets password strength description
  static String getPasswordStrengthDescription(int strength) {
    if (strength < 30) return 'Muito fraca';
    if (strength < 50) return 'Fraca';
    if (strength < 70) return 'Regular';
    if (strength < 90) return 'Boa';
    return 'Muito boa';
  }
}