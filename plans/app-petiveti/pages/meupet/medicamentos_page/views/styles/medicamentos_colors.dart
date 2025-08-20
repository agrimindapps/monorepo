// Flutter imports:
import 'package:flutter/material.dart';

class MedicamentosColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
  
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFF9E9E9E);
  
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
  
  static const Color disabledColor = Color(0xFFE0E0E0);
  static const Color disabledTextColor = Color(0xFF9E9E9E);
  
  static const Color overlayColor = Color(0x80000000);
  
  // Status colors
  static const Color activeStatusColor = Color(0xFF4CAF50);
  static const Color inactiveStatusColor = Color(0xFF9E9E9E);
  static const Color urgentStatusColor = Color(0xFFFF5722);
  static const Color expiredStatusColor = Color(0xFF795548);
  
  // Background colors for status
  static Color get activeStatusBackground => activeStatusColor.withValues(alpha: 0.1);
  static Color get inactiveStatusBackground => inactiveStatusColor.withValues(alpha: 0.1);
  static Color get urgentStatusBackground => urgentStatusColor.withValues(alpha: 0.1);
  static Color get expiredStatusBackground => expiredStatusColor.withValues(alpha: 0.1);
  
  // General alpha variants
  static Color get primaryColorLight => primaryColor.withValues(alpha: 0.1);
  static Color get errorColorLight => errorColor.withValues(alpha: 0.1);
  static Color get successColorLight => successColor.withValues(alpha: 0.1);
  static Color get warningColorLight => warningColor.withValues(alpha: 0.1);
}
