// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'form_colors.dart';
import 'form_constants.dart';

/// Text styles and theme configurations for vaccine forms
class FormStyles {
  
  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: FormColors.textPrimary,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: FormColors.textSecondary,
  );
  
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: FormColors.fieldLabel,
  );
  
  static const TextStyle fieldTextStyle = TextStyle(
    fontSize: 16.0,
    color: FormColors.fieldText,
  );
  
  static const TextStyle hintStyle = TextStyle(
    fontSize: 16.0,
    color: FormColors.fieldHint,
  );
  
  static const TextStyle errorStyle = TextStyle(
    fontSize: 12.0,
    color: FormColors.errorText,
  );
  
  static const TextStyle counterStyle = TextStyle(
    fontSize: FormConstants.counterFontSize,
    color: FormColors.counterNormal,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: FormColors.buttonTextPrimary,
  );
  
  // Input decoration themes
  static InputDecoration getFieldDecoration({
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
    String? errorText,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      errorText: errorText,
      enabled: enabled,
      filled: true,
      fillColor: enabled ? FormColors.fieldBackground : FormColors.fieldBackground.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
        borderSide: const BorderSide(
          color: FormColors.fieldBorder,
          width: FormConstants.fieldBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
        borderSide: const BorderSide(
          color: FormColors.fieldBorder,
          width: FormConstants.fieldBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
        borderSide: const BorderSide(
          color: FormColors.fieldBorderFocused,
          width: FormConstants.fieldBorderFocusedWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
        borderSide: const BorderSide(
          color: FormColors.error,
          width: FormConstants.fieldBorderFocusedWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
        borderSide: const BorderSide(
          color: FormColors.error,
          width: FormConstants.fieldBorderFocusedWidth,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FormConstants.spacingMedium,
        vertical: FormConstants.spacingMedium,
      ),
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      errorStyle: errorStyle,
    );
  }
  
  // Button styles
  static ButtonStyle getPrimaryButtonStyle({bool enabled = true}) {
    return ElevatedButton.styleFrom(
      backgroundColor: enabled ? FormColors.buttonPrimary : FormColors.buttonDisabled,
      foregroundColor: enabled ? FormColors.buttonTextPrimary : FormColors.buttonTextDisabled,
      elevation: enabled ? FormConstants.buttonElevation : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormConstants.buttonBorderRadius),
      ),
      minimumSize: const Size(FormConstants.buttonMinWidth, FormConstants.buttonHeight),
      textStyle: buttonTextStyle,
    );
  }
  
  static ButtonStyle getSecondaryButtonStyle({bool enabled = true}) {
    return OutlinedButton.styleFrom(
      foregroundColor: enabled ? FormColors.buttonSecondary : FormColors.buttonTextDisabled,
      side: BorderSide(
        color: enabled ? FormColors.buttonSecondary : FormColors.buttonDisabled,
        width: FormConstants.fieldBorderWidth,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormConstants.buttonBorderRadius),
      ),
      minimumSize: const Size(FormConstants.buttonMinWidth, FormConstants.buttonHeight),
      textStyle: buttonTextStyle,
    );
  }
  
  // Card styles
  static BoxDecoration getCardDecoration() {
    return BoxDecoration(
      color: FormColors.cardBackground,
      borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
      boxShadow: const [
        BoxShadow(
          color: FormColors.cardShadow,
          blurRadius: FormConstants.shadowBlurRadius,
          spreadRadius: FormConstants.shadowSpreadRadius,
          offset: Offset(FormConstants.shadowOffsetX, FormConstants.shadowOffsetY),
        ),
      ],
    );
  }
  
  // Dialog theme
  static DialogTheme getDialogTheme() {
    return DialogTheme(
      backgroundColor: FormColors.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
      ),
      elevation: FormConstants.cardElevation,
    );
  }
  
  // Loading overlay decoration
  static BoxDecoration getLoadingOverlayDecoration() {
    return const BoxDecoration(
      color: FormColors.loadingBackground,
    );
  }
  
  // Error message decoration
  static BoxDecoration getErrorDecoration() {
    return BoxDecoration(
      color: FormColors.errorLight,
      borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
      border: Border.all(
        color: FormColors.error,
        width: FormConstants.fieldBorderWidth,
      ),
    );
  }
  
  // Success message decoration  
  static BoxDecoration getSuccessDecoration() {
    return BoxDecoration(
      color: FormColors.successLight,
      borderRadius: BorderRadius.circular(FormConstants.fieldBorderRadius),
      border: Border.all(
        color: FormColors.success,
        width: FormConstants.fieldBorderWidth,
      ),
    );
  }
  
  // Form container decoration
  static BoxDecoration getFormContainerDecoration() {
    return BoxDecoration(
      color: FormColors.background,
      borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
    );
  }
  
  // Character counter style
  static TextStyle getCounterStyle(int currentLength, int maxLength) {
    return counterStyle.copyWith(
      color: FormColorsExtension.getCounterColor(currentLength, maxLength),
    );
  }
}
