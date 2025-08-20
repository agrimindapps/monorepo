// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../config/despesa_config.dart';

class DespesaFormStyles {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF66BB6A);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color disabledColor = Color(0xFFBDBDBD);

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static const TextStyle inputStyle = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );

  static const TextStyle errorStyle = TextStyle(
    fontSize: 14,
    color: errorColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Spacing and Dimensions - using DespesaConfig constants
  static EdgeInsets get formPadding =>
      const EdgeInsets.all(DespesaConfig.spacingMedium);
  static EdgeInsets get cardPadding =>
      const EdgeInsets.all(DespesaConfig.cardPadding);
  static EdgeInsets get cardMargin => const EdgeInsets.all(DespesaConfig.cardMargin);
  static EdgeInsets get inputPadding => const EdgeInsets.symmetric(
        horizontal: DespesaConfig.spacingMedium,
        vertical: DespesaConfig.spacingSmall,
      );
  static EdgeInsets get buttonPadding => const EdgeInsets.symmetric(
        horizontal: DespesaConfig.spacingLarge,
        vertical: DespesaConfig.spacingSmall,
      );

  static double get borderRadius => DespesaConfig.cardBorderRadius;
  static double get cardElevation => DespesaConfig.cardElevation;
  static double get buttonElevation => DespesaConfig.cardElevation;
  static double get inputBorderWidth => DespesaConfig.inputFieldBorderWidth;

  // Shapes - using DespesaConfig constants
  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      );

  static RoundedRectangleBorder get buttonShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      );

  static OutlineInputBorder get inputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: dividerColor,
          width: inputBorderWidth,
        ),
      );

  static OutlineInputBorder get focusedInputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: primaryColor,
          width: inputBorderWidth,
        ),
      );

  static OutlineInputBorder get errorInputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: errorColor,
          width: inputBorderWidth,
        ),
      );

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: buttonElevation,
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    elevation: buttonElevation,
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    elevation: buttonElevation,
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  static final ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: successColor,
    foregroundColor: Colors.white,
    elevation: buttonElevation,
    padding: buttonPadding,
    shape: buttonShape,
    textStyle: buttonTextStyle,
  );

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: labelStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: focusedInputBorder,
      errorBorder: errorInputBorder,
      focusedErrorBorder: errorInputBorder,
      filled: true,
      fillColor: Colors.white,
      contentPadding: inputPadding,
      errorStyle: errorStyle,
    );
  }

  // Dropdown Decoration
  static InputDecoration getDropdownDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: labelStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIcon,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: focusedInputBorder,
      errorBorder: errorInputBorder,
      focusedErrorBorder: errorInputBorder,
      filled: true,
      fillColor: Colors.white,
      contentPadding: inputPadding,
      errorStyle: errorStyle,
    );
  }

  // Card Themes
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration errorCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: errorColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: errorColor.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration successCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: successColor, width: 1),
    boxShadow: [
      BoxShadow(
        color: successColor.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // cardTheme: CardTheme(
      //   color: cardColor,
      //   elevation: cardElevation,
      //   shape: cardShape,
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: outlineButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(
        style: textButtonStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedInputBorder,
        errorBorder: errorInputBorder,
        focusedErrorBorder: errorInputBorder,
        filled: true,
        fillColor: Colors.white,
        contentPadding: inputPadding,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        errorStyle: errorStyle,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: appBarTitleStyle,
        centerTitle: true,
      ),
    );
  }

  // Animation Durations - using DespesaConfig constants
  static Duration get shortAnimation =>
      DespesaConfig.getAnimationDuration(fast: true);
  static Duration get mediumAnimation => DespesaConfig.getAnimationDuration();
  static Duration get longAnimation =>
      const Duration(milliseconds: DespesaConfig.animationDurationSlow);

  // Icon Sizes - using DespesaConfig constants
  static double get smallIconSize => DespesaConfig.iconSizeSmall;
  static double get mediumIconSize => DespesaConfig.iconSizeMedium;
  static double get largeIconSize => DespesaConfig.iconSizeLarge;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;

  // Form Constraints - using DespesaConfig constants
  static double get maxFormWidth => DespesaConfig.maxFormWidth;
  static double get minButtonHeight => DespesaConfig.buttonHeight;
  static double get maxDropdownHeight => DespesaConfig.maxFormHeight;

  // Helper Methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(DespesaConfig.spacingMedium);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(DespesaConfig.spacingLarge);
    } else {
      return const EdgeInsets.all(DespesaConfig.spacingXLarge);
    }
  }

  static double getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth - 32.0;
    } else {
      return maxFormWidth.clamp(400.0, screenWidth - 64.0);
    }
  }
}
