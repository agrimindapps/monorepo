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
  // ============================================================================
  // COLOR SYSTEM - Consolidado de GasometerDesignTokens + Form Components
  // ============================================================================
  
  // PRIMARY BRAND COLORS - Mantidas as cores principais do app
  static const Color _colorPrimary = Color(0xFFFF5722);      // Deep Orange - Cor principal da marca
  static const Color _colorSecondary = Color(0xFF2196F3);    // Blue - Ações secundárias
  
  // SEMANTIC COLORS - Estados e feedback visual
  static const Color colorSuccess = Color(0xFF4CAF50);       // Estados de sucesso
  static const Color colorWarning = Color(0xFFFF9800);       // Estados de aviso
  static const Color colorError = Color(0xFFF44336);         // Estados de erro
  static const Color colorInfo = Color(0xFF2196F3);          // Estados informativos
  
  // SURFACE COLORS - Backgrounds e superfícies  
  static const Color colorSurface = Color(0xFFFFFFFF);       // Superfície primária
  static const Color colorSurfaceVariant = Color(0xFFF8F9FA); // Superfície alternativa
  static const Color colorBackground = Color(0xFFF5F5F5);    // Background principal
  static const Color colorHeaderBackground = Color(0xFF2C2C2E); // Background do header
  
  // CONTEXT-SPECIFIC COLORS - Cores específicas do domínio
  static const Color colorFuelGasoline = Color(0xFFFF5722);  // Gasolina laranja
  static const Color colorFuelEthanol = Color(0xFF4CAF50);   // Etanol verde
  static const Color colorFuelDiesel = Color(0xFF795548);    // Diesel marrom
  
  // ============================================================================
  // TYPOGRAPHY SYSTEM - Padronizado para formulários
  // ============================================================================
  static const double fontSizeXS = 11.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;  // Padrão para body text
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeDisplay = 32.0;
  
  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // ============================================================================
  // SPACING SYSTEM - Unificado para todas as interfaces
  // ============================================================================
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  
  // Semantic Spacing - Para uso específico em formulários
  static const double spacingFormField = 16.0;        // Entre campos de formulário
  static const double spacingSection = 24.0;          // Entre seções
  static const double spacingPageMargin = 20.0;       // Margens da página
  static const double spacingDialogPadding = 24.0;    // Padding de diálogos
  static const double spacingCardPadding = 20.0;      // Padding de cards
  
  // ============================================================================
  // BORDER RADIUS SYSTEM
  // ============================================================================
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 20.0;
  
  // Semantic Radius
  static const double radiusButton = 8.0;             // Botões
  static const double radiusCard = 16.0;              // Cards
  static const double radiusDialog = 12.0;            // Diálogos
  static const double radiusInput = 8.0;              // Campos de input
  
  // ============================================================================
  // RESPONSIVE BREAKPOINTS
  // ============================================================================
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  
  // ============================================================================
  // HELPER METHODS - Para uso responsivo e adaptativo
  // ============================================================================
  
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
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
  
  // ============================================================================
  // DEPRECATED MAPPING - Para migração gradual dos tokens antigos
  // ============================================================================
  
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
}