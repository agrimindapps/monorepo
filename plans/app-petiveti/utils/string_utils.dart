/// Utilitários para manipulação de strings
extension StringExtension on String {
  /// Capitaliza o primeiro caractere de uma string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palavra em uma string
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty ? word.capitalize() : word)
        .join(' ');
  }
}

class StringUtils {
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Capitalize each word
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Sanitize text by trimming and normalizing spaces
  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
