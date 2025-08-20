class FormatUtils {
  /// Format weight with appropriate unit
  static String formatWeight(double peso) {
    if (peso >= 1.0) {
      return '${peso.toStringAsFixed(1)} kg';
    } else {
      final gramas = (peso * 1000).round();
      return '${gramas}g';
    }
  }
  
  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  /// Format large numbers
  static String formatLargeNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
  
  /// Format decimal with specified precision
  static String formatDecimal(double value, int precision) {
    return value.toStringAsFixed(precision);
  }
  
  /// Format currency (Brazilian Real)
  static String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
  
  /// Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }
  
  /// Escape field for CSV export
  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Format monetary value without currency symbol
  static String formatValor(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }
  
  /// Format monetary value with currency symbol
  static String formatValorComMoeda(double valor) {
    return 'R\$ ${formatValor(valor)}';
  }
  
  /// Parse monetary value from string
  static double parseValor(String valorString) {
    try {
      final cleanValue = valorString
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Sanitize text by trimming and normalizing spaces
  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Capitalize all words
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
}