import 'package:flutter/material.dart';

/// A centralized collection of constants for the Splash Screen feature.
///
/// This includes UI strings, layout values, colors, and animation timings
/// to ensure a consistent and polished launch experience.
class SplashConstants {
  SplashConstants._();

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String appName = 'PetiVeti';
    static const String appTagline = 'Complete care for your best friend';
    static const String appDescription =
        'The most complete app for owners who care about the health and well-being of their pets. Track vaccines, medications, weight, appointments, and much more.';
    static const String launchStatus = 'COMING SOON';
    static const String launchDateFormatted = '10/1/2025';
  }

  /// Constants for navigation routes.
  abstract class Routes {
    Routes._();
    static const String home = '/';
    static const String promo = '/promo';
  }

  /// Image and asset URLs.
  abstract class Images {
    Images._();
    static const String heroImageUrl =
        'https://fkjakafxqciukoesqvkp.supabase.co/storage/v1/object/public/agrihurb/website/vetipeti.png';
  }

  /// Constants for animation durations and curves.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Timings {
    Timings._();
    static const Duration animation = Duration(milliseconds: 1500);
    static const Duration splashMinimum = Duration(milliseconds: 2000);
    static const Interval fadeIn = Interval(0.0, 0.6, curve: Curves.easeIn);
    static const Interval scaleOut = Interval(0.2, 0.8, curve: Curves.elasticOut);
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const double fadeBeginValue = 0.0;
    static const double fadeEndValue = 1.0;
    static const double scaleBeginValue = 0.8;
    static const double scaleEndValue = 1.0;
    static const EdgeInsets logoPadding = EdgeInsets.all(32.0);
    static const double logoIconSize = 80.0;
    static const double logoShadowBlurRadius = 20.0;
    static const Offset logoShadowOffset = Offset(0, 10);
    static const double logoToTitleSpacing = 32.0;
    static const double titleToTaglineSpacing = 8.0;
    static const double taglineToIndicatorSpacing = 48.0;
    static const double progressIndicatorSize = 32.0;
    static const double progressIndicatorStrokeWidth = 3.0;
  }

  /// Color constants specific to the Splash Screen feature.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Colors {
    Colors._();
    static const Color primary = Color(0xFF6A1B9A); // Purple 800
    static const Color accent = Color(0xFF03A9F4); // Light Blue 500
    static const Color background = Color(0xFFF5F5F5);
    static const Color text = Color(0xFF333333);
    static const Color white = Colors.white;
    static const Color black = Colors.black;
    static const double logoShadowOpacity = 0.2;

    static final Color shadow = primary.withOpacity(logoShadowOpacity);

    static const List<Color> heroGradient = [
      Color(0xFF6A1B9A), // Purple 800
      Color(0xFF4A148C), // Purple 900
    ];

    // Feature colors used on the promo page.
    static const Color petProfiles = Color(0xFF6A1B9A);
    static const Color vaccines = Color(0xFFD32F2F);
    static const Color medications = Color(0xFF388E3C);
    static const Color weightControl = Color(0xFFFF8F00);
    static const Color appointments = Color(0xFF1976D2);
    static const Color reminders = Color(0xFF00796B);
  }
}