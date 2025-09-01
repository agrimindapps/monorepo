/// Security-enhanced validation utilities for authentication
class AuthValidators {
  /// Enhanced secure email validation using comprehensive RegExp
  /// 
  /// This validator provides comprehensive protection against:
  /// - Email injection attacks
  /// - Malformed email addresses
  /// - Suspicious patterns that could indicate malicious input
  /// - Buffer overflow attempts via extremely long emails
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Trim whitespace and convert to lowercase for validation
    final cleanEmail = email.trim().toLowerCase();
    
    // Enhanced email validation regex with stricter security
    // More restrictive than basic RFC compliance for security
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$'
    );
    
    // Primary format validation
    if (!emailRegex.hasMatch(cleanEmail)) return false;
    
    // Prevent multiple @ symbols (injection protection)
    if (cleanEmail.split('@').length != 2) return false;
    
    // Enhanced suspicious pattern detection
    if (cleanEmail.contains('..') || 
        cleanEmail.startsWith('.') || 
        cleanEmail.endsWith('.') ||
        cleanEmail.contains('@.') ||
        cleanEmail.contains('.@') ||
        cleanEmail.contains('.-') ||
        cleanEmail.contains('-.')) {
      return false;
    }
    
    // Check for potential script injection patterns in email
    if (RegExp(r'[<>"\\\s\n\r\t]').hasMatch(cleanEmail)) {
      return false;
    }
    
    // Validate local part length (before @)
    final parts = cleanEmail.split('@');
    if (parts[0].length > 64 || parts[0].isEmpty) return false;
    
    // Validate domain part length (after @)
    if (parts[1].length > 253 || parts[1].isEmpty) return false;
    
    // Maximum total email length for security (RFC 5321 limit)
    if (cleanEmail.length > 320) return false;
    
    return true;
  }
  
  /// Enhanced password validation with security requirements
  /// 
  /// Requirements:
  /// - Minimum 8 characters (consistent across app)
  /// - At least one letter and one number
  /// - Protection against common weak passwords
  static String? validatePassword(String password, {bool isRegistration = false}) {
    if (password.isEmpty) {
      return isRegistration ? 'Por favor, insira uma senha' : 'Por favor, insira sua senha';
    }
    
    // Consistent minimum length requirement
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    
    // For registration, enforce stronger requirements
    if (isRegistration) {
      // Require letters and numbers
      if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
        return 'A senha deve conter letras e números';
      }
      
      // Check for common weak patterns
      final commonWeakPatterns = [
        r'12345',
        r'abcde',
        r'qwert',
        r'password',
        r'senha',
      ];
      
      for (final pattern in commonWeakPatterns) {
        if (password.toLowerCase().contains(pattern)) {
          return 'Senha muito simples. Evite sequências comuns';
        }
      }
    }
    
    return null; // Valid password
  }
  
  /// Validate password confirmation matches
  static String? validatePasswordConfirmation(String password, String confirmation) {
    if (confirmation.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    
    if (password != confirmation) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }
  
  /// Validate name field for registration
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Por favor, insira seu nome';
    }
    
    final trimmedName = name.trim();
    
    if (trimmedName.length < 2) {
      return 'O nome deve ter pelo menos 2 caracteres';
    }
    
    // Check for suspicious characters
    if (RegExp(r'[<>"\\\n\r\t]').hasMatch(trimmedName)) {
      return 'Nome contém caracteres não permitidos';
    }
    
    // Maximum length for security
    if (trimmedName.length > 100) {
      return 'Nome muito longo (máximo 100 caracteres)';
    }
    
    return null;
  }
}