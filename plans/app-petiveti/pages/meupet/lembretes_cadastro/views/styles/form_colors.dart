// Flutter imports:
import 'package:flutter/material.dart';

class LembreteFormColors {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF2563EB);
  static const Color borderError = Color(0xFFEF4444);
  
  static const Color fieldBackground = Color(0xFFF9FAFB);
  static const Color fieldBackgroundFocus = Color(0xFFFFFFFF);
  static const Color fieldBackgroundDisabled = Color(0xFFF3F4F6);
  
  static Color get primaryWithOpacity => primaryColor.withValues(alpha: 0.1);
  static Color get successWithOpacity => successColor.withValues(alpha: 0.1);
  static Color get errorWithOpacity => errorColor.withValues(alpha: 0.1);
  static Color get warningWithOpacity => warningColor.withValues(alpha: 0.1);
  static Color get infoWithOpacity => infoColor.withValues(alpha: 0.1);
  
  static Color get shadowColor => Colors.black.withValues(alpha: 0.1);
  static Color get overlayColor => Colors.black.withValues(alpha: 0.5);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );
  
  static BoxShadow get cardShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get buttonShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 4,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get inputShadow => BoxShadow(
    color: shadowColor,
    blurRadius: 2,
    offset: const Offset(0, 1),
  );
}
