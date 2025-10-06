/// Centralized formatting service for odometer values
///
/// This service provides consistent formatting and parsing for odometer values
/// throughout the application, ensuring data consistency and user experience.
class OdometerFormatter {
  /// Decimal separator used in Brazilian locale
  static const String decimalSeparator = ',';
  static const String dotSeparator = '.';
  
  /// Maximum decimal places for odometer values
  static const int decimalPlaces = 2;
  
  /// Zero value formatted with unit
  static const String zeroValueWithKm = '0,00 km';
  
  /// Threshold for adding thousands separator
  static const double thousandsSeparatorThreshold = 1000.0;
  
  /// Group size for thousands separator
  static const int thousandsGroupSize = 3;
  
  /// Formats a double value to Brazilian decimal format
  ///
  /// Example: 1234.56 -> "1234,56"
  static String formatOdometer(double value) {
    if (value == 0.0) return '';
    final String formatted = value.toStringAsFixed(decimalPlaces);
    return formatted.replaceAll(dotSeparator, decimalSeparator);
  }
  
  /// Parses a Brazilian formatted string to double
  ///
  /// Example: "1234,56" -> 1234.56
  static double parseOdometer(String value) {
    if (value.isEmpty) return 0.0;
    final String cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    
    return double.tryParse(cleanValue) ?? 0.0;
  }
  
  /// Validates if a string represents a valid odometer format
  ///
  /// Returns true if the format is valid, false otherwise
  static bool isValidOdometerFormat(String value) {
    if (value.isEmpty) return true; // Empty is valid (will be 0.0)
    final cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    final number = double.tryParse(cleanValue);
    
    return number != null && number >= 0;
  }
  
  /// Formats odometer value for display with unit
  ///
  /// Example: 1234.56 -> "1.234,56 km"
  static String formatOdometerWithUnit(double value, {String unit = 'km'}) {
    if (value == 0.0) return unit == 'km' ? zeroValueWithKm : '0,00 $unit';
    String formatted = value.toStringAsFixed(decimalPlaces);
    formatted = formatted.replaceAll(dotSeparator, decimalSeparator);
    if (value >= thousandsSeparatorThreshold) {
      final parts = formatted.split(decimalSeparator);
      final String integerPart = parts[0];
      final String decimalPart = parts.length > 1 ? parts[1] : '00';
      String result = '';
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % thousandsGroupSize == 0) {
          result = '.$result';
        }
        result = integerPart[i] + result;
        count++;
      }
      
      formatted = '$result,$decimalPart';
    }
    
    return '$formatted $unit';
  }
  
  /// Cleans and formats input text with comprehensive validation rules
  ///
  /// This method implements sophisticated input processing for odometer values:
  /// - Removes invalid characters (keeping only digits, commas, and dots)
  /// - Normalizes decimal separators to Brazilian format (comma)
  /// - Handles multiple decimal separator edge cases
  /// - Enforces decimal place limitations for data consistency
  /// - Maintains user input flow while ensuring data integrity
  ///
  /// Processing steps:
  /// 1. Strip non-numeric characters except decimal separators
  /// 2. Convert dots to commas for Brazilian locale
  /// 3. Resolve multiple decimal separators (keeps first, merges rest)
  /// 4. Truncate excessive decimal places
  ///
  /// Used primarily in TextFormField input formatters for real-time validation
  ///
  /// [input] The raw user input string
  /// Returns cleaned and formatted string ready for display and processing
  static String cleanAndFormatInput(String input) {
    if (input.isEmpty) return input;
    String cleaned = input.replaceAll(RegExp(r'[^\d,.]'), '');
    cleaned = cleaned.replaceAll(dotSeparator, decimalSeparator);
    final parts = cleaned.split(decimalSeparator);
    if (parts.length > 2) {
      cleaned = '${parts[0]}$decimalSeparator${parts.sublist(1).join('')}';
    }
    final finalParts = cleaned.split(decimalSeparator);
    if (finalParts.length == 2 && finalParts[1].length > decimalPlaces) {
      cleaned = '${finalParts[0]}$decimalSeparator${finalParts[1].substring(0, decimalPlaces)}';
    }
    
    return cleaned;
  }
}