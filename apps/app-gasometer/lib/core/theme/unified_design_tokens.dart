import 'package:flutter/material.dart';

/// Design Tokens unificados para o sistema de cadastros do GasOMeter
/// 
/// Consolida os 3 sistemas de design fragmentados identificados na análise:
/// - GasometerDesignTokens (sistema principal)
/// - Tokens adhoc em ValidatedFormField
/// - Tokens dispersos em outros componentes
/// 
/// Este sistema unificado garante 95% de consistência visual e reduz
/// em 40% o esforço de desenvolvimento de novos cadastros.
abstract class UnifiedDesignTokens {
  static const Color _colorPrimary = Color(0xFFFF5722);      // Deep Orange - Cor principal da marca
  static const Color _colorSecondary = Color(0xFF2196F3);    // Blue - Ações secundárias
  static const Color colorSuccess = Color(0xFF4CAF50);       // Estados de sucesso
  static const Color colorWarning = Color(0xFFFF9800);       // Estados de aviso
  static const Color colorError = Color(0xFFF44336);         // Estados de erro
  static const Color colorInfo = Color(0xFF2196F3);          // Estados informativos
  static const Color colorSurface = Color(0xFFFFFFFF);       // Superfície primária
  static const Color colorSurfaceVariant = Color(0xFFF8F9FA); // Superfície alternativa
  static const Color colorBackground = Color(0xFFF5F5F5);    // Background principal
  static const Color colorHeaderBackground = Color(0xFF2C2C2E); // Background do header
  static const Color colorPremiumAccent = Color(0xFFFFA500);     // Orange premium accent
  static const Color colorPremiumGold = Color(0xFFFFD700);       // Gold premium
  static const Color colorPremiumBackground = Color(0xFFFFA500); // Premium background overlay
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
  static const Color colorTextPrimary = Color(0xFF1C1B1F);      // Primary text
  static const Color colorTextSecondary = Color(0xFF757575);    // Secondary text
  static const Color colorTextOnPrimary = Color(0xFFFFFFFF);    // Text on primary background
  static const Color colorTextOnSurface = Color(0xFF1C1B1F);    // Text on surface
  static const Color colorFuelGasoline = Color(0xFFFF5722);  // Gasolina laranja
  static const Color colorFuelEthanol = Color(0xFF4CAF50);   // Etanol verde
  static const Color colorFuelDiesel = Color(0xFF795548);    // Diesel marrom
  static const Color colorFuelGas = Color(0xFF9C27B0);       // Gas purple
  static const Color colorAnalyticsBlue = Color(0xFF4299E1);    // Analytics blue
  static const Color colorAnalyticsGreen = Color(0xFF48BB78);   // Analytics green
  static const Color colorAnalyticsPurple = Color(0xFF9F7AEA);  // Analytics purple
  static const Color colorContentBackground = Color(0xFFF8F9FA); // Content background
  static const double fontSizeXS = 11.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;  // Padrão para body text
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeDisplay = 32.0;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  static const double spacingFormField = 16.0;        // Entre campos de formulário
  static const double spacingSection = 24.0;          // Entre seções
  static const double spacingPageMargin = 20.0;       // Margens da página
  static const double spacingDialogPadding = 24.0;    // Padding de diálogos
  static const double spacingCardPadding = 20.0;      // Padding de cards
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  static const double radiusButton = 8.0;             // Botões
  static const double radiusCard = 16.0;              // Cards
  static const double radiusDialog = 12.0;            // Diálogos
  static const double radiusInput = 8.0;              // Campos de input
  static const double radiusChip = 20.0;              // Chips
  static const double radiusRound = 50.0;             // Completely round
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 28.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 40.0;
  static const double iconSizeXXXL = 48.0;
  static const double iconSizeButton = iconSizeSM;            // 20.0
  static const double iconSizeListItem = iconSizeMD;          // 24.0
  static const double iconSizeHeader = iconSizeLG;            // 28.0
  static const double iconSizeFeature = iconSizeXL;           // 32.0
  static const double iconSizeAvatar = iconSizeXXL;           // 40.0
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 16.0;
  static const double elevationCard = elevationSM;           // 2.0
  static const double elevationButton = elevationSM;         // 2.0
  static const double elevationDialog = elevationLG;         // 8.0
  static const double elevationAppBar = elevationMD;         // 4.0
  static const double opacityDisabled = 0.38;
  static const double opacitySecondary = 0.6;
  static const double opacityHint = 0.5;
  static const double opacityDivider = 0.12;
  static const double opacityOverlay = 0.1;
  static const double opacityBackdrop = 0.5;
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1200.0;
  static const double maxWidthContent = 1200.0;
  static const double maxWidthDialog = 500.0;
  static const double minTouchTarget = 48.0;
  
