// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'form_colors.dart';
import 'form_constants.dart';

class FormStyles {
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: FormColors.surfaceColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.borderColor,
        width: FormConstants.borderWidth,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.borderColor,
        width: FormConstants.borderWidth,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.primaryColor,
        width: FormConstants.focusedBorderWidth,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.errorColor,
        width: FormConstants.borderWidth,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.errorColor,
        width: FormConstants.focusedBorderWidth,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FormConstants.borderRadius),
      borderSide: const BorderSide(
        color: FormColors.disabledColor,
        width: FormConstants.borderWidth,
      ),
    ),
    labelStyle: const TextStyle(
      color: FormColors.textSecondaryColor,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    hintStyle: const TextStyle(
      color: FormColors.textHintColor,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: const TextStyle(
      color: FormColors.errorColor,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FormConstants.defaultPadding,
      vertical: FormConstants.defaultPadding,
    ),
  );

  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: FormColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: FormColors.primaryColor.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FormConstants.buttonBorderRadius),
    ),
    minimumSize: const Size(double.infinity, FormConstants.buttonHeight),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: FormColors.primaryColor,
    side: const BorderSide(
      color: FormColors.primaryColor,
      width: FormConstants.borderWidth,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FormConstants.buttonBorderRadius),
    ),
    minimumSize: const Size(double.infinity, FormConstants.buttonHeight),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static TextStyle get titleTextStyle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: FormColors.textPrimaryColor,
  );

  static TextStyle get subtitleTextStyle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: FormColors.textSecondaryColor,
  );

  static TextStyle get bodyTextStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FormColors.textPrimaryColor,
  );

  static TextStyle get captionTextStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: FormColors.textSecondaryColor,
  );

  static TextStyle get errorTextStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FormColors.errorColor,
  );

  static TextStyle get successTextStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FormColors.successColor,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: FormColors.cardColor,
    borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get errorCardDecoration => BoxDecoration(
    color: FormColors.errorColorLight,
    borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
    border: Border.all(
      color: FormColors.errorColor,
      width: FormConstants.borderWidth,
    ),
  );

  static BoxDecoration get successCardDecoration => BoxDecoration(
    color: FormColors.successColorLight,
    borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
    border: Border.all(
      color: FormColors.successColor,
      width: FormConstants.borderWidth,
    ),
  );
}
