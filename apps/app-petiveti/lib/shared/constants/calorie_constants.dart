import 'package:flutter/material.dart';

/// Constants for the calorie calculator page animations, dimensions, and UI elements
class CalorieConstants {
  // Private constructor to prevent instantiation
  CalorieConstants._();

  // Animation durations
  static const Duration progressContainerAnimationDuration = Duration(milliseconds: 300);
  static const Duration navigationButtonAnimationDuration = Duration(milliseconds: 200);
  static const Duration animatedSwitcherDuration = Duration(milliseconds: 200);

  // Progress indicator container
  static const EdgeInsets progressIndicatorPadding = EdgeInsets.all(16.0);
  static const double progressShadowBlurRadius = 4.0;
  static const double progressShadowBlurRadiusLoading = 6.0;
  static const Offset progressShadowOffset = Offset(0, 2);
  static const double progressShadowOpacity = 0.1;
  static const double progressShadowOpacityLoading = 0.15;
  static const double progressContainerOpacity = 0.5;
  static const double progressOverlayOpacity = 0.3;
  static const double progressBorderRadius = 8.0;

  // Loading indicator dimensions
  static const double loadingIndicatorSize = 16.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
  static const double loadingSpacing = 8.0;

  // Text styling
  static const double processingTextSize = 12.0;
  static const FontWeight processingTextWeight = FontWeight.w500;

  // Main content padding
  static const EdgeInsets mainContentPadding = EdgeInsets.all(16.0);
  static const double actionButtonsSpacing = 16.0;

  // Navigation bar
  static const EdgeInsets navigationBarPadding = EdgeInsets.all(16.0);
  static const double navigationBorderOpacity = 0.2;
  static const double navigationButtonSpacing = 16.0;

  // App text content
  static const String appBarTitle = 'Necessidades Calóricas';
  static const String helpTooltip = 'Guia de Cálculo';
  static const String processingText = 'Processando...';
  static const String backButtonText = 'Voltar';
  static const String shareButtonText = 'Compartilhar';
  static const String newCalculationButtonText = 'Novo Cálculo';
  static const String calculateButtonText = 'Calcular';
  static const String advanceButtonText = 'Avançar';
  static const String calculatingText = 'Calculando...';
  static const String loadingText = 'Carregando...';

  // Animation keys
  static const String loadingAnimationKey = 'loading';
  static const String normalAnimationKey = 'normal';

  // Step navigation
  static const int reviewStepIndex = 4;
  static const int firstStepIndex = 0;
  
  // Animation values
  static const double defaultOpacityValue = 1.0;
}

/// Color constants for the calorie calculator page
class CalorieColors {
  // Private constructor to prevent instantiation
  CalorieColors._();

  // Default opacity values for theme-based colors
  static const double primaryContainerOpacity = 0.5;
  static const double surfaceOverlayOpacity = 0.3;
  static const double borderOpacity = 0.2;
  static const double shadowOpacity = 0.1;
  static const double shadowOpacityLoading = 0.15;
}

/// Layout constants for responsive design
class CalorieLayout {
  // Private constructor to prevent instantiation
  CalorieLayout._();

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Adaptive spacing
  static const double mobileSpacing = 16.0;
  static const double tabletSpacing = 24.0;
  static const double desktopSpacing = 32.0;

  // Button dimensions
  static const double minButtonHeight = 48.0;
  static const double minButtonWidth = 120.0;
}