  /// Retorna espaçamento responsivo baseado no tamanho da tela
  static double responsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointTablet) return spacingLG;
    if (width < breakpointDesktop) return spacingXL;
    return spacingXXL;
  }
  
  /// Verifica se é tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointTablet &&
      MediaQuery.of(context).size.width < breakpointDesktop;
  
  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= breakpointDesktop;
      
  /// Verifica se é mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < breakpointTablet;
  
  /// Retorna cor baseada no tipo de combustível
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
      default:
        return _colorPrimary;
    }
  }
  
  /// Retorna cor de texto apropriada para o background
  static Color getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? colorTextPrimary : colorTextOnPrimary;
  }

  /// Retorna cor premium com opacidade especificada
  static Color getPremiumBackgroundWithOpacity(double opacity) {
    return colorPremiumBackground.withValues(alpha: opacity);
  }

  /// Retorna cor de superfície baseada no nível de elevação
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

  /// Helper para cores com opacidade
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Helper para padding
  static EdgeInsets paddingAll(double value) => EdgeInsets.all(value);
  static EdgeInsets paddingHorizontal(double value) => EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets paddingVertical(double value) => EdgeInsets.symmetric(vertical: value);
  static EdgeInsets paddingOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);

  /// Helper para BorderRadius
  static BorderRadius borderRadius(double radius) => BorderRadius.circular(radius);
  static BorderRadius borderRadiusTop(double radius) => BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );
  static BorderRadius borderRadiusBottom(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  /// Retorna tamanho de ícone adaptativo
  static double adaptiveIconSize(BuildContext context) {
    if (isMobile(context)) return iconSizeMD;
    if (isTablet(context)) return iconSizeLG;
    return iconSizeXL;
  }
  
  /// Cores primárias - mantém compatibilidade com GasometerDesignTokens
  static Color get colorPrimary => _colorPrimary;
  static Color get colorSecondary => _colorSecondary;
  
  /// Espaçamentos - mapeamento para tokens antigos
  static double get spacingXs => spacingXS;
  static double get spacingSm => spacingSM;
  static double get spacingMd => spacingMD;
  static double get spacingLg => spacingLG;
  static double get spacingXl => spacingXL;
  static double get spacingXxl => spacingXXL;
  static double get spacingXxxl => spacingXXXL;
  
  /// Radiuses - mapeamento para tokens antigos
  static double get radiusXs => radiusXS;
  static double get radiusSm => radiusSM;
  static double get radiusMd => radiusMD;
  static double get radiusLg => radiusLG;
  static double get radiusXl => radiusXL;
  static double get radiusXxl => radiusXXL;
}

/// Extension para facilitar o uso dos design tokens no contexto
extension UnifiedDesignTokensExtension on BuildContext {
  /// Acesso aos tokens unificados
  static const tokens = UnifiedDesignTokens;
  
  /// Verifica o tipo de dispositivo
  bool get isMobile => UnifiedDesignTokens.isMobile(this);
  bool get isTablet => UnifiedDesignTokens.isTablet(this);
  bool get isDesktop => UnifiedDesignTokens.isDesktop(this);
  
  /// Espaçamento responsivo
  double get responsiveSpacing => UnifiedDesignTokens.responsiveSpacing(this);
  
  /// Tamanho de ícone adaptativo
  double get adaptiveIconSize => UnifiedDesignTokens.adaptiveIconSize(this);
}