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

  // Static colors
  static const mutedTextColor = Colors.grey;
  static const focusedBorderColor = Color(0xFF94A3B8);
  static const primaryColor = Color(0xFF020817);
  static const surfaceColor = Color(0xFFF8FAFC);

  // Border Radius
  static final borderRadius = BorderRadius.circular(6);
  static final dialogBorderRadius = BorderRadius.circular(8);

  // Text Styles - Context-dependent
  static TextStyle titleStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textColor(context),
  );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor(context),
  );

  static TextStyle inputStyle(BuildContext context) =>
      TextStyle(fontSize: 14, color: textColor(context));

  static const labelStyle = TextStyle(
    color: mutedTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle sectionHeaderStyle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor(context),
  );

  static const focusColor = Color(0xFF000000);

  // Input Decoration
  static InputDecoration inputDecoration({
    required String label,
    required BuildContext context,
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
      hintStyle: labelStyle.copyWith(color: mutedTextColor.withValues(alpha: 0.8)),
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
    );
  }

  // Borders
  static OutlineInputBorder inputBorder(BuildContext context) =>
      OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor(context)),
      );

  static const OutlineInputBorder inputBorderFocused = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
  );

  static const OutlineInputBorder inputBorderError = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(color: Colors.red, width: 1),
  );

  // Button Styles
  static ButtonStyle textButtonStyle(BuildContext context) =>
      TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: borderColor(context)),
        ),
        foregroundColor: textColor(context),
      );

  static ButtonStyle primaryButtonStyle(BuildContext context) =>
      TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      );

  // Dialog Styles
  static DialogTheme dialogTheme(BuildContext context) => DialogTheme(
    backgroundColor: backgroundColor(context),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: dialogBorderRadius,
      side: BorderSide(color: borderColor(context)),
    ),
  );

  // Dialog Container Decoration
  static BoxDecoration dialogContainerDecoration(BuildContext context) =>
      BoxDecoration(
        color: backgroundColor(context),
        borderRadius: dialogBorderRadius,
      );

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
  static Widget buildSectionHeader(
    String title, {
    IconData? icon,
    BuildContext? context,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: mutedTextColor),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: context != null
                ? sectionHeaderStyle(context)
                : const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: mutedTextColor,
                  ),
          ),
        ],
      ),
    );
  }

  // Dialog Title
  static Widget buildDialogTitle(
    String title,
    bool isSmallScreen, {
    required BuildContext context,
  }) {
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
                  style: titleStyle(context),
                ),
              ),
            ],
          ),
        ),
        Divider(color: borderColor(context)),
      ],
    );
  }

  static SliderThemeData sliderTheme(BuildContext context) => SliderThemeData(
    trackHeight: 8.0,
    activeTrackColor: textColor(context),
    inactiveTrackColor: borderColor(context),
    thumbColor: textColor(context),
    overlayColor: textColor(context).withValues(alpha: 0.12),
    tickMarkShape: const RoundSliderTickMarkShape(),
    valueIndicatorColor: textColor(context),
    valueIndicatorTextStyle: TextStyle(
      color: backgroundColor(context),
      fontSize: 14,
    ),
  );

  static Color chartBarColor(BuildContext context) =>
      textColor(context).withValues(alpha: 0.9);
  static Color chartLineColor(BuildContext context) =>
      textColor(context).withValues(alpha: 0.9);
  static Color chartAreaColor(BuildContext context) =>
      textColor(context).withValues(alpha: 0.1);

  // Dropdown Styles
  static InputDecoration dropdownDecoration(BuildContext context) =>
      InputDecoration(
        labelStyle: labelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: borderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: borderColor(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: backgroundColor(context),
      );

  static ButtonStyle segmentedButtonTheme(BuildContext context) => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return textColor(context);
      }
      return backgroundColor(context);
    }),
    foregroundColor: WidgetStateProperty.resolveWith<Color>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return backgroundColor(context);
      }
      return textColor(context);
    }),
    side: WidgetStateProperty.all(BorderSide(color: borderColor(context))),
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
