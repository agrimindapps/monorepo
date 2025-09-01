import 'package:flutter/material.dart';

/// Constants for the splash page animations, timing, and UI elements
class SplashConstants {
  // Private constructor to prevent instantiation
  SplashConstants._();

  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration splashMinimumDuration = Duration(milliseconds: 2000);

  // Animation curves and intervals
  static const Curve fadeInCurve = Curves.easeIn;
  static const Curve scaleOutCurve = Curves.elasticOut;
  static const Interval fadeInterval = Interval(0.0, 0.6, curve: fadeInCurve);
  static const Interval scaleInterval = Interval(0.2, 0.8, curve: scaleOutCurve);

  // Animation values
  static const double fadeBeginValue = 0.0;
  static const double fadeEndValue = 1.0;
  static const double scaleBeginValue = 0.8;
  static const double scaleEndValue = 1.0;

  // Logo container dimensions and styling
  static const EdgeInsets logoContainerPadding = EdgeInsets.all(32.0);
  static const double logoIconSize = 80.0;
  static const double logoShadowBlurRadius = 20.0;
  static const Offset logoShadowOffset = Offset(0, 10);
  static const double logoShadowOpacity = 0.2;

  // Spacing values
  static const double logoToTitleSpacing = 32.0;
  static const double titleToTaglineSpacing = 8.0;
  static const double taglineToIndicatorSpacing = 48.0;

  // Progress indicator dimensions
  static const double progressIndicatorSize = 32.0;
  static const double progressIndicatorStrokeWidth = 3.0;

  // App text content
  static const String appName = 'PetiVeti';
  static const String appTagline = 'Cuidados completos para seu melhor amigo';
  static const String appDescription = 'O aplicativo mais completo para tutores que se preocupam com a saúde e bem-estar de seus pets. Acompanhe vacinas, medicamentos, peso, consultas e muito mais.';
  static const String launchStatus = 'EM BREVE';
  
  // Launch Information
  static final DateTime launchDate = DateTime(2025, 10, 1);
  static const String launchDateFormatted = '1/10/2025';
  
  // Hero image URL
  static const String heroImageUrl = 'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png';

  // Routes
  static const String homeRoute = '/';
  static const String promoRoute = '/promo';
}

/// Color constants for the splash page and promo
/// For theme-aware colors, use these methods with Theme.of(context)
class SplashColors {
  // Private constructor to prevent instantiation
  SplashColors._();

  // Main Theme Colors
  static const Color primaryColor = Color(0xFF6A1B9A); // Purple 800
  static const Color accentColor = Color(0xFF03A9F4); // Light Blue 500
  static const Color backgroundColor = Color(0xFFF5F5F5); // Grey 100
  static const Color textColor = Color(0xFF333333); // Dark Grey
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;

  // Feature Colors
  static const Color petProfilesColor = Color(0xFF6A1B9A); // Purple 700
  static const Color vaccinesColor = Color(0xFFD32F2F); // Red 600
  static const Color medicationsColor = Color(0xFF388E3C); // Green 700
  static const Color weightControlColor = Color(0xFFFF8F00); // Orange 700
  static const Color appointmentsColor = Color(0xFF1976D2); // Blue 600
  static const Color remindersColor = Color(0xFF00796B); // Teal 700

  // Hero Gradient
  static const List<Color> heroGradient = [
    Color(0xFF6A1B9A), // Purple 800
    Color(0xFF4A148C), // Purple 900
  ];

  // Background colors
  static Color getBackgroundColor(BuildContext context) => backgroundColor;
      
  static Color getLogoContainerColor(BuildContext context) => 
      Theme.of(context).colorScheme.surface;
      
  static Color getLogoIconColor(BuildContext context) => 
      Theme.of(context).colorScheme.primary;

  // Text colors
  static Color getTitleColor(BuildContext context) => 
      Theme.of(context).colorScheme.primary;
      
  static Color getTaglineColor(BuildContext context) => 
      Theme.of(context).colorScheme.onSurfaceVariant;

  // Progress indicator color
  static Color getProgressIndicatorColor(BuildContext context) => 
      Theme.of(context).colorScheme.primary;

  // Shadow color
  static Color getShadowColor(BuildContext context) => 
      Theme.of(context).colorScheme.primary.withValues(alpha: SplashConstants.logoShadowOpacity);
      
  // Legacy static colors for backwards compatibility (removed duplicate backgroundColor)
  static const Color logoContainerColor = Colors.white;
  static const Color logoIconColor = Colors.blue;
  static Color titleColor = Colors.blue[700]!;
  static Color taglineColor = Colors.blue[600]!;
  static Color progressIndicatorColor = Colors.blue[400]!;
  static Color shadowColor = Colors.blue.withValues(alpha: SplashConstants.logoShadowOpacity);
}