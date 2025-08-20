/// Constants for vaccine registration form layout and dimensions
class FormConstants {
  // Dialog dimensions
  static const double dialogMaxWidth = 500.0;
  static const double dialogMaxHeight = 600.0;
  static const double dialogMinHeight = 400.0;
  
  // Spacing and padding
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Field dimensions
  static const double fieldHeight = 56.0;
  static const double fieldBorderRadius = 8.0;
  static const double fieldBorderWidth = 1.0;
  static const double fieldBorderFocusedWidth = 2.0;
  
  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 8.0;
  static const double buttonElevation = 2.0;
  static const double buttonMinWidth = 120.0;
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Text field constraints
  static const int maxVaccineNameLength = 100;
  static const int maxObservationsLength = 500;
  static const int minVaccineNameLength = 2;
  
  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Form validation
  static const Duration validationDebounce = Duration(milliseconds: 500);
  static const Duration autoSaveDelay = Duration(seconds: 2);
  
  // Loading overlay
  static const double loadingOverlayOpacity = 0.7;
  static const double loadingIndicatorSize = 50.0;
  
  // Error display
  static const double errorIconSize = 20.0;
  static const double errorPadding = 8.0;
  
  // Date picker
  static const double datePickerHeight = 400.0;
  static const double datePickerWidth = 320.0;
  
  // Character counter
  static const double counterFontSize = 12.0;
  static const double counterPadding = 4.0;
  
  // Form sections
  static const double sectionSpacing = 20.0;
  static const double fieldSpacing = 16.0;
  static const double buttonSpacing = 12.0;
  
  // Card styling
  static const double cardElevation = 4.0;
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 16.0;
  
  // Shadow
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 2.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = 2.0;
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  
  // Z-index values
  static const int zIndexDialog = 100;
  static const int zIndexLoading = 200;
  static const int zIndexError = 150;
  
  // Form field types
  static const String fieldTypeText = 'text';
  static const String fieldTypeDate = 'date';
  static const String fieldTypeTextArea = 'textarea';
}