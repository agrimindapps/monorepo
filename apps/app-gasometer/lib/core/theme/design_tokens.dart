import 'package:flutter/material.dart';

/// Design Tokens para consistência visual no GasOMeter
/// Centraliza cores, espaçamentos, tamanhos e outros valores de design
/// para garantir consistência visual e facilitar manutenção
class GasometerDesignTokens {
  // ============================================================================
  // COLOR DESIGN TOKENS
  // ============================================================================
  
  // PRIMARY BRAND COLORS
  static const Color colorPrimary = Color(0xFFFF5722);        // Deep Orange - Main brand color
  static const Color colorPrimaryLight = Color(0xFFFF8A65);   // Light orange variant
  static const Color colorPrimaryDark = Color(0xFFE64A19);    // Dark orange variant
  
  // SECONDARY COLORS
  static const Color colorSecondary = Color(0xFF2196F3);      // Blue for secondary actions
  static const Color colorSecondaryLight = Color(0xFF64B5F6); // Light blue variant
  static const Color colorSecondaryDark = Color(0xFF1976D2);  // Dark blue variant
  
  // ACCENT COLORS
  static const Color colorAccent = Color(0xFF4CAF50);         // Green for positive actions
  static const Color colorAccentLight = Color(0xFF81C784);    // Light green variant
  static const Color colorAccentDark = Color(0xFF388E3C);     // Dark green variant
  
  // HEADER/SURFACE COLORS
  static const Color colorHeaderBackground = Color(0xFF2C2C2E); // Dark header background
  static const Color colorSurface = Color(0xFFFFFFFF);          // Primary surface
  static const Color colorSurfaceVariant = Color(0xFFF8F9FA);   // Alternative surface
  static const Color colorBackground = Color(0xFFF5F5F5);       // Main background
  
  // PREMIUM COLORS
  static const Color colorPremiumAccent = Color(0xFFFFA500);     // Orange premium accent
  static const Color colorPremiumGold = Color(0xFFFFD700);       // Gold premium
  static const Color colorPremiumBackground = Color(0xFFFFA500); // Premium background overlay
  
  // STATUS COLORS
  static const Color colorSuccess = Color(0xFF4CAF50);          // Success states
  static const Color colorWarning = Color(0xFFFF9800);          // Warning states
  static const Color colorError = Color(0xFFF44336);            // Error states
  static const Color colorInfo = Color(0xFF2196F3);             // Info states
  
  // NEUTRAL COLORS (GRAYSCALE)
  static const Color colorNeutral50 = Color(0xFFFAFAFA);        // Lightest neutral
  static const Color colorNeutral100 = Color(0xFFF5F5F5);       // Very light neutral
  static const Color colorNeutral200 = Color(0xFFEEEEEE);       // Light neutral
  static const Color colorNeutral300 = Color(0xFFE0E0E0);       // Medium light neutral
  static const Color colorNeutral400 = Color(0xFFBDBDBD);       // Medium neutral
  static const Color colorNeutral500 = Color(0xFF9E9E9E);       // Base neutral
  static const Color colorNeutral600 = Color(0xFF757575);       // Medium dark neutral
  static const Color colorNeutral700 = Color(0xFF616161);       // Dark neutral
  static const Color colorNeutral800 = Color(0xFF424242);       // Very dark neutral
  static const Color colorNeutral900 = Color(0xFF212121);       // Darkest neutral
  
  // TEXT COLORS
  static const Color colorTextPrimary = Color(0xFF1C1B1F);      // Primary text
  static const Color colorTextSecondary = Color(0xFF757575);     // Secondary text
  static const Color colorTextOnPrimary = Color(0xFFFFFFFF);    // Text on primary background
  static const Color colorTextOnSurface = Color(0xFF1C1B1F);    // Text on surface
  
  // FUEL-SPECIFIC COLORS
  static const Color colorFuelGasoline = Color(0xFFFF5722);     // Gasoline orange
  static const Color colorFuelEthanol = Color(0xFF4CAF50);      // Ethanol green
  static const Color colorFuelDiesel = Color(0xFF795548);       // Diesel brown
  static const Color colorFuelGas = Color(0xFF9C27B0);          // Gas purple
  
  // REPORT/ANALYTICS COLORS
  static const Color colorAnalyticsBlue = Color(0xFF4299E1);    // Analytics blue
  static const Color colorAnalyticsGreen = Color(0xFF48BB78);   // Analytics green
  static const Color colorAnalyticsPurple = Color(0xFF9F7AEA);  // Analytics purple
  
  // FAQ/CONTENT COLORS
  static const Color colorContentBackground = Color(0xFFF8F9FA); // Content background
  
  // ============================================================================
  // COLOR HELPER METHODS
  // ============================================================================
  
  /// Returns fuel-specific color based on fuel type
  static Color getFuelTypeColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'gasoline':
      case 'gasolina':
        return colorFuelGasoline;
      case 'ethanol':
      case 'etanol':
        return colorFuelEthanol;
      case 'diesel':
        return colorFuelDiesel;
      case 'gas':
      case 'gnv':
        return colorFuelGas;
      default:
        return colorPrimary;
    }
  }
  
  /// Returns appropriate text color for given background
  static Color getTextColorForBackground(Color backgroundColor) {
    // Simple luminance calculation to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? colorTextPrimary : colorTextOnPrimary;
  }
  
  /// Returns premium background color with specified opacity
  static Color getPremiumBackgroundWithOpacity(double opacity) {
    return colorPremiumBackground.withOpacity(opacity);
  }
  
  /// Returns surface color based on elevation level
  static Color getSurfaceColorByElevation(int elevation) {
    switch (elevation) {
      case 0:
        return colorSurface;
      case 1:
        return colorSurfaceVariant;
      default:
        return colorNeutral50;
    }
  }
  
  // ============================================================================
  // SPACING TOKENS
  // ============================================================================
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
  
  // Form-specific semantic spacing (from UnifiedDesignTokens)
  static const double spacingFormField = 16.0;        // Entre campos de formulário
  static const double spacingSection = 24.0;          // Entre seções
  static const double spacingPageMargin = 20.0;       // Margens da página
  
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
    return color.withOpacity(opacity);
  }
  
  /// Helper para tamanhos responsivos
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointTablet;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointTablet && width < breakpointDesktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }
  
  /// Retorna espaçamento responsivo baseado no tamanho da tela (from UnifiedDesignTokens)
  static double responsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointTablet) return spacingLg;
    if (width < breakpointDesktop) return spacingXl;
    return spacingXxl;
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
  
  /// Retorna espaçamento responsivo (from UnifiedDesignTokens)
  double get responsiveSpacing => GasometerDesignTokens.responsiveSpacing(this);
  
  /// Retorna tamanho de ícone adaptativo
  double get adaptiveIconSize => GasometerDesignTokens.adaptiveIconSize(this);
}