import 'package:flutter/material.dart';

/// A centralized collection of constants for the Body Condition Score (BCS) feature.
///
/// This includes UI strings, accessibility labels, layout values, and icons
/// to ensure consistency and ease of maintenance.
class BodyConditionConstants {
  BodyConditionConstants._();

  // --- Feature-level Constants ---
  static const int tabCount = 3;
  static const int inputTabIndex = 0;
  static const int resultTabIndex = 1;
  static const int historyTabIndex = 2;

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String appBarTitle = 'Body Condition Score (BCS)';
    static const String emptyResultTitle = 'No results yet';
    static const String emptyResultDescription =
        'Fill in the data on the "Input" tab and tap "Calculate"';
    static const String emptyHistoryTitle = 'No history yet';
    static const String emptyHistoryDescription =
        'Calculation results will appear here';
    static const String calculateButtonText = 'Calculate BCS';
    static const String calculatingButtonText = 'Calculating...';
    static const TextAlign emptyStateTextAlign = TextAlign.center;
    static const TabBarIndicatorSize tabBarIndicatorSize = TabBarIndicatorSize.tab;
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String helpTooltip = 'BCS Guide';
  }

  /// Icon constants for the Body Condition feature.
  abstract class Icons {
    Icons._();
    static const IconData back = Icons.arrow_back;
    static const IconData help = Icons.help_outline;
    static const IconData emptyResult = Icons.analytics_outlined;
    static const IconData emptyHistory = Icons.history;
    static const IconData calculate = Icons.calculate;
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const EdgeInsets tabPadding = EdgeInsets.all(16.0);
    static const double emptyStateIconSize = 64.0;
    static const double emptyStateTitleFontSize = 18.0;
    static const FontWeight emptyStateTitleWeight = FontWeight.bold;
    static const double emptyStateIconSpacing = 16.0;
    static const double emptyStateTitleSpacing = 8.0;
    static const double fabLoadingIndicatorSize = 16.0;
    static const double fabLoadingStrokeWidth = 2.0;
  }

  /// Color constants specific to the Body Condition feature.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Colors {
    Colors._();
    static const Color emptyStateIcon = Colors.grey;
    static const Color emptyStateText = Colors.grey;
    static const Color fabDisabled = Colors.grey;
    static const Color fabLoadingIndicator = Colors.white;
  }
}