// STUB - FASE 0.7
// TODO FASE 1: Implementar configuração completa de tema

import 'package:flutter/material.dart';

class AppThemeConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color textColor;

  const AppThemeConfig({
    this.primaryColor = const Color(0xFF4CAF50),
    this.secondaryColor = const Color(0xFF81C784),
    this.accentColor = const Color(0xFFFFEB3B),
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
  });

  // Factory para Nutrituti
  factory AppThemeConfig.forNutrituti() {
    return const AppThemeConfig(
      primaryColor: Color(0xFF4CAF50), // Verde Nutrituti
      secondaryColor: Color(0xFF81C784),
      accentColor: Color(0xFFFFEB3B),
    );
  }

  // CopyWith para customizações
  AppThemeConfig copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return AppThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
    );
  }
}
