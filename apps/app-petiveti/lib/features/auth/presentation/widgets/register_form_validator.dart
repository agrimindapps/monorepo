/// **Form Validation Logic for Registration**
/// 
/// Contains all validation rules and logic for user registration form fields.
/// This class provides static validation methods that can be reused across
/// different components and ensures consistent validation behavior.
/// 
/// ## Validation Rules:
/// - **Name**: Required, minimum 2 characters, alphabetic + spaces only
/// - **Email**: Required, valid email format, automatic lowercase conversion
/// - **Password**: Required, minimum 6 characters, strength recommendations
/// - **Confirm Password**: Required, must match password exactly
/// 
/// @author PetiVeti Development Team
/// @since 1.0.0
/// @version 1.3.0 - Enhanced validation patterns
abstract final class RegisterFormValidator {
  
  /// **Name Field Validation**
  /// 
  /// Validates user's full name input with the following rules:
  /// - Required field (cannot be empty or null)
  /// - Minimum length of 2 characters after trimming whitespace
  /// - Only alphabetic characters and spaces are allowed
  /// - Automatic whitespace trimming
  /// 
  /// @param value The name input value to validate
  /// @return String error message or null if valid
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    
    // Allow only letters, spaces, and common name characters
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmedValue)) {
      return 'Nome deve conter apenas letras';
    }
    
    return null;
  }
  
  /// **Email Field Validation**
  /// 
  /// Validates email address with comprehensive format checking:
  /// - Required field (cannot be empty or null)
  /// - Valid email format using robust RegExp pattern
  /// - Automatic lowercase conversion for consistency
  /// - Checks for common email format issues
  /// 
  /// @param value The email input value to validate
  /// @return String error message or null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }
    
    final trimmedValue = value.trim().toLowerCase();
    
    // Enhanced email validation pattern
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    
    if (!emailRegExp.hasMatch(trimmedValue)) {
      return 'Digite um email válido';
    }
    
    return null;
  }
  
  /// **Password Field Validation**
  /// 
  /// Validates password strength with security requirements:
  /// - Required field (cannot be empty or null)
  /// - Minimum length of 6 characters
  /// - Future enhancement: strength indicators and complex requirements
  /// 
  /// @param value The password input value to validate
  /// @return String error message or null if valid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    
    // Future enhancement: Add complexity requirements
    // - At least one uppercase letter
    // - At least one lowercase letter  
    // - At least one number
    // - At least one special character
    
    return null;
  }
  
  /// **Confirm Password Field Validation**
  /// 
  /// Validates password confirmation matching:
  /// - Required field (cannot be empty or null)
  /// - Must exactly match the original password
  /// - Case-sensitive matching for security
  /// 
  /// @param value The confirm password input value to validate
  /// @param originalPassword The original password to match against
  /// @return String error message or null if valid
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirmação de senha é obrigatória';
    }
    
    if (value != originalPassword) {
      return 'Senhas não coincidem';
    }
    
    return null;
  }
  
  /// **Password Strength Assessment**
  /// 
  /// Evaluates password strength and provides user feedback.
  /// Returns a score from 0-4 indicating password strength level.
  /// 
  /// @param password The password to evaluate
  /// @return PasswordStrength object with score and recommendations
  static PasswordStrength assessPasswordStrength(String password) {
    if (password.isEmpty) {
      return const PasswordStrength(
        score: 0,
        label: 'Muito fraca',
        recommendations: ['Digite uma senha'],
      );
    }
    
    int score = 0;
    final recommendations = <String>[];
    
    // Length check
    if (password.length >= 8) {
      score++;
    } else {
      recommendations.add('Use pelo menos 8 caracteres');
    }
    
    // Uppercase check
    if (password.contains(RegExp(r'[A-Z]'))) {
      score++;
    } else {
      recommendations.add('Inclua pelo menos uma letra maiúscula');
    }
    
    // Lowercase check
    if (password.contains(RegExp(r'[a-z]'))) {
      score++;
    } else {
      recommendations.add('Inclua pelo menos uma letra minúscula');
    }
    
    // Number check
    if (password.contains(RegExp(r'[0-9]'))) {
      score++;
    } else {
      recommendations.add('Inclua pelo menos um número');
    }
    
    // Special character check
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score++;
    } else {
      recommendations.add('Inclua pelo menos um caractere especial');
    }
    
    String label;
    switch (score) {
      case 0:
      case 1:
        label = 'Muito fraca';
        break;
      case 2:
        label = 'Fraca';
        break;
      case 3:
        label = 'Média';
        break;
      case 4:
        label = 'Forte';
        break;
      case 5:
        label = 'Muito forte';
        break;
      default:
        label = 'Muito fraca';
    }
    
    return PasswordStrength(
      score: score,
      label: label,
      recommendations: recommendations,
    );
  }
  
  /// **Form Completeness Validation**
  /// 
  /// Validates that all required form fields are completed correctly
  /// and terms are accepted before allowing form submission.
  /// 
  /// @param name User's name input
  /// @param email User's email input
  /// @param password User's password input
  /// @param confirmPassword User's confirm password input
  /// @param termsAccepted Whether terms and conditions are accepted
  /// @return FormValidationResult with overall validation status
  static FormValidationResult validateCompleteForm({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
  }) {
    final errors = <String, String>{};
    
    final nameError = validateName(name);
    if (nameError != null) errors['name'] = nameError;
    
    final emailError = validateEmail(email);
    if (emailError != null) errors['email'] = emailError;
    
    final passwordError = validatePassword(password);
    if (passwordError != null) errors['password'] = passwordError;
    
    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);
    if (confirmPasswordError != null) errors['confirmPassword'] = confirmPasswordError;
    
    if (!termsAccepted) {
      errors['terms'] = 'Você deve aceitar os termos e condições';
    }
    
    return FormValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// **Password Strength Assessment Result**
/// 
/// Contains password strength evaluation results with score and recommendations.
class PasswordStrength {
  final int score;
  final String label;
  final List<String> recommendations;
  
  const PasswordStrength({
    required this.score,
    required this.label,
    required this.recommendations,
  });
}

/// **Form Validation Result**
/// 
/// Contains complete form validation results with field-specific errors.
class FormValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  
  const FormValidationResult({
    required this.isValid,
    required this.errors,
  });
}