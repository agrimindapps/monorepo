/// Core UI constants for consistent design system
/// Contains all hardcoded values used across the app
library;

import 'package:flutter/material.dart';

/// Spacing and sizing constants
class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 20.0;
  static const double xxlarge = 24.0;
  static const double xxxlarge = 32.0;
  static const double spacingXS = 2.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double cardPadding = 16.0;
  static const double listItemPadding = 16.0;
  static const double dialogPadding = 24.0;
}

/// Icon and image sizing constants
class AppSizes {
  static const double iconXS = 16.0;
  static const double iconS = 20.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  static const double imageThumbSize = 120.0;
  static const double imagePreviewHeight = 200.0;
  static const double imagePreviewMaxHeight = 400.0;
  static const double imageDialogMaxWidth = 600.0;
  static const double inputHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double minButtonWidth = 120.0;
  static const double maxContentWidth = 400.0;
  static const double listItemHeight = 72.0;
  static const int defaultPageSize = 20;
}

/// Border radius constants
class AppRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xlarge = 16.0;
  static const double round = 50.0;
}

/// Animation and duration constants  
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration loading = Duration(milliseconds: 800);
  static const Duration shimmerAnimation = Duration(milliseconds: 1200);
  static const Duration fadeTransition = Duration(milliseconds: 250);
  static const Duration slideTransition = Duration(milliseconds: 350);
}

/// Opacity and alpha constants
class AppOpacity {
  static const double disabled = 0.3;
  static const double subtle = 0.5;
  static const double medium = 0.6;
  static const double prominent = 0.7;
  static const double overlay = 0.8;
  static const double strong = 0.9;
}

/// Font weight and typography constants
class AppFontWeights {
  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
}

/// Font size constants
class AppFontSizes {
  static const double xs = 10.0;
  static const double small = 12.0;
  static const double body = 14.0;
  static const double medium = 16.0;
  static const double large = 18.0;
  static const double title = 20.0;
  static const double heading = 24.0;
  static const double display = 32.0;
}

/// Elevation and shadow constants
class AppElevations {
  static const double none = 0.0;
  static const double low = 1.0;
  static const double medium = 3.0;
  static const double high = 6.0;
  static const double highest = 12.0;
}

/// Layout and constraint constants
class AppConstraints {
  static const double minScreenWidth = 320.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
  static const double maxFormWidth = 500.0;
  static const double minFieldHeight = 48.0;
  static const double maxDialogWidth = 600.0;
  static const double minDialogHeight = 200.0;
}

/// Network and pagination constants
class AppDefaults {
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int analyticsFlushSize = 50;
  static const int defaultLicenseDays = 30;
  static const int minSignalStrength = 0;
  static const int maxSignalStrength = 100;
}