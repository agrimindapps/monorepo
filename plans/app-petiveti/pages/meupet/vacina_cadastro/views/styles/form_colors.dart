// Flutter imports:
import 'package:flutter/material.dart';

/// Color constants for vaccine registration forms
class FormColors {
  // Primary form colors
  static const Color primary = Colors.blue;
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Form field colors
  static const Color fieldBackground = Colors.white;
  static const Color fieldBorder = Color(0xFFE0E0E0);
  static const Color fieldBorderFocused = Colors.blue;
  static const Color fieldLabel = Color(0xFF757575);
  static const Color fieldText = Color(0xFF212121);
  static const Color fieldHint = Color(0xFF9E9E9E);
  
  // Validation colors
  static const Color error = Colors.red;
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorText = Color(0xFFD32F2F);
  static const Color success = Colors.green;
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color warning = Colors.orange;
  static const Color warningLight = Color(0xFFFFF3E0);
  
  // Button colors
  static const Color buttonPrimary = Colors.blue;
  static const Color buttonSecondary = Color(0xFF757575);
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonTextPrimary = Colors.white;
  static const Color buttonTextSecondary = Colors.white;
  static const Color buttonTextDisabled = Color(0xFF9E9E9E);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color dialogBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Icon colors
  static const Color iconPrimary = Color(0xFF757575);
  static const Color iconSecondary = Color(0xFF9E9E9E);
  static const Color iconError = Colors.red;
  static const Color iconSuccess = Colors.green;
  
  // Loading colors
  static const Color loadingBackground = Color(0x80000000);
  static const Color loadingIndicator = Colors.blue;
  
  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color cardShadow = Color(0x0F000000);
  
  // Date picker colors
  static const Color datePickerPrimary = Colors.blue;
  static const Color datePickerBackground = Colors.white;
  static const Color datePickerText = Color(0xFF212121);
  
  // Character counter colors
  static const Color counterNormal = Color(0xFF9E9E9E);
  static const Color counterWarning = Colors.orange;
  static const Color counterError = Colors.red;
}

/// Extension for color utilities
extension FormColorsExtension on FormColors {
  /// Gets validation color based on state
  static Color getValidationColor(ValidationState state) {
    switch (state) {
      case ValidationState.error:
        return FormColors.error;
      case ValidationState.warning:
        return FormColors.warning;
      case ValidationState.success:
        return FormColors.success;
      case ValidationState.normal:
        return FormColors.fieldBorder;
    }
  }
  
  /// Gets validation background color based on state
  static Color getValidationBackgroundColor(ValidationState state) {
    switch (state) {
      case ValidationState.error:
        return FormColors.errorLight;
      case ValidationState.warning:
        return FormColors.warningLight;
      case ValidationState.success:
        return FormColors.successLight;
      case ValidationState.normal:
        return FormColors.fieldBackground;
    }
  }
  
  /// Gets character counter color based on usage
  static Color getCounterColor(int currentLength, int maxLength) {
    final percentage = currentLength / maxLength;
    
    if (percentage >= 1.0) {
      return FormColors.counterError;
    } else if (percentage >= 0.8) {
      return FormColors.counterWarning;
    } else {
      return FormColors.counterNormal;
    }
  }
}

/// Validation state enum
enum ValidationState {
  normal,
  success,
  warning,
  error,
}
