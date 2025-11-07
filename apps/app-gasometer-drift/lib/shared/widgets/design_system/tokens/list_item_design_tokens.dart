import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';

/// Design tokens específicos para list items padronizados
/// 
/// Complementa os GasometerDesignTokens com valores específicos
/// para garantir consistência visual entre todos os tipos de list items.
abstract class ListItemDesignTokens {
  static const double dateColumnWidth = 80.0;
  static const double dividerThickness = 1.0;
  static const double cardMinHeight = 80.0;
  static EdgeInsets get cardPadding => const EdgeInsets.all(GasometerDesignTokens.spacingLg);
  static EdgeInsets get contentPadding => const EdgeInsets.only(
    left: GasometerDesignTokens.spacingMd,
    right: GasometerDesignTokens.spacingSm,
    top: GasometerDesignTokens.spacingSm,
    bottom: GasometerDesignTokens.spacingSm,
  );
  static EdgeInsets get dateColumnPadding => const EdgeInsets.only(
    right: GasometerDesignTokens.spacingMd,
    top: GasometerDesignTokens.spacingSm,
    bottom: GasometerDesignTokens.spacingSm,
  );
  static double get infoItemsSpacing => GasometerDesignTokens.spacingSm;
  static double get badgeSpacing => GasometerDesignTokens.spacingXs;
  static Color get dividerColor => GasometerDesignTokens.colorNeutral300;
  static Color get cardBackgroundColor => GasometerDesignTokens.colorBackground;
  static Color get cardHoverColor => GasometerDesignTokens.colorPrimaryLight.withValues(alpha: 0.1);
  static TextStyle get dateTextStyle => const TextStyle(
    fontSize: GasometerDesignTokens.fontSizeSm,
    fontWeight: GasometerDesignTokens.fontWeightMedium,
    color: GasometerDesignTokens.colorTextSecondary,
  );
  
  static TextStyle get monthTextStyle => const TextStyle(
    fontSize: GasometerDesignTokens.fontSizeXs,
    fontWeight: GasometerDesignTokens.fontWeightRegular,
    color: GasometerDesignTokens.colorTextSecondary,
  );
  static TextStyle get infoLabelStyle => const TextStyle(
    fontSize: GasometerDesignTokens.fontSizeXs,
    fontWeight: GasometerDesignTokens.fontWeightRegular,
    color: GasometerDesignTokens.colorTextSecondary,
  );
  
  static TextStyle get infoValueStyle => const TextStyle(
    fontSize: GasometerDesignTokens.fontSizeSm,
    fontWeight: GasometerDesignTokens.fontWeightMedium,
    color: GasometerDesignTokens.colorTextPrimary,
  );
  static BorderRadius get cardBorderRadius => BorderRadius.circular(GasometerDesignTokens.radiusCard);
  static BorderRadius get badgeBorderRadius => BorderRadius.circular(GasometerDesignTokens.radiusSm);
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: GasometerDesignTokens.colorNeutral500.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const Curve animationCurve = Curves.easeInOut;
  static const double minimumTouchTargetSize = 48.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  
  /// Retorna padding responsivo baseado na largura da tela
  static EdgeInsets getResponsiveCardPadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return const EdgeInsets.all(GasometerDesignTokens.spacingMd);
    } else if (screenWidth < tabletBreakpoint) {
      return const EdgeInsets.all(GasometerDesignTokens.spacingLg);
    } else {
      return const EdgeInsets.all(GasometerDesignTokens.spacingXl);
    }
  }
  
  /// Retorna largura da coluna de data baseada na largura da tela
  static double getResponsiveDateWidth(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return dateColumnWidth * 0.8;
    }
    return dateColumnWidth;
  }
}
