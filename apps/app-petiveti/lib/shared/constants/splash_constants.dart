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
  static const String appTagline = 'Cuidando do seu melhor amigo';

  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
}

/// Color constants for the splash page
class SplashColors {
  // Private constructor to prevent instantiation
  SplashColors._();

  // Background colors
  static Color backgroundColor = Colors.blue[50]!;
  static const Color logoContainerColor = Colors.white;
  static const Color logoIconColor = Colors.blue;

  // Text colors
  static Color titleColor = Colors.blue[700]!;
  static Color taglineColor = Colors.blue[600]!;

  // Progress indicator color
  static Color progressIndicatorColor = Colors.blue[400]!;

  // Shadow color
  static Color shadowColor = Colors.blue.withValues(alpha: SplashConstants.logoShadowOpacity);
}