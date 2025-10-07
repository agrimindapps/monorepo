import 'dart:core';

/// A utility class providing security-focused validators for user input.
///
/// This class offers static methods for validating common input fields like emails,
/// phone numbers, and names, with a focus on preventing common vulnerabilities.
class InputValidators {
  InputValidators._();

  /// Validates an email address against a secure regex and common patterns.
  ///
  /// This validator checks for a valid format, reasonable length, and common
  /// mistakes to prevent invalid data and potential injection vectors.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.'; // l10n
    }

    final trimmedValue = value.trim();
    // A more RFC-compliant regex, though not perfect, it covers most cases.
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");

    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Please enter a valid email address.'; // l10n
    }
    if (trimmedValue.length > 254) {
      return 'Email address is too long.'; // l10n
    }
    return null;
  }

  /// Validates a phone number, specifically formatted for Brazil.
  ///
  /// This validator is optional and checks for common Brazilian phone formats,
  /// including country code and DDD.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional.
    }

    final cleanPhone = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    // Validates Brazilian numbers: (e.g., 11987654321 or 5511987654321)
    final phoneRegex = RegExp(r'^(?:[1-9]{2})?9[1-9][0-9]{7}$');

    if (cleanPhone.length < 10 || cleanPhone.length > 13) {
      return 'Please enter a valid phone number.'; // l10n
    }

    final dddAndNumber =
        cleanPhone.length >= 12 ? cleanPhone.substring(2) : cleanPhone;

    if (!phoneRegex.hasMatch(dddAndNumber)) {
      return 'Please use a valid format (e.g., (11) 99999-9999).'; // l10n
    }
    return null;
  }

  /// Validates a full name, requiring at least a first and last name.
  ///
  /// This validator prevents common injection characters and ensures the name
  /// is reasonably structured.
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.'; // l10n
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 3) {
      return 'Name is too short.'; // l10n
    }
    if (trimmedValue.length > 100) {
      return 'Name is too long.'; // l10n
    }
    // Disallow characters often used in injection attacks.
    if (RegExp(r'[<>"\'&$/\\|]').hasMatch(trimmedValue)) {
      return 'Name contains invalid characters.'; // l10n
    }
    if (RegExp(r'\d').hasMatch(trimmedValue)) {
      return 'Name cannot contain numbers.'; // l10n
    }

    final nameParts = trimmedValue.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (nameParts.length < 2) {
      return 'Please enter both your first and last name.'; // l10n
    }
    return null;
  }
}

/// A utility class for validating passwords based on security policies.
class PasswordValidator {
  PasswordValidator._();

  /// The minimum required length for a secure password.
  static const int minPasswordLength = 8;

  static final List<String> _commonWeakPasswords = [
    'password', 'senha123', '12345678', 'qwerty', '123456', 'admin'
  ];
  static final List<String> _keyboardSequences = [
    'qwerty', 'asdfgh', 'zxcvbn', '123456', '654321'
  ];

  /// Validates a password against a set of security requirements.
  ///
  /// Checks for length, character diversity, and common weak patterns.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.'; // l10n
    }
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters long.'; // l10n
    }
    if (value.length > 128) {
      return 'Password is too long (max 128 characters).'; // l10n
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter.'; // l10n
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter.'; // l10n
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number.'; // l10n
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character.'; // l10n
    }

    final lowercasePassword = value.toLowerCase();
    if (_commonWeakPasswords.any(lowercasePassword.contains)) {
      return 'Password is too common. Please choose a stronger one.'; // l10n
    }
    if (_keyboardSequences.any(lowercasePassword.contains)) {
      return 'Avoid using keyboard sequences in your password.'; // l10n
    }
    // Check for more than 2 repeated characters (e.g., 'aaa').
    if (RegExp(r'(.)\1{2,}').hasMatch(value)) {
      return 'Avoid using repeating characters in your password.'; // l10n
    }
    return null;
  }

  /// Validates that the password confirmation matches the original password.
  static String? validatePasswordConfirmation(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.'; // l10n
    }
    if (value != originalPassword) {
      return 'Passwords do not match.'; // l10n
    }
    return null;
  }

  /// Calculates a password strength score from 0 to 100.
  ///
  /// This can be used to provide real-time feedback to the user.
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;
    // Length-based score
    score += (password.length >= 8) ? 20 : 0;
    score += (password.length >= 12) ? 10 : 0;
    score += (password.length >= 16) ? 10 : 0;

    // Character diversity score
    if (password.contains(RegExp(r'[a-z]'))) score += 15;
    if (password.contains(RegExp(r'[A-Z]'))) score += 15;
    if (password.contains(RegExp(r'[0-9]'))) score += 15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score += 15;

    // Penalties for weak patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score -= 10;
    if (_keyboardSequences.any(password.toLowerCase().contains)) score -= 15;

    return score.clamp(0, 100);
  }

  /// Returns a human-readable description of the password strength.
  static String getPasswordStrengthDescription(int strength) {
    if (strength < 30) return 'Very Weak'; // l10n
    if (strength < 50) return 'Weak'; // l10n
    if (strength < 70) return 'Fair'; // l10n
    if (strength < 90) return 'Good'; // l10n
    return 'Very Good'; // l10n
  }
}