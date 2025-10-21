import 'package:flutter/material.dart';

class ShadcnStyle {
  // Helper method to get colors based on theme
  static Color backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF18181B) : const Color(0xFFF7FAFC);
  }

  static Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
  }

  static Color textColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0F172A);
  }
  static const mutedTextColor = Colors.grey;
  static const focusedBorderColor = Color(0xFF94A3B8);
  static const primaryColor = Color(0xFF020817);

  // Border Radius
  static final borderRadius = BorderRadius.circular(6);
  static final dialogBorderRadius = BorderRadius.circular(8);

  // Text Styles
  static final titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static final subtitleStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static final inputStyle = TextStyle(
    fontSize: 14,
    color: textColor,
  );

  static const labelStyle = TextStyle(
    color: mutedTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static final sectionHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static const focusColor = Color(0xFF000000);

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    String? prefix,
    String? suffix,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool showCounter = false,
    String? suffixText,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelStyle,
      hintText: hint,
      hintStyle: labelStyle.copyWith(color: mutedTextColor.withOpacity(0.8)),
      prefixText: prefix,
      suffixText: suffix,
      helperText: helperText,
      helperStyle: labelStyle.copyWith(fontSize: 12),
      prefixIcon: prefixIcon != null
          ? IconTheme(
              data: const IconThemeData(color: mutedTextColor, size: 20),
              child: prefixIcon,
            )
          : null,
      suffixIcon: suffixIcon,
      counterText: showCounter ? null : '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      // filled: true,
      // fillColor: backgroundColor,
      // border: inputBorder,
      // enabledBorder: inputBorder,
      // focusedBorder: inputBorderFocused,
      // errorBorder: inputBorderError,
      // focusedErrorBorder: inputBorderError,
    );
  }

  // Borders
  static final inputBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(color: borderColor),
  );

  static final inputBorderFocused = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: const BorderSide(color: focusedBorderColor, width: 1.5),
  );

  static final inputBorderError = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: const BorderSide(color: Colors.red, width: 1),
  );

  // Button Styles
  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(color: borderColor),
    ),
    foregroundColor: textColor,
  );

  static ButtonStyle primaryButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: borderRadius,
    ),
  );

  // Dialog Styles
  static DialogTheme dialogTheme = DialogTheme(
    backgroundColor: backgroundColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: dialogBorderRadius,
      side: BorderSide(color: borderColor),
    ),
  );

  // Dialog Container Decoration
  static BoxDecoration dialogContainerDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: dialogBorderRadius,
  );

  static var labelColor;

  // Padding Values
  static EdgeInsets getDialogPadding(bool isSmallScreen) => EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 12 : 16,
        0,
      );

  static EdgeInsets getDialogInsetPadding(bool isSmallScreen) =>
      EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 16 : 24,
      );

  static EdgeInsets getActionsPadding(bool isSmallScreen) =>
      EdgeInsets.fromLTRB(
        isSmallScreen ? 8 : 12,
        isSmallScreen ? 6 : 8,
        isSmallScreen ? 8 : 12,
        isSmallScreen ? 8 : 12,
      );

  // Section Header
  static Widget buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: mutedTextColor),
            const SizedBox(width: 8),
          ],
          Text(title, style: sectionHeaderStyle),
        ],
      ),
    );
  }

  // Dialog Title
  static Widget buildDialogTitle(String title, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12 : 20,
            0,
            isSmallScreen ? 12 : 20,
            5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
              ),
            ],
          ),
        ),
        Divider(color: borderColor),
      ],
    );
  }

  static final sliderTheme = SliderThemeData(
    trackHeight: 8.0,
    activeTrackColor: textColor, // Changed from primaryColor
    inactiveTrackColor: borderColor,
    thumbColor: textColor, // Changed from primaryColor
    overlayColor: textColor.withOpacity(0.12), // Changed from primaryColor
    tickMarkShape: const RoundSliderTickMarkShape(),
    valueIndicatorColor: textColor, // Changed from primaryColor
    valueIndicatorTextStyle: TextStyle(
      color: backgroundColor,
      fontSize: 14,
    ),
  );

  static final chartBarColor = textColor.withOpacity(0.9);
  static final chartLineColor = textColor.withOpacity(0.9);
  static final chartAreaColor = textColor.withOpacity(0.1);

  // Dropdown Styles
  static final dropdownDecoration = InputDecoration(
    labelStyle: TextStyle(color: labelColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: focusedBorderColor, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    filled: true,
    fillColor: backgroundColor,
  );

  static final segmentedButtonTheme = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return textColor;
        }
        return backgroundColor;
      },
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return backgroundColor;
        }
        return textColor;
      },
    ),
    side: WidgetStateProperty.all(
      BorderSide(color: borderColor),
    ),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // static const borderColor = Color(0xFFE2E8F0); // Slate 200
  // static const focusedBorderColor = Color(0xFF94A3B8); // Slate 400
  static const surfaceColor = Color(0xFFF8FAFC); // Slate 50
}
