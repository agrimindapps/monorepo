import 'package:flutter/material.dart';

/// Cores base neutras compartilhadas entre todos os apps
class BaseColors {
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD4EFDF);
  static const Color successDark = Color(0xFF1E8449);
  
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF5E7);
  static const Color warningDark = Color(0xFFB7750F);
  
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFADED8);
  static const Color errorDark = Color(0xFFAD302A);
  
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFDBF2FD);
  static const Color infoDark = Color(0xFF2874A6);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  static const Color textDisabledLight = Color(0xFFBDC3C7);
  static const Color dividerLight = Color(0xFFECF0F1);
  static const Color borderLight = Color(0xFFDDE1E3);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF6C6C6C);
  static const Color dividerDark = Color(0xFF2C2C2C);
  static const Color borderDark = Color(0xFF404040);
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowDark = Color(0x3F000000);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static Color surfaceTintLight(int elevation) {
    final opacity = _elevationOpacity(elevation);
    return Color.lerp(surfaceLight, textPrimaryLight, opacity) ?? surfaceLight;
  }
  
  static Color surfaceTintDark(int elevation) {
    final opacity = _elevationOpacity(elevation);
    return Color.lerp(surfaceDark, white, opacity) ?? surfaceDark;
  }
  
  static double _elevationOpacity(int elevation) {
    switch (elevation) {
      case 1: return 0.05;
      case 2: return 0.08;
      case 3: return 0.11;
      case 4: return 0.12;
      case 6: return 0.14;
      case 8: return 0.16;
      case 12: return 0.20;
      case 16: return 0.22;
      case 24: return 0.24;
      default: return 0.0;
    }
  }
}