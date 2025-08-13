// Flutter imports:
import 'package:flutter/material.dart';

class LayoutConstants {
  // Device breakpoints
  static const double smallDeviceMaxWidth = 360;
  static const double mediumDeviceMaxWidth = 600;
  static const double responsiveLayoutBreakpoint = 320;

  // Padding and margins
  static const double defaultPadding = 12.0;
  static const double cardPadding = 16.0;
  static const double listItemPadding = 15.0;
  static const double categoryButtonPadding = 12.0;
  static const double sectionTitleVerticalPadding = 16.0;
  static const double sectionTitleHorizontalPadding = 4.0;

  // Spacing
  static const double smallSpacing = 4.0;
  static const double defaultSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 32.0;
  static const double extraLargeSpacing = 40.0;

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 4.0;
  static const double categoryButtonBorderRadius = 15.0;
  static const double badgeBorderRadius = 12.0;

  // Widget dimensions
  static const double categoryButtonHeight = 90.0;
  static const double listItemHeight = 70.0;
  static const double sectionTitleIndicatorWidth = 6.0;
  static const double sectionTitleIndicatorHeight = 24.0;
  static const double sectionTitleDividerHeight = 1.0;
  static const double listSeparatorHeight = 1.0;
  static const double listSeparatorIndent = 10.0;
  static const double backgroundIconSize = 70.0;
  static const double categoryIconSize = 22.0;
  static const double sectionTitleIconSize = 20.0;
  static const double listItemIconSize = 18.0;
  static const double smallIconSize = 14.0;
  static const double tagIconSize = 10.0;

  // Layout calculations
  static const double categoryButtonMargin = 16.0;
  static const double categoryButtonSpacing = 32.0;
  static const double categoryButtonLargeSpacing = 40.0;

  // List item specifics
  static const double splashRadius = 20.0;
  static const EdgeInsetsDirectional listItemContentPadding =
      EdgeInsetsDirectional.fromSTEB(15, 0, 10, 0);
  static const VisualDensity compactVisualDensity =
      VisualDensity(horizontal: 0, vertical: -1);
}

class AnimationConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Loading timeouts
  static const Duration initializationTimeout = Duration(seconds: 30);
  static const Duration dataLoadTimeout = Duration(seconds: 20);
  static const Duration refreshTimeout = Duration(seconds: 30);

  // Retry delays
  static const Duration baseRetryDelay = Duration(milliseconds: 500);
  static const Duration exponentialRetryBase = Duration(milliseconds: 1000);

  // State management timeouts
  static const int maxRetryAttempts = 3;
  static const int maxRefreshAttempts = 2;
  static const int maxStateLogEntries = 20;
}

class SizeConstants {
  // Font sizes
  static const double largeFontSize = 18.0;
  static const double defaultFontSize = 16.0;
  static const double mediumFontSize = 14.0;
  static const double smallFontSize = 12.0;
  static const double extraSmallFontSize = 10.0;

  // Letter spacing
  static const double defaultLetterSpacing = 0.5;
}

class ColorConstants {
  // Green color variations
  static const int greenShade100 = 100;
  static const int greenShade200 = 200;
  static const int greenShade400 = 400;
  static const int greenShade600 = 600;
  static const int greenShade700 = 700;
  static const int greenShade800 = 800;

  // Grey color variations
  static const int greyShade400 = 400;
  static const int greyShade500 = 500;
  static const int greyShade600 = 600;
  static const int greyShade700 = 700;

  // Opacity values
  static const double lowOpacity = 0.1;
  static const double shadowOpacity = 0.3;
  static const double mediumOpacity = 0.5;
  static const double highOpacity = 0.7;
  static const double veryHighOpacity = 0.9;
}

class ElevationConstants {
  static const double cardElevation = 0.0; // Removida elevação dos cards
  static const double shadowBlurRadius = 8.0;
  static const double shadowBlurRadiusSmall = 3.0;
  static const Offset shadowOffset = Offset(0, 3);
  static const Offset textShadowOffset = Offset(0, 1);
}
