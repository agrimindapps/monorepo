class MedicamentosConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 6.0;
  static const double statusIndicatorBorderRadius = 12.0;
  
  static const double borderWidth = 1.0;
  static const double focusedBorderWidth = 2.0;
  
  static const double cardElevation = 2.0;
  static const double dialogElevation = 8.0;
  
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  static const double statusIconSize = 64.0;
  
  static const double listItemHeight = 80.0;
  static const double headerHeight = 120.0;
  
  static const double maxContentWidth = 1020.0;
  static const double noDataMessageWidth = 300.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Text limits
  static const int maxNomeMedicamentoLength = 100;
  static const int maxDosagemLength = 50;
  static const int maxObservacoesLength = 500;
  static const int maxSearchLength = 100;
  
  // Business rules
  static const int maxTreatmentDurationDays = 730; // 2 years
  static const int minTreatmentDurationDays = 1;
  static const int urgentThresholdDays = 3;
  static const int defaultDateRangeDays = 30;
  
  // Layout breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}