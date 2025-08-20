// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Sistema de tema centralizado para todo o módulo AgriHurbi
/// 
/// Unifica todas as cores, estilos e constantes de design em um local central,
/// substituindo cores hardcoded espalhadas pelo código.
/// Baseado no ShadcnStyle para consistência com o sistema de design global.
class AgrihurbiTheme {
  // === AGRICULTURA SPECIFIC COLORS ===
  // Cores primárias inspiradas na agricultura - verdes naturais
  static const Color agriculturaPrimary = Color(0xFF4CAF50); // Green 500 - Cor principal do módulo
  static const Color agriculturaSecondary = Color(0xFF2E7D32); // Green 800 - Verde mais escuro
  static const Color agriculturaLight = Color(0xFF81C784); // Green 300 - Verde claro
  static const Color agriculturaDark = Color(0xFF1B5E20); // Green 900 - Verde muito escuro
  
  // Cores de apoio para diferentes contextos
  static const Color agriculturaSurface = Color(0xFFE8F5E8); // Verde muito claro para superfícies
  static const Color agriculturaAccent = Color(0xFF66BB6A); // Green 400 - Cor de destaque
  
  // === CORE COLORS ===
  // Baseado no ShadcnStyle para consistência
  static Color get backgroundColor => ShadcnStyle.backgroundColor;
  static Color get borderColor => ShadcnStyle.borderColor;
  static Color get textColor => ShadcnStyle.textColor;
  static Color get mutedTextColor => ShadcnStyle.mutedTextColor;
  static Color get focusedBorderColor => ShadcnStyle.focusedBorderColor;
  
  // === STATUS COLORS ===
  static const Color successColor = Color(0xFF22C55E); // Green 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500  
  static const Color errorColor = Color(0xFFEF4444); // Red 500
  static const Color infoColor = Color(0xFF3B82F6); // Blue 500
  
