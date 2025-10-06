import 'package:flutter/material.dart';

/// Typography base compartilhada entre todos os apps
class BaseTypography {
  static const String defaultFontFamily = 'Inter';
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.29,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.10,
    height: 1.43,
  );
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.10,
    height: 1.43,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.50,
    height: 1.33,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.50,
    height: 1.45,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.40,
    height: 1.33,
  );
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.10,
    height: 1.43,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.40,
    height: 1.33,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.50,
    height: 1.60,
  );
  
  /// Returns a TextTheme with the specified font family
  static TextTheme textTheme([String? fontFamily]) {
    final family = fontFamily ?? defaultFontFamily;
    
    return TextTheme(
      displayLarge: displayLarge.copyWith(fontFamily: family),
      displayMedium: displayMedium.copyWith(fontFamily: family),
      displaySmall: displaySmall.copyWith(fontFamily: family),
      headlineLarge: headlineLarge.copyWith(fontFamily: family),
      headlineMedium: headlineMedium.copyWith(fontFamily: family),
      headlineSmall: headlineSmall.copyWith(fontFamily: family),
      titleLarge: titleLarge.copyWith(fontFamily: family),
      titleMedium: titleMedium.copyWith(fontFamily: family),
      titleSmall: titleSmall.copyWith(fontFamily: family),
      bodyLarge: bodyLarge.copyWith(fontFamily: family),
      bodyMedium: bodyMedium.copyWith(fontFamily: family),
      bodySmall: bodySmall.copyWith(fontFamily: family),
      labelLarge: labelLarge.copyWith(fontFamily: family),
      labelMedium: labelMedium.copyWith(fontFamily: family),
      labelSmall: labelSmall.copyWith(fontFamily: family),
    );
  }
}