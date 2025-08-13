// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/themes/manager.dart';

/// Design tokens específicos para o módulo de detalhes_defensivos
/// Baseado no sistema de design do home_defensivos e favoritos
class DetalhesDefensivosDesignTokens {
  // Cores principais do sistema
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color infoColor = Color(0xFF1976D2);

  // Variações de cores
  static Color primaryLight = primaryColor.withValues(alpha: 0.1);
  static Color accentLight = accentColor.withValues(alpha: 0.1);
  static Color warningLight = warningColor.withValues(alpha: 0.1);
  static Color errorLight = errorColor.withValues(alpha: 0.1);
  static Color infoLight = infoColor.withValues(alpha: 0.1);

  // Espaçamentos padronizados
  static const double smallSpacing = 4.0;
  static const double defaultSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;
  static const double hugeLargeSpacing = 32.0;

  // Padding padronizado
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets sectionPadding = EdgeInsets.all(16.0);
  static const EdgeInsets contentPadding =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
  static const EdgeInsets appBarPadding = EdgeInsets.all(16.0);

  // Border radius
  static const double smallBorderRadius = 8.0;
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 20.0;

  // Elevação e sombras
  static const double cardElevation = 2.0;
  static const double appBarElevation = 4.0;
  static const double modalElevation = 8.0;

  static List<BoxShadow> cardShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get appBarShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // Tamanhos de ícones
  static const double smallIconSize = 14.0;
  static const double defaultIconSize = 18.0;
  static const double mediumIconSize = 22.0;
  static const double largeIconSize = 24.0;
  static const double extraLargeIconSize = 32.0;
  static const double hugeIconSize = 48.0;

  // Tamanhos de fonte
  static const double captionFontSize = 12.0;
  static const double bodyFontSize = 14.0;
  static const double titleFontSize = 16.0;
  static const double headingFontSize = 18.0;
  static const double largeTitleFontSize = 20.0;
  static const double displayFontSize = 24.0;

  // Estilos de texto padronizados
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: largeTitleFontSize,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle appBarSubtitleStyle = TextStyle(
    fontSize: bodyFontSize,
    height: 1.3,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: headingFontSize,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: bodyFontSize,
    height: 1.4,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: bodyFontSize,
  );

  // Gradientes padronizados
  static LinearGradient createPrimaryGradient() {
    return LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.8),
        primaryColor.withValues(alpha: 0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient createAccentGradient() {
    return LinearGradient(
      colors: [
        accentColor.withValues(alpha: 0.8),
        accentColor.withValues(alpha: 0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Configurações de tema dark/light
  static Color getTextColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.white : Colors.black87;
  }

  static Color getSubtitleColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  static Color getCardColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade900 : Colors.white;
  }

  static Color getBorderColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  }

  static Color getBackgroundColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade900 : Colors.white;
  }

  static Color getSurfaceColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade50;
  }

  // Método para obter cores por tipo de conteúdo
  static Color getContentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'informacoes':
      case 'info':
        return primaryColor;
      case 'diagnostico':
        return infoColor;
      case 'aplicacao':
        return accentColor;
      case 'comentarios':
        return warningColor;
      default:
        return primaryColor;
    }
  }

  // Configurações de animação
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Decorações padronizadas
  static BoxDecoration cardDecoration(BuildContext context,
      {Color? borderColor}) {
    return BoxDecoration(
      color: getCardColor(context),
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      border: Border.all(
        color: borderColor ?? getBorderColor(context),
        width: 1,
      ),
      boxShadow: subtleShadow,
    );
  }

  // Decoração de card sem elevation (para informações de insetos)
  static BoxDecoration cardDecorationFlat(BuildContext context,
      {Color? borderColor}) {
    return BoxDecoration(
      color: getCardColor(context),
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      border: Border.all(
        color: borderColor ?? getBorderColor(context),
        width: 1,
      ),
    );
  }

  static BoxDecoration sectionDecoration(BuildContext context,
      {Color? accentColor}) {
    return BoxDecoration(
      color: getCardColor(context),
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      border: accentColor != null
          ? Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.5,
            )
          : null,
      boxShadow: accentColor != null ? cardShadow(accentColor) : subtleShadow,
    );
  }
}
