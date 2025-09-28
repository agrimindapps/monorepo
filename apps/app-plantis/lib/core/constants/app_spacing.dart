/// App-wide spacing and padding constants
/// This ensures consistent spacing throughout the application
class AppSpacing {
  AppSpacing._();

  // Base spacing units
  static const double xs = 4.0; // Extra small spacing
  static const double sm = 8.0; // Small spacing
  static const double md = 12.0; // Medium spacing
  static const double lg = 16.0; // Large spacing
  static const double xl = 20.0; // Extra large spacing
  static const double xxl = 24.0; // Extra extra large spacing
  static const double xxxl = 32.0; // Triple extra large spacing

  // Specific spacing values used in plant details
  static const double cardPadding = lg; // 16.0
  static const double screenPadding = lg; // 16.0
  static const double sectionSpacing = xxl; // 24.0
  static const double buttonSpacing = md; // 12.0
  static const double modalPadding = xxl; // 24.0
  static const double tabPadding = xs; // 4.0
  static const double iconPadding = sm; // 8.0
  static const double listItemSpacing = lg; // 16.0

  // Border radius values
  static const double borderRadiusSmall = sm; // 8.0
  static const double borderRadiusMedium = md; // 12.0
  static const double borderRadiusLarge = xl; // 20.0
  static const double borderRadiusCard = md; // 12.0
  static const double borderRadiusModal = xl; // 20.0
  static const double borderRadiusButton = md; // 12.0
  static const double borderRadiusCircular = 40.0; // Full circular

  // Container dimensions
  static const double appBarHeight = 200.0;
  static const double loadingImageHeight = 200.0;
  static const double iconSize = 80.0;
  static const double largeIconSize = 120.0;
  static const double tabHeight = 48.0;
  static const double handleHeight = 4.0;
  static const double handleWidth = 40.0;

  // Elevation and blur values
  static const double shadowBlurRadius = 8.0;
  static const double shadowBlurRadiusLarge = 10.0;
  static const double shadowOffset = 2.0;
  static const double strokeWidth = 3.0;
  static const double tipBulletSize = 4.0;
}
