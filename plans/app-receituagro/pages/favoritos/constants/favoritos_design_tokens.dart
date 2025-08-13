// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/themes/manager.dart';

/// Design tokens específicos para o módulo de favoritos
/// Baseado no sistema de design do home_defensivos
class FavoritosDesignTokens {
  // Cores do sistema por categoria
  static const Color defensivosColor = Color(0xFF2E7D32);
  static const Color pragasColor = Color(0xFF2E7D32); // Alterado de vermelho para verde
  static const Color diagnosticosColor = Color(0xFF2E7D32); // Alterado de azul para verde

  // Variações de cores
  static Color defensivosLight = defensivosColor.withValues(alpha: 0.1);
  static Color pragasLight = pragasColor.withValues(alpha: 0.1);
  static Color diagnosticosLight = diagnosticosColor.withValues(alpha: 0.1);

  // Espaçamentos padronizados (baseado no home_defensivos)
  static const double smallSpacing = 4.0;
  static const double defaultSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;

  // Padding padronizado
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets sectionPadding = EdgeInsets.all(16.0);

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Elevação e sombras
  static const double cardElevation = 2.0;
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

  static List<BoxShadow> iconShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  // Tamanhos de ícones
  static const double smallIconSize = 14.0;
  static const double defaultIconSize = 18.0;
  static const double mediumIconSize = 22.0;
  static const double largeIconSize = 24.0;
  static const double avatarIconSize = 48.0;

  // Tamanhos de fonte
  static const double captionFontSize = 12.0;
  static const double bodyFontSize = 14.0;
  static const double titleFontSize = 16.0;
  static const double headingFontSize = 18.0;
  static const double largeTitleFontSize = 22.0;

  // Estilos de texto padronizados
  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: bodyFontSize,
    height: 1.4,
  );

  static const TextStyle listItemTitleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle listItemSubtitleStyle = TextStyle(
    fontSize: bodyFontSize,
    height: 1.4,
  );

  static const TextStyle tabLabelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
  );

  static const TextStyle tabUnselectedStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  // Gradientes padronizados
  static LinearGradient createIconGradient(Color color) {
    return LinearGradient(
      colors: [
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Método para obter cor por categoria
  static Color getColorByCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return defensivosColor;
      case 1:
        return pragasColor;
      case 2:
        return diagnosticosColor;
      default:
        return defensivosColor;
    }
  }

  // Método para obter cor clara por categoria
  static Color getLightColorByCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return defensivosLight;
      case 1:
        return pragasLight;
      case 2:
        return diagnosticosLight;
      default:
        return defensivosLight;
    }
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
    return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  }

  static Color getBackgroundColor(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    return isDark ? Colors.grey.shade900 : Colors.white;
  }
}
