import 'package:flutter/material.dart';

/// A centralized collection of constants for the Calorie Calculator feature.
///
/// This includes UI strings, accessibility labels, layout values, and animation
/// durations to ensure consistency and ease of maintenance.
class CalorieConstants {
  CalorieConstants._();

  // --- Feature-level Constants ---
  static const int reviewStepIndex = 4;
  static const int firstStepIndex = 0;

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String appBarTitle = 'Calorie Needs';
    static const String processingText = 'Processing...';
    static const String backButtonText = 'Back';
    static const String shareButtonText = 'Share';
    static const String newCalculationButtonText = 'New Calculation';
    static const String calculateButtonText = 'Calculate';
    static const String advanceButtonText = 'Next';
    static const String calculatingText = 'Calculating...';
    static const String loadingText = 'Loading...';
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String helpTooltip = 'Calculation Guide';
  }

  /// Constants for animation keys.
  abstract class Keys {
    Keys._();
    static const String loadingAnimationKey = 'loading';
    static const String normalAnimationKey = 'normal';
  }

  /// Constants for animation durations.
  abstract class Durations {
    Durations._();
    static const Duration progressContainer = Duration(milliseconds: 300);
    static const Duration navigationButton = Duration(milliseconds: 200);
    static const Duration animatedSwitcher = Duration(milliseconds: 200);
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const EdgeInsets progressIndicatorPadding = EdgeInsets.all(16.0);
    static const EdgeInsets mainContentPadding = EdgeInsets.all(16.0);
    static const EdgeInsets navigationBarPadding = EdgeInsets.all(16.0);
    static const double progressShadowBlurRadius = 4.0;
    static const double progressShadowBlurRadiusLoading = 6.0;
    static const Offset progressShadowOffset = Offset(0, 2);
    static const double progressBorderRadius = 8.0;
    static const double loadingIndicatorSize = 16.0;
    static const double loadingIndicatorStrokeWidth = 2.0;
    static const double loadingSpacing = 8.0;
    static const double processingTextSize = 12.0;
    static const FontWeight processingTextWeight = FontWeight.w500;
    static const double actionButtonsSpacing = 16.0;
    static const double navigationButtonSpacing = 16.0;
    static const double minButtonHeight = 48.0;
    static const double minButtonWidth = 120.0;
  }

  /// Opacity values.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Opacities {
    Opacities._();
    static const double progressShadow = 0.1;
    static const double progressShadowLoading = 0.15;
    static const double progressContainer = 0.5;
    static const double progressOverlay = 0.3;
    static const double navigationBorder = 0.2;
    static const double defaultOpacity = 1.0;
  }

  /// Breakpoints for responsive design.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Layout {
    Layout._();
    static const double mobileBreakpoint = 600.0;
    static const double tabletBreakpoint = 900.0;
    static const double desktopBreakpoint = 1200.0;
    static const double mobileSpacing = 16.0;
    static const double tabletSpacing = 24.0;
    static const double desktopSpacing = 32.0;
  }
}