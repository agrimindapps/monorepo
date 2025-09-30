import 'dart:developer' as developer;

/// Security-hardened input validation utilities
/// 
/// Contains robust validation methods for user inputs to prevent
/// common security vulnerabilities and ensure data integrity.
class InputValidators {
  InputValidators._();

  // === EMAIL VALIDATION ===
  
  /// Secure email validation regex
  /// 
  /// Security improvements over vulnerable pattern:
  /// - No vulnerable character classes
  /// - Proper domain validation
  /// - Prevents bypass attacks like test@.com
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  /// Validates email with security-first approach
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-mail é obrigatório';
    }

    final email = value.trim().toLowerCase();
    
    // Length validation
    if (email.length > 254) {
      return 'E-mail muito longo';
    }
    
    if (email.length < 3) {
      return 'E-mail muito curto';
    }

    // Regex validation
    if (!_emailRegex.hasMatch(email)) {
      return 'Formato de e-mail inválido';
    }

    // Additional security checks
    if (email.contains('..') || 
        email.startsWith('.') || 
        email.endsWith('.') ||
        email.startsWith('@') || 
        email.endsWith('@')) {
      return 'E-mail contém caracteres inválidos';
    }

    // Local part validation (before @)
    final parts = email.split('@');
    if (parts[0].length > 64) {
      return 'Nome do e-mail muito longo';
    }

    return null;
  }

  // === PHONE VALIDATION ===
  
  /// Brazilian phone number patterns
  static final RegExp _brazilianPhoneRegex = RegExp(
    r'^(\+55\s?)?(\(?\d{2}\)?\s?)?9?\d{8}$',
    caseSensitive: false,
  );
  
  /// International phone validation (more restrictive)
  static final RegExp _internationalPhoneRegex = RegExp(
    r'^\+[1-9]\d{1,14}$',
    caseSensitive: false,
  );

  /// Validates phone number with Brazilian and international support
  /// 
  /// Returns null if valid or empty, error message if invalid
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final phone = value.trim().replaceAll(RegExp(r'[\s\(\)\-]'), '');
    
    // Length validation
    if (phone.length < 8) {
      return 'Telefone muito curto';
    }
    
    if (phone.length > 17) { // +XX + 15 digits max
      return 'Telefone muito longo';
    }

    // Check for valid characters only
    if (!RegExp(r'^[\+\d]+$').hasMatch(phone)) {
      return 'Telefone contém caracteres inválidos';
    }

    // Validate Brazilian or international format
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d\+]'), '');
    
    if (cleanPhone.startsWith('+55')) {
      // Brazilian number
      if (!_brazilianPhoneRegex.hasMatch(value.trim())) {
        return 'Formato de telefone brasileiro inválido';
      }
    } else if (cleanPhone.startsWith('+')) {
      // International number
      if (!_internationalPhoneRegex.hasMatch(cleanPhone)) {
        return 'Formato de telefone internacional inválido';
      }
    } else {
      // Assume Brazilian without country code
      final brazilianPhone = '+55$cleanPhone';
      if (!_brazilianPhoneRegex.hasMatch(brazilianPhone)) {
        return 'Formato de telefone inválido';
      }
    }

    return null;
  }

  // === NAME VALIDATION ===
  
  /// Validates full name with security considerations
  /// 
  /// Returns null if valid, error message if invalid
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome completo é obrigatório';
    }

    final name = value.trim();
    
    // Length validation
    if (name.length < 2) {
      return 'Nome muito curto';
    }
    
    if (name.length > 100) {
      return 'Nome muito longo';
    }

    // Character validation - only letters, spaces, and common name characters
    final namePattern = RegExp(r'^[a-zA-ZÀ-ÿ\u0100-\u017F\s\.\-]+$', unicode: true);
    if (!namePattern.hasMatch(name)) {
      return 'Nome contém caracteres inválidos';
    }

    // Structure validation
    final parts = name.split(RegExp(r'\s+'));
    
    if (parts.length < 2) {
      return 'Digite seu nome completo (nome e sobrenome)';
    }

    // Each part must have at least 2 characters
    for (final part in parts) {
      if (part.length < 2) {
        return 'Cada parte do nome deve ter pelo menos 2 caracteres';
      }
    }

    // Prevent malicious patterns
    final maliciousPattern = RegExp(r'[<>"&]');
    if (name.contains(maliciousPattern)) {
      return 'Nome contém caracteres não permitidos';
    }

    // Prevent excessive repetition
    if (RegExp(r'(.)\1{4,}').hasMatch(name)) {
      return 'Nome contém repetições excessivas';
    }

    return null;
  }
}

