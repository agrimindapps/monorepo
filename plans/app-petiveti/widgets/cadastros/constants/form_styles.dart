// Flutter imports:
import 'package:flutter/material.dart';

/// Constantes de estilo unificadas para todos os formulários de cadastro
class FormStyles {
  // Cores
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Colors.white;
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFF9E9E9E);

  // Espaçamentos
  static const double tinySpacing = 4.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Bordas
  static const double borderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double borderWidth = 1.0;

  // Elevações
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Tamanhos de fonte
  static const double titleFontSize = 20.0;
  static const double subtitleFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;

  // Alturas de componentes
  static const double inputHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double smallButtonHeight = 36.0;

  // Estilos de texto
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: subtitleFontSize,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: bodyFontSize,
    color: Colors.black87,
  );

  static const TextStyle captionTextStyle = TextStyle(
    fontSize: captionFontSize,
    color: Colors.black54,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontSize: captionFontSize,
    color: errorColor,
  );

  // Estilos de input
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      filled: true,
      fillColor: enabled ? surfaceColor : backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: borderWidth),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: disabledColor, width: borderWidth),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: mediumSpacing,
        vertical: smallSpacing,
      ),
    );
  }

  // Estilos de botão
  static ButtonStyle getPrimaryButtonStyle({
    Size? minimumSize,
    Color? backgroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryColor,
      foregroundColor: Colors.white,
      minimumSize: minimumSize ?? const Size(double.infinity, buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: mediumElevation,
    );
  }

  static ButtonStyle getSecondaryButtonStyle({
    Size? minimumSize,
    Color? borderColor,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      minimumSize: minimumSize ?? const Size(double.infinity, buttonHeight),
      side: BorderSide(color: borderColor ?? primaryColor, width: borderWidth),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ButtonStyle getDangerButtonStyle({
    Size? minimumSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: errorColor,
      foregroundColor: Colors.white,
      minimumSize: minimumSize ?? const Size(double.infinity, buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      elevation: mediumElevation,
    );
  }

  // Estilos de card
  static BoxDecoration getCardDecoration({
    Color? color,
    double? elevation,
  }) {
    return BoxDecoration(
      color: color ?? surfaceColor,
      borderRadius: BorderRadius.circular(largeBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: elevation ?? mediumElevation,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Padding padrão
  static const EdgeInsets defaultPadding = EdgeInsets.all(mediumSpacing);
  static const EdgeInsets smallPadding = EdgeInsets.all(smallSpacing);
  static const EdgeInsets largePadding = EdgeInsets.all(largeSpacing);

  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: mediumSpacing,
  );

  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(
    vertical: mediumSpacing,
  );
}
