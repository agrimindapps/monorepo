/// Input sanitization service to prevent XSS and data corruption
/// 
/// This service provides centralized input sanitization methods for all form inputs
/// across the application, preventing XSS attacks and maintaining data integrity.
/// 
/// Usage:
/// ```dart
/// final sanitized = InputSanitizer.sanitize(userInput);
/// final numericValue = InputSanitizer.sanitizeNumeric(priceInput);
/// ```
class InputSanitizer {
  
  /// Sanitizes general text input by removing HTML tags, dangerous characters,
  /// and normalizing whitespace to prevent XSS attacks
  /// 
  /// [input] - The raw input string to sanitize
  /// 
  /// Returns sanitized string safe for storage and display
  static String sanitize(String input) {
    if (input.isEmpty) return input;
    
    return input
        .trim()
        // Remove HTML tags to prevent XSS
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove potentially dangerous characters
        .replaceAll(RegExp(r'[&<>"\x27\x60]'), '')
        // Remove script-related keywords (case insensitive)
        .replaceAll(RegExp(r'javascript:|vbscript:|data:|file:', caseSensitive: false), '')
        // Remove event handlers (onclick, onload, etc.)
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        // Normalize multiple whitespaces to single space
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// Sanitizes numeric input by keeping only digits, commas, and decimal points
  /// 
  /// [input] - The numeric input string to sanitize
  /// 
  /// Returns string containing only valid numeric characters
  static String sanitizeNumeric(String input) {
    if (input.isEmpty) return input;
    
    return input
        .trim()
        // Keep only digits, comma, and decimal point
        .replaceAll(RegExp(r'[^0-9,.]'), '')
        // Ensure only one decimal separator
        .replaceAllMapped(RegExp(r'[,.]'), (match) {
          return match.group(0) == ',' ? ',' : '.';
        });
  }
  
  /// Sanitizes email input by removing dangerous characters while preserving
  /// valid email format
  /// 
  /// [input] - The email input string to sanitize
  /// 
  /// Returns sanitized email string
  static String sanitizeEmail(String input) {
    if (input.isEmpty) return input;
    
    return input
        .trim()
        .toLowerCase()
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove dangerous characters but keep valid email chars
        .replaceAll(RegExp(r'[^a-zA-Z0-9@._-]'), '')
        // Remove script-related content
        .replaceAll(RegExp(r'javascript:|data:|file:', caseSensitive: false), '');
  }
  
  /// Sanitizes name input by allowing only letters, spaces, and common name characters
  /// 
  /// [input] - The name input string to sanitize
  /// 
  /// Returns sanitized name string
  static String sanitizeName(String input) {
    if (input.isEmpty) return input;
    
    return input
        .trim()
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Keep only letters, spaces, apostrophes, and hyphens
        .replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ\s\x27-]'), '')
        // Remove dangerous patterns
        .replaceAll(RegExp(r'javascript:|data:|file:', caseSensitive: false), '')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  /// Sanitizes description/note input with more lenient rules but still secure
  /// 
  /// [input] - The description/note input string to sanitize
  /// 
  /// Returns sanitized description string
  static String sanitizeDescription(String input) {
    if (input.isEmpty) return input;
    
    return input
        .trim()
        // Remove HTML tags to prevent XSS
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Remove script injections
        .replaceAll(RegExp(r'javascript:|vbscript:|data:|file:', caseSensitive: false), '')
        // Remove event handlers
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        // Remove dangerous characters but allow more punctuation
        .replaceAll(RegExp(r'[<>"\x27\x60]'), '')
        // Normalize line breaks and whitespace
        .replaceAll(RegExp(r'\r\n|\r|\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();
  }
  
  /// Validates that input doesn't contain malicious patterns
  /// 
  /// [input] - The input string to validate
  /// 
  /// Returns true if input appears safe, false if potentially malicious
  static bool isInputSafe(String input) {
    if (input.isEmpty) return true;
    
    final maliciousPatterns = [
      RegExp(r'<script[^>]*>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'data:text/html', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'<iframe[^>]*>', caseSensitive: false),
      RegExp(r'<object[^>]*>', caseSensitive: false),
      RegExp(r'<embed[^>]*>', caseSensitive: false),
      RegExp(r'<form[^>]*>', caseSensitive: false),
    ];
    
    for (final pattern in maliciousPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Sanitizes input based on the field type automatically
  /// 
  /// [input] - The input string to sanitize
  /// [fieldType] - The type of field (text, numeric, email, name, description)
  /// 
  /// Returns sanitized string based on field type
  static String sanitizeByType(String input, String fieldType) {
    switch (fieldType.toLowerCase()) {
      case 'numeric':
      case 'number':
      case 'currency':
        return sanitizeNumeric(input);
      case 'email':
        return sanitizeEmail(input);
      case 'name':
        return sanitizeName(input);
      case 'description':
      case 'note':
      case 'observation':
        return sanitizeDescription(input);
      default:
        return sanitize(input);
    }
  }
  
  /// Log function for debugging sanitization issues (in debug mode only)
  // ignore: unused_element
  static void _logSanitization(String original, String sanitized) {
    assert(() {
      if (original != sanitized) {
        print('InputSanitizer: Input sanitized - Original: "$original" -> Sanitized: "$sanitized"');
      }
      return true;
    }());
  }
}