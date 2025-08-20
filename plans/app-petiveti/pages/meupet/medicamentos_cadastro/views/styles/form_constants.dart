class FormConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 6.0;
  
  static const double borderWidth = 1.0;
  static const double focusedBorderWidth = 2.0;
  
  static const double textFieldHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 32.0;
  
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;
  
  static const double dialogMaxWidth = 600.0;
  static const double dialogMaxHeight = 600.0;
  
  static const double loadingIndicatorSize = 24.0;
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Form field limits
  static const int maxNomeMedicamentoLength = 100;
  static const int maxDosagemLength = 50;
  static const int maxFrequenciaLength = 50;
  static const int maxDuracaoLength = 50;
  static const int maxObservacoesLength = 500;
  
  // Validation limits
  static const int minFieldLength = 2;
  static const int minFrequenciaLength = 3;
  static const int maxTreatmentDurationDays = 730; // 2 years
  static const int minTreatmentDurationHours = 1;
  
  // Layout
  static const double formScrollViewHeight = 400.0;
  static const double fieldLabelFontSize = 16.0;
  static const double fieldHintFontSize = 14.0;
  static const double errorTextFontSize = 12.0;
}