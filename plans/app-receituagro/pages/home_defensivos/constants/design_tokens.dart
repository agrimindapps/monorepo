// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'layout_constants.dart';

/// Design tokens centralizados para o módulo home_defensivos
/// Este arquivo define o sistema de design tokens que pode ser facilmente ajustado
class HomeDefensivosDesignTokens {
  // Cores base do sistema
  static const MaterialColor primaryGreen = Colors.green;
  static final Color primaryGreen100 = primaryGreen[ColorConstants.greenShade100]!;
  static final Color primaryGreen200 = primaryGreen[ColorConstants.greenShade200]!;
  static final Color primaryGreen700 = primaryGreen[ColorConstants.greenShade700]!;
  static final Color primaryGreen800 = primaryGreen[ColorConstants.greenShade800]!;
  
  static final Color neutralGrey400 = Colors.grey[ColorConstants.greyShade400]!;
  static final Color neutralGrey500 = Colors.grey[ColorConstants.greyShade500]!;
  static final Color neutralGrey600 = Colors.grey[ColorConstants.greyShade600]!;
  static final Color neutralGrey700 = Colors.grey[ColorConstants.greyShade700]!;
  
  // Estilos de texto padronizados
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: SizeConstants.largeFontSize,
    fontWeight: FontWeight.bold,
    letterSpacing: SizeConstants.defaultLetterSpacing,
  );
  
  static const TextStyle categoryButtonTitleStyle = TextStyle(
    fontSize: SizeConstants.mediumFontSize,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  
  static const TextStyle categoryButtonCountStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: SizeConstants.defaultFontSize,
  );
  
  static const TextStyle listItemTitleStyle = TextStyle(
    fontSize: SizeConstants.mediumFontSize, 
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle listItemSubtitleStyle = TextStyle(
    fontSize: SizeConstants.smallFontSize,
  );
  
  static const TextStyle listItemCaptionStyle = TextStyle(
    fontSize: SizeConstants.extraSmallFontSize,
  );
  
  // Decorações padronizadas
  static BoxDecoration get cardDecoration => const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(LayoutConstants.defaultBorderRadius)),
  );
  
  static BoxDecoration get categoryButtonDecoration => const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(LayoutConstants.categoryButtonBorderRadius)),
    boxShadow: [
      BoxShadow(
        blurRadius: ElevationConstants.shadowBlurRadius,
        offset: ElevationConstants.shadowOffset,
      ),
    ],
  );
  
  static BoxDecoration get sectionIndicatorDecoration => const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(LayoutConstants.smallBorderRadius)),
  );
  
  static BoxDecoration get badgeDecoration => const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(LayoutConstants.badgeBorderRadius)),
  );
  
  // Shadows padronizadas
  static const List<Shadow> textShadows = [
    Shadow(
      offset: ElevationConstants.textShadowOffset,
      blurRadius: ElevationConstants.shadowBlurRadiusSmall,
    ),
  ];
  
  // Espacamentos padronizados
  static const EdgeInsets cardPadding = EdgeInsets.all(LayoutConstants.cardPadding);
  static const EdgeInsets defaultPadding = EdgeInsets.all(LayoutConstants.defaultPadding);
  static const EdgeInsets categoryButtonPadding = EdgeInsets.all(LayoutConstants.categoryButtonPadding);
  
  static const EdgeInsets sectionTitlePadding = EdgeInsets.symmetric(
    vertical: LayoutConstants.sectionTitleVerticalPadding,
    horizontal: LayoutConstants.sectionTitleHorizontalPadding,
  );
  
  // Gaps padronizados
  static const SizedBox smallGap = SizedBox(width: LayoutConstants.smallSpacing, height: LayoutConstants.smallSpacing);
  static const SizedBox defaultGap = SizedBox(width: LayoutConstants.defaultSpacing, height: LayoutConstants.defaultSpacing);
  static const SizedBox mediumGap = SizedBox(width: LayoutConstants.mediumSpacing, height: LayoutConstants.mediumSpacing);
  
  // Configurações de animação
  static const Duration fastAnimation = AnimationConstants.fastAnimation;
  static const Duration defaultAnimation = AnimationConstants.defaultAnimation;
  static const Duration slowAnimation = AnimationConstants.slowAnimation;
  
  // Configurações de densidade visual
  static const VisualDensity compactDensity = LayoutConstants.compactVisualDensity;
  
  // Métodos utilitários para cores dinâmicas
  static Color getGreenShade(int shade) {
    return Colors.green[shade] ?? Colors.green;
  }
  
  static Color getGreyShade(int shade) {
    return Colors.grey[shade] ?? Colors.grey;
  }
  
  static Color withOpacityValue(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  // Método para criar gradientes padronizados
  static LinearGradient createCategoryGradient(Color baseColor) {
    return LinearGradient(
      colors: [
        withOpacityValue(baseColor, ColorConstants.highOpacity),
        withOpacityValue(baseColor, ColorConstants.veryHighOpacity),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  // Método para criar sombras dinâmicas
  static List<BoxShadow> createShadow(Color color, {double opacity = ColorConstants.shadowOpacity}) {
    return [
      BoxShadow(
        color: withOpacityValue(color, opacity),
        blurRadius: ElevationConstants.shadowBlurRadius,
        offset: ElevationConstants.shadowOffset,
      ),
    ];
  }
}