/// Password security validator with comprehensive strength checking
/// 
/// Implements industry-standard password security requirements
/// to prevent common authentication vulnerabilities.
class PasswordValidator {
  PasswordValidator._();

  // Password strength requirements
  static const int _minLength = 8;
  static const int _maxLength = 128;
  
  /// Validates password strength with security requirements
  /// 
  /// Security requirements:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter  
  /// - At least 1 number
  /// - At least 1 special character
  /// - No common weak patterns
  /// 
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    final password = value;
    
    // Length validation
    if (password.length < _minLength) {
      return 'Senha deve ter pelo menos $_minLength caracteres';
    }
    
    if (password.length > _maxLength) {
      return 'Senha muito longa (máximo $_maxLength caracteres)';
    }

    // Character composition requirements
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Senha deve conter pelo menos 1 letra maiúscula';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Senha deve conter pelo menos 1 letra minúscula';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Senha deve conter pelo menos 1 número';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Senha deve conter pelo menos 1 caractere especial (!@#\$%^&*(),.?":{}|<>)';
    }

    // Security pattern checks
    if (_hasWeakPatterns(password)) {
      return 'Senha contém padrões inseguros (sequências, repetições)';
    }

    // Common password validation
    if (_isCommonPassword(password.toLowerCase())) {
      return 'Esta senha é muito comum. Escolha uma senha mais segura';
    }

    return null;
  }

  /// Validates password confirmation matches
  /// 
  /// Returns null if passwords match, error message if they don't
  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }

    if (password != confirmation) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  /// Calculates password strength score (0-4)
  /// 
  /// 0: Very weak
  /// 1: Weak  
  /// 2: Fair
  /// 3: Good
  /// 4: Strong
  static int calculatePasswordStrength(String password) {
    int score = 0;
    
    // Length bonus
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    
    // Penalty for weak patterns
    if (_hasWeakPatterns(password)) score -= 2;
    if (_isCommonPassword(password.toLowerCase())) score -= 2;
    
    return score.clamp(0, 4);
  }

  /// Checks for weak password patterns
  static bool _hasWeakPatterns(String password) {
    final lower = password.toLowerCase();
    
    // Sequential characters
    if (RegExp(r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)').hasMatch(lower) ||
        RegExp(r'(123|234|345|456|567|678|789|890)').hasMatch(password)) {
      return true;
    }
    
    // Reverse sequential
    if (RegExp(r'(zyx|yxw|xwv|wvu|vut|uts|tsr|srq|rqp|qpo|pon|onm|nml|mlk|lkj|kji|jih|ihg|hgf|gfe|fed|edc|dcb|cba)').hasMatch(lower) ||
        RegExp(r'(987|876|765|654|543|432|321|210)').hasMatch(password)) {
      return true;
    }
    
    // Repeated characters
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      return true;
    }
    
    // Keyboard patterns
    if (RegExp(r'(qwer|asdf|zxcv|1234|qaz|wsx|edc)').hasMatch(lower)) {
      return true;
    }
    
    return false;
  }

  /// Checks against common weak passwords
  static bool _isCommonPassword(String password) {
    const commonPasswords = [
      '123456', 'password', '123456789', '12345678', '12345', '1234567', 
      'qwerty', 'abc123', 'password123', 'admin', 'letmein', 'welcome',
      '123123', 'password1', '1234567890', 'senha123', 'senha', '123senha'
    ];
    
    return commonPasswords.contains(password);
  }

  /// Returns password strength description
  static String getPasswordStrengthDescription(int strength) {
    switch (strength) {
      case 0:
        return 'Muito fraca';
      case 1:
        return 'Fraca';
      case 2:
        return 'Regular';
      case 3:
        return 'Boa';
      case 4:
        return 'Forte';
      default:
        return 'Desconhecida';
    }
  }

  /// Returns password strength color for UI
  static String getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return '#FF5252'; // Red
      case 2:
        return '#FF9800'; // Orange  
      case 3:
        return '#FFC107'; // Yellow
      case 4:
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Gray
    }
  }
}

/// Logging utility for security validation events
class SecurityLogger {
  SecurityLogger._();

  static void logValidationAttempt(String type, bool success) {
    if (!success) {
      developer.log(
        'Validation failed for $type', 
        name: 'SecurityValidator',
        level: 900, // Warning level
      );
    }
  }
  
  static void logSuspiciousActivity(String activity, String details) {
    developer.log(
      'Suspicious activity detected: $activity - $details',
      name: 'SecurityValidator', 
      level: 1000, // Error level
    );
  }
}