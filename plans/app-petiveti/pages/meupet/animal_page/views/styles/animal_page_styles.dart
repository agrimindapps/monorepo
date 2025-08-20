// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../constants/design_tokens.dart';

class AnimalPageStyles {
  // Private constructor to prevent instantiation
  AnimalPageStyles._();

  // COLORS
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Colors.black87;
  static const Color textSecondaryColor = Colors.black54;
  static const Color textHintColor = Colors.black38;
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFCCCCCC);

  // STATUS COLORS
  static const Color successColor = DesignTokens.colorSuccess;
  static const Color warningColor = DesignTokens.colorWarning;
  static const Color errorColor = DesignTokens.colorError;
  static const Color infoColor = DesignTokens.colorInfo;

  // DIMENSIONS
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderWidth = 1.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ICON SIZES
  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;

  // SPACING
  static const EdgeInsets contentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets itemPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 24.0);

  // TEXT STYLES
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondaryColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // CARD STYLES
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      );

  static BoxDecoration get selectedCardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      );

  // INPUT DECORATIONS
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      filled: true,
      fillColor: hasError ? errorColor.withValues(alpha: 0.05) : surfaceColor,
    );
  }

  // BUTTON STYLES
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevationLow,
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: const BorderSide(color: primaryColor),
      );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );

  // SEARCH STYLES
  static InputDecoration get searchDecoration => InputDecoration(
        hintText: 'Buscar animais...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // FILTER CHIP STYLES
  static InputDecoration get filterDecoration => InputDecoration(
        hintText: 'Filtrar por...',
        prefixIcon: const Icon(Icons.filter_list),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: borderColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // STATUS INDICATOR STYLES
  static BoxDecoration statusDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      );

  // AVATAR STYLES
  static BoxDecoration get avatarDecoration => BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withValues(alpha: 0.1),
      );

  // DIVIDER STYLES
  static Widget get sectionDivider => Container(
        height: 1,
        color: dividerColor,
        margin: const EdgeInsets.symmetric(vertical: 16),
      );

  static Widget get listDivider => const Divider(
        height: 1,
        thickness: 1,
        color: dividerColor,
        indent: 16,
        endIndent: 16,
      );

  // LOADING INDICATOR STYLES
  static Widget loadingIndicator({Color? color}) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color ?? primaryColor),
        ),
      );

  // ERROR STATE STYLES
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
  }) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: subtitleStyle,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: primaryButtonStyle,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ],
        ),
      );

  // EMPTY STATE STYLES
  static Widget emptyState({
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 64,
              color: textHintColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: subtitleStyle.copyWith(color: textSecondaryColor),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                style: primaryButtonStyle,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      );

  // ANIMATION STYLES
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;

  // SHADOW STYLES
  static List<BoxShadow> get lightShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get strongShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          offset: const Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
}
