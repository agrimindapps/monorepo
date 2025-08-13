// Flutter imports:
import 'package:flutter/material.dart';

/// Design tokens centralizados para a página de detalhes de pragas
/// Mantém consistência visual e facilita manutenção
class DetalhesPragasDesignTokens {
  // Cores principais
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);

  // Espaçamentos padronizados
  static const double smallSpacing = 4.0;
  static const double defaultSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 16.0;
  static const double extraLargeSpacing = 24.0;

  // Padding padronizado
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets defaultPadding = EdgeInsets.all(12.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets sectionPadding = EdgeInsets.all(16.0);
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(
    vertical: defaultSpacing,
    horizontal: smallSpacing,
  );

  // Border radius padronizado
  static const double smallBorderRadius = 4.0;
  static const double defaultBorderRadius = 8.0;
  static const double mediumBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;

  // Tamanhos de ícone
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 20.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;

  // Animações
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration defaultAnimation = Duration(milliseconds: 250);
  static const Duration slowAnimation = Duration(milliseconds: 400);

  // Estilos de texto
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardSubtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmallStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );

  // Cores por tema
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color getSubtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade600;
  }

  static Color getContentTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'informacoes':
      case 'informações':
        return const Color(0xFF1976D2); // Azul
      case 'diagnostico':
      case 'diagnóstico':
        return const Color(0xFFFF9800); // Laranja
      case 'comentarios':
      case 'comentários':
        return const Color(0xFF4CAF50); // Verde
      default:
        return primaryColor;
    }
  }

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

  static BoxDecoration sectionDecoration(BuildContext context,
      {Color? accentColor}) {
    return BoxDecoration(
      color: getCardColor(context),
      borderRadius: BorderRadius.circular(mediumBorderRadius),
      border: Border.all(
        color: accentColor?.withValues(alpha: 0.3) ?? getBorderColor(context),
        width: 1,
      ),
      boxShadow: subtleShadow,
    );
  }

  static BoxDecoration inputDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(mediumBorderRadius),
      border: Border.all(
        color: getBorderColor(context),
        width: 1,
      ),
    );
  }

  // Sombras
  static List<BoxShadow> get subtleShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get largeShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Input decorations
  static InputDecoration searchInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: largeSpacing,
        vertical: mediumSpacing,
      ),
    );
  }

  // Button styles
  static ButtonStyle elevatedButtonStyle(BuildContext context,
      {Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: mediumSpacing,
        horizontal: largeSpacing,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      elevation: 2,
    );
  }

  static ButtonStyle outlinedButtonStyle(BuildContext context,
      {Color? borderColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: borderColor ?? primaryColor,
      padding: const EdgeInsets.symmetric(
        vertical: mediumSpacing,
        horizontal: largeSpacing,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      side: BorderSide(
        color: borderColor ?? primaryColor,
        width: 1,
      ),
    );
  }

  // Decorações sem elevation (flat)
  static BoxDecoration cardDecorationFlat(BuildContext context,
      {Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ??
          (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF222228)
              : Colors.white),
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade200,
        width: 1,
      ),
    );
  }

  // Button style sem elevation
  static ButtonStyle elevatedButtonStyleFlat(BuildContext context,
      {Color? backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: mediumSpacing,
        horizontal: largeSpacing,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
      elevation: 0,
    );
  }
}
