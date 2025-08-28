import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Definição dos estilos de texto do aplicativo GasOMeter
class AppTextStyles {
  AppTextStyles._();

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    inherit: false,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );

  static const TextStyle displayMedium = TextStyle(
    inherit: false,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle displaySmall = TextStyle(
    inherit: false,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    inherit: false,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMedium = TextStyle(
    inherit: false,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSmall = TextStyle(
    inherit: false,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    inherit: false,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static const TextStyle titleMedium = TextStyle(
    inherit: false,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  static const TextStyle titleSmall = TextStyle(
    inherit: false,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    inherit: false,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  static const TextStyle labelMedium = TextStyle(
    inherit: false,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSmall = TextStyle(
    inherit: false,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    inherit: false,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    inherit: false,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    inherit: false,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.onSurface,
  );

  // Estilos específicos do Premium
  static const TextStyle premiumTitle = TextStyle(
    inherit: false,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.premiumGold,
  );

  static const TextStyle premiumSubtitle = TextStyle(
    inherit: false,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  static const TextStyle premiumPrice = TextStyle(
    inherit: false,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.primary,
  );

  static const TextStyle premiumFeature = TextStyle(
    inherit: false,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurface,
  );

  // Estilos de botões
  static const TextStyle buttonLarge = TextStyle(
    inherit: false,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );

  static const TextStyle buttonMedium = TextStyle(
    inherit: false,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );

  static const TextStyle buttonSmall = TextStyle(
    inherit: false,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );
}