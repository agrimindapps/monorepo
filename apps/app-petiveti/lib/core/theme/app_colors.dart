import 'package:flutter/material.dart';

/// PetiVeti App Colors - Sistema unificado de cores
/// Baseado na identidade visual das páginas de login e promoção
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ========== CORE BRAND COLORS ==========
  
  /// Primary Purple - Cor principal da marca
  static const primary = Color(0xFF6A1B9A); // Purple 800
  
  /// Primary variants
  static const primaryLight = Color(0xFF9C4DCC); // Purple 400
  static const primaryDark = Color(0xFF4A148C); // Purple 900
  
  /// Secondary Light Blue - Cor accent
  static const secondary = Color(0xFF03A9F4); // Light Blue 500
  static const secondaryLight = Color(0xFF40C4FF); // Light Blue 400
  static const secondaryDark = Color(0xFF0288D1); // Light Blue 600

  // ========== GRADIENT COLORS ==========
  
  /// Primary gradient (usado em headers, login, etc)
  static const List<Color> primaryGradient = [primary, primaryDark];
  
  /// Secondary gradient (para destaques suaves)
  static const List<Color> secondaryGradient = [secondaryLight, secondary];

  // ========== SURFACE COLORS ==========
  
  /// Background colors
  static const background = Color(0xFFF5F5F5); // Light grey
  static const surface = Color(0xFFFFFFFF); // White
  static const surfaceVariant = Color(0xFFF8F9FA); // Very light grey
  
  /// On-surface colors  
  static const onSurface = Color(0xFF1F1F1F); // Dark grey
  static const onBackground = Color(0xFF1F1F1F); // Dark grey
  static const onPrimary = Colors.white; // White on purple
  static const onSecondary = Colors.white; // White on blue

  // ========== SEMANTIC COLORS ==========
  
  /// Success (Verde veterinário - mantendo para contexto médico)
  static const success = Color(0xFF4CAF50); // Green 500
  static const successLight = Color(0xFF81C784); // Green 300
  static const successDark = Color(0xFF388E3C); // Green 700
  
  /// Warning
  static const warning = Color(0xFFFF9800); // Orange 500
  static const warningLight = Color(0xFFFFB74D); // Orange 300
  static const warningDark = Color(0xFFF57C00); // Orange 700
  
  /// Error  
  static const error = Color(0xFFF44336); // Red 500
  static const errorLight = Color(0xFFE57373); // Red 300
  static const errorDark = Color(0xFFD32F2F); // Red 700
  
  /// Info
  static const info = secondary; // Use secondary blue for info

  // ========== TEXT COLORS ==========
  
  static const textPrimary = Color(0xFF212121); // Dark grey
  static const textSecondary = Color(0xFF757575); // Medium grey  
  static const textDisabled = Color(0xFFBDBDBD); // Light grey
  static const textOnPrimary = Colors.white; // White on purple
  static const textOnSecondary = Colors.white; // White on blue

  // ========== FEATURE COLORS ==========
  // Cores específicas para diferentes features (baseadas no SplashColors)
  
  static const petProfilesColor = primary; // Purple
  static const vaccinesColor = Color(0xFFD32F2F); // Red 600
  static const medicationsColor = Color(0xFF388E3C); // Green 700  
  static const weightControlColor = Color(0xFFFF8F00); // Orange 700
  static const appointmentsColor = Color(0xFF1976D2); // Blue 600
  static const remindersColor = Color(0xFF00796B); // Teal 700

  // ========== UI ELEMENTS ==========
  
  static const divider = Color(0xFFE0E0E0); // Light grey
  static const border = Color(0xFFE0E0E0); // Light grey
  static const shadow = Color(0x1F000000); // Black with opacity
  
  /// Dialog/Modal colors
  static const dialogBackground = surface;
  static const dialogBarrier = Color(0x80000000); // Black with opacity
  static const overlayBackground = Color(0xF0FFFFFF); // Almost white with opacity

  // ========== NAVIGATION COLORS ==========
  
  static const navigationBackground = surface;
  static const navigationSelected = primary;
  static const navigationUnselected = Color(0xFF757575);
  static const navigationIndicator = primary;

  // ========== COMPATIBILITY METHODS ==========
  // Para manter compatibilidade com código existente
  
  /// Get primary color (compatibility)
  static Color get primaryColor => primary;
  
  /// Get accent color (compatibility) 
  static Color get accentColor => secondary;
  
  /// Get background color (compatibility)
  static Color get backgroundColor => background;
}