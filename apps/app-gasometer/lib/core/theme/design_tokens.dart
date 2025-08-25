import 'package:flutter/material.dart';

/// Design Tokens para consistência visual no GasOMeter
class GasometerDesignTokens {
  // SPACING TOKENS
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingXxxl = 32.0;
  
  // Semantic spacing
  static const double spacingCardPadding = spacingXl;          // 20.0
  static const double spacingItemSpacing = spacingMd;         // 12.0
  static const double spacingSectionSpacing = spacingXxl;     // 24.0
  static const double spacingPagePadding = spacingLg;         // 16.0
  static const double spacingDialogPadding = spacingXxl;      // 24.0
  
  // ICON SIZES
  static const double iconSizeXs = 16.0;
  static const double iconSizeSm = 20.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 28.0;
  static const double iconSizeXl = 32.0;
  static const double iconSizeXxl = 40.0;
  static const double iconSizeXxxl = 48.0;
  
  // Semantic icon sizes
  static const double iconSizeButton = iconSizeSm;            // 20.0
  static const double iconSizeListItem = iconSizeMd;          // 24.0
  static const double iconSizeHeader = iconSizeLg;            // 28.0
  static const double iconSizeFeature = iconSizeXl;           // 32.0
  static const double iconSizeAvatar = iconSizeXxl;           // 40.0
  
  // BORDER RADIUS
  static const double radiusXs = 4.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusRound = 50.0;
  
  // Semantic border radius
  static const double radiusButton = radiusMd;               // 8.0
  static const double radiusCard = radiusXl;                 // 16.0
  static const double radiusDialog = radiusLg;               // 12.0
  static const double radiusChip = radiusXxl;                // 20.0
  static const double radiusInput = radiusMd;                // 8.0
  
  // ELEVATION
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
  
  // Semantic elevation
  static const double elevationCard = elevationSm;           // 2.0
  static const double elevationButton = elevationSm;         // 2.0
  static const double elevationDialog = elevationLg;         // 8.0
  static const double elevationAppBar = elevationMd;         // 4.0
  
  // OPACITY
  static const double opacityDisabled = 0.38;
  static const double opacitySecondary = 0.6;
  static const double opacityHint = 0.5;
  static const double opacityDivider = 0.12;
  static const double opacityOverlay = 0.1;
  static const double opacityBackdrop = 0.5;
  
  // FONT WEIGHTS
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // FONT SIZES
  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeXxxl = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Semantic font sizes
  static const double fontSizeBody = fontSizeMd;             // 14.0
  static const double fontSizeBodyLarge = fontSizeLg;        // 16.0
  static const double fontSizeCaption = fontSizeSm;          // 12.0
  static const double fontSizeButton = fontSizeLg;           // 16.0
  static const double fontSizeHeading = fontSizeXl;          // 18.0
  static const double fontSizeTitle = fontSizeXxl;           // 20.0
  static const double fontSizeDisplayLarge = fontSizeDisplay; // 32.0
  
  // ANIMATION DURATIONS
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  
  // BREAKPOINTS
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1200.0;
  
  // CONSTRAINTS
  static const double maxWidthContent = 1200.0;
  static const double maxWidthDialog = 500.0;
  static const double minTouchTarget = 48.0;
  
  // HELPER METHODS
  
  /// Retorna espaçamento baseado no contexto
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);
  static EdgeInsets paddingHorizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets paddingVertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets paddingOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  
  /// Retorna BorderRadius baseado no token
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);
  static BorderRadius borderRadiusTop(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );
  static BorderRadius borderRadiusBottom(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );
  
  /// Helper para cores do tema com opacidade
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Helper para tamanhos responsivos
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
  
  /// Retorna padding adaptativo baseado no tamanho da tela
  static double adaptiveSpacing(BuildContext context) {
    if (isMobile(context)) return spacingLg;
    if (isTablet(context)) return spacingXl;
    return spacingXxl;
  }
  
  /// Retorna tamanho de ícone adaptativo
  static double adaptiveIconSize(BuildContext context) {
    if (isMobile(context)) return iconSizeMd;
    if (isTablet(context)) return iconSizeLg;
    return iconSizeXl;
  }
}

/// Extension para facilitar uso dos design tokens
extension GasometerDesignTokensExtension on BuildContext {
  /// Acesso rápido aos tokens de design
  static const tokens = GasometerDesignTokens;
  
  /// Verifica se é mobile
  bool get isMobile => GasometerDesignTokens.isMobile(this);
  
  /// Verifica se é tablet
  bool get isTablet => GasometerDesignTokens.isTablet(this);
  
  /// Verifica se é desktop
  bool get isDesktop => GasometerDesignTokens.isDesktop(this);
  
  /// Retorna espaçamento adaptativo
  double get adaptiveSpacing => GasometerDesignTokens.adaptiveSpacing(this);
  
  /// Retorna tamanho de ícone adaptativo
  double get adaptiveIconSize => GasometerDesignTokens.adaptiveIconSize(this);
}