  // === GRADIENT COLORS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [agriculturaPrimary, agriculturaSecondary],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [agriculturaLight, agriculturaPrimary],
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [agriculturaSurface, Color(0xFFF1F8E9)],
  );

  // === SPECIALIZED COLORS ===
  // Para diferentes contextos do módulo
  
  // Bovinos e Equinos
  static const Color animalPrimary = agriculturaPrimary;
  static const Color animalHealthy = Color(0xFF4CAF50);
  static const Color animalWarning = Color(0xFFFF9800);
  static const Color animalDanger = Color(0xFFE53E3E);
  
  // Pluviometria e clima
  static const Color rainColor = Color(0xFF0EA5E9); // Sky 500
  static const Color noRainColor = Color(0xFF94A3B8); // Slate 400
  static const Color highRainColor = Color(0xFF1D4ED8); // Blue 700
  static const Color mediumRainColor = Color(0xFF3B82F6); // Blue 500
  static const Color lowRainColor = Color(0xFF60A5FA); // Blue 400
  
  // Calculadoras
  static const Color calculatorPrimary = agriculturaPrimary;
  static const Color calculatorResult = Color(0xFF059669); // Emerald 600
  static const Color calculatorInput = Color(0xFFF3F4F6); // Gray 100
  
  // === CARD COLORS ===
  static Color get cardBackground => backgroundColor;
  static Color get cardBorder => borderColor;
  static Color get cardShadow => textColor.withValues(alpha: 0.1);
  static const Color cardAccent = agriculturaSurface;
  
  // === INTERACTIVE STATES ===
  static Color get hoverColor => textColor.withValues(alpha: 0.05);
  static Color get pressedColor => textColor.withValues(alpha: 0.1);
  static Color get selectedColor => agriculturaPrimary.withValues(alpha: 0.1);
  static Color get disabledColor => mutedTextColor.withValues(alpha: 0.5);
  
  // === TYPOGRAPHY SCALE ===
  // Hierarchy de textos baseada no ShadcnStyle
  
  static TextStyle get headingXL => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.75,
      );
      
  static TextStyle get headingLarge => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.25,
      );

  static TextStyle get headingSmall => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedTextColor,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: mutedTextColor,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedTextColor,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: mutedTextColor,
      );

  // === SPACING SYSTEM ===
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  static const double space12 = 48.0;
  static const double space16 = 64.0;
  static const double space20 = 80.0;

  // === BORDER RADIUS ===
  static BorderRadius get radiusNone => BorderRadius.zero;
  static BorderRadius get radiusSmall => BorderRadius.circular(4.0);
  static BorderRadius get radiusMedium => BorderRadius.circular(8.0);
  static BorderRadius get radiusLarge => BorderRadius.circular(12.0);
  static BorderRadius get radiusXL => BorderRadius.circular(16.0);
  static BorderRadius get radiusXXL => BorderRadius.circular(24.0);
  static BorderRadius get radiusFull => BorderRadius.circular(9999.0);

  // === SHADOWS ===
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: cardShadow,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: cardShadow,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: cardShadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowXL => [
        BoxShadow(
          color: cardShadow,
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // === DECORATIONS ===
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: radiusMedium,
        border: Border.all(color: cardBorder),
        boxShadow: shadowSmall,
      );

  static BoxDecoration get primaryCardDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: radiusMedium,
        boxShadow: shadowMedium,
      );

  static BoxDecoration get surfaceCardDecoration => BoxDecoration(
        color: cardAccent,
        borderRadius: radiusMedium,
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      );

  static BoxDecoration get inputDecoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: radiusMedium,
        border: Border.all(color: borderColor),
      );

  // === BUTTON STYLES ===
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: agriculturaPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        textStyle: titleMedium.copyWith(color: Colors.white),
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: agriculturaPrimary,
        side: const BorderSide(color: agriculturaPrimary),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      );

  static ButtonStyle get ghostButtonStyle => TextButton.styleFrom(
        foregroundColor: agriculturaPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      );

  static ButtonStyle get dangerButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: errorColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      );

  // === INPUT STYLES ===
  static InputDecoration getInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelLarge,
      hintText: hint,
      hintStyle: bodyMedium.copyWith(color: mutedTextColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      helperText: helperText,
      helperStyle: labelSmall,
      contentPadding: const EdgeInsets.symmetric(horizontal: space4, vertical: space3),
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(color: agriculturaPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(color: errorColor),
      ),
    );
  }

  // === HELPER METHODS ===
  
  /// Retorna cor baseada na intensidade da chuva
  static Color getRainIntensityColor(double quantidade) {
    if (quantidade == 0) return noRainColor;
    if (quantidade < 5) return lowRainColor;
    if (quantidade < 20) return mediumRainColor;
    return highRainColor;
  }

  /// Retorna cor baseada no status de saúde do animal
  static Color getAnimalHealthColor(String status) {
    switch (status.toLowerCase()) {
      case 'saudável':
      case 'saudavel':
      case 'bom':
        return animalHealthy;
      case 'atenção':
      case 'atencao':
      case 'cuidado':
        return animalWarning;
      case 'doente':
      case 'crítico':
      case 'critico':
        return animalDanger;
      default:
        return agriculturaPrimary;
    }
  }

  /// Retorna cor baseada no tipo de estatística
  static Color getStatisticColor(String type) {
    switch (type.toLowerCase()) {
      case 'total':
        return agriculturaPrimary;
      case 'média':
      case 'media':
        return infoColor;
      case 'máximo':
      case 'maximo':
        return warningColor;
      case 'mínimo':
      case 'minimo':
        return successColor;
      default:
        return textColor;
    }
  }

  // === RESPONSIVE BREAKPOINTS ===
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1280.0;

  /// Verifica se é dispositivo mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Verifica se é tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Verifica se é desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Retorna padding adaptativo baseado no tamanho da tela
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(space3);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(space4);
    } else {
      return const EdgeInsets.all(space6);
    }
  }

  /// Retorna espaçamento adaptativo
  static double getAdaptiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return space2;
    } else if (isTablet(context)) {
      return space3;
    } else {
      return space4;
    }
  }

  // === ANIMATION DURATIONS ===
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // === ICON SIZES ===
  static const double iconTiny = 12.0;
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // === LAYOUT CONSTRAINTS ===
  static const double maxContentWidth = 1200.0;
  static const double maxCardWidth = 400.0;
  static const double minCardHeight = 64.0;
  static const double appBarHeight = 88.0;
  static const double bottomNavHeight = 80.0;
}