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
  
  /// Formats a double value to Brazilian decimal format
  ///
  /// Example: 1234.56 -> "1234,56"
  static String formatOdometer(double value) {
    if (value == 0.0) return '';
    
    // Format with proper decimal places
    String formatted = value.toStringAsFixed(decimalPlaces);
    
    // Replace dot with comma for Brazilian format
    return formatted.replaceAll(dotSeparator, decimalSeparator);
  }
  
  /// Parses a Brazilian formatted string to double
  ///
  /// Example: "1234,56" -> 1234.56
  static double parseOdometer(String value) {
    if (value.isEmpty) return 0.0;
    
    // Replace comma with dot for parsing
    String cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    
    return double.tryParse(cleanValue) ?? 0.0;
  }
  
  /// Validates if a string represents a valid odometer format
  ///
  /// Returns true if the format is valid, false otherwise
  static bool isValidOdometerFormat(String value) {
    if (value.isEmpty) return true; // Empty is valid (will be 0.0)
    
    // Check for valid decimal format
    final cleanValue = value.replaceAll(decimalSeparator, dotSeparator);
    final number = double.tryParse(cleanValue);
    
    return number != null && number >= 0;
  }
  
  /// Formats odometer value for display with unit
  ///
  /// Example: 1234.56 -> "1.234,56 km"
  static String formatOdometerWithUnit(double value, {String unit = 'km'}) {
    if (value == 0.0) return '0,00 $unit';
    
    // Format with thousands separator
    String formatted = value.toStringAsFixed(decimalPlaces);
    formatted = formatted.replaceAll(dotSeparator, decimalSeparator);
    
    // Add thousands separator (simple implementation)
    if (value >= 1000) {
      final parts = formatted.split(decimalSeparator);
      String integerPart = parts[0];
      String decimalPart = parts.length > 1 ? parts[1] : '00';
      
      // Add dots for thousands
      String result = '';
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result = '.$result';
        }
        result = integerPart[i] + result;
        count++;
      }
      
      formatted = '$result,$decimalPart';
    }
    
    return '$formatted $unit';
  }
  
  /// Cleans and formats input text for consistent display
  ///
  /// Used in TextFormField formatters
  static String cleanAndFormatInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove any non-numeric characters except comma and dot
    String cleaned = input.replaceAll(RegExp(r'[^\d,.]'), '');
    
    // Replace dots with commas
    cleaned = cleaned.replaceAll(dotSeparator, decimalSeparator);
    
    // Ensure only one decimal separator
    final parts = cleaned.split(decimalSeparator);
    if (parts.length > 2) {
      cleaned = '${parts[0]}$decimalSeparator${parts.sublist(1).join('')}';
    }
    
    // Limit decimal places
    final finalParts = cleaned.split(decimalSeparator);
    if (finalParts.length == 2 && finalParts[1].length > decimalPlaces) {
      cleaned = '${finalParts[0]}$decimalSeparator${finalParts[1].substring(0, decimalPlaces)}';
    }
    
    return cleaned;
  }
}