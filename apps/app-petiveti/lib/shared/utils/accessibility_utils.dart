import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A collection of utilities and helpers to improve accessibility across the
/// PetiVeti application, ensuring a more inclusive design.
///
/// This library provides helpers for:
/// - Creating accessible semantics for common widgets.
/// - Calculating and verifying color contrast ratios.
/// - Managing focus and screen reader announcements.
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Wraps a widget with button semantics for screen readers.
  ///
  /// - [label]: A clear, concise description of the button's action.
  /// - [hint]: Optional additional context for the button's behavior.
  /// - [onTap]: The callback to be executed when the button is activated.
  /// - [isToggled]: For toggle buttons, indicates the current toggled state.
  static Widget accessibleButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool enabled = true,
    bool isSelected = false,
    bool isToggled = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      selected: isSelected,
      toggled: isToggled,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a list item widget with enhanced semantics for better navigation.
  ///
  /// Provides context like "item X of Y" and hints for interactive elements.
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    String? hint,
    int? index,
    int? totalItems,
    VoidCallback? onTap,
    bool hasSubItems = false,
  }) {
    final positionHint = (index != null && totalItems != null)
        ? ', item ${index + 1} of $totalItems' // l10n
        : '';
    final subItemHint = hasSubItems
        ? 'Has sub-items. Double-tap to expand.' // l10n
        : '';

    final finalHint = [hint, subItemHint].where((s) => s != null && s.isNotEmpty).join('. ');

    return Semantics(
      label: '$label$positionHint',
      hint: finalHint.isNotEmpty ? finalHint : null,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a text field with semantics for validation and input guidance.
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? helperText,
    String? errorText,
    bool isRequired = false,
    int? characterCount,
    int? maxLength,
  }) {
    final semanticLabel = '$label${isRequired ? ", required" : ""}'.trim(); // l10n
    final hintParts = [
      if (errorText != null) 'Error: $errorText', // l10n
      if (hint != null) hint,
      if (helperText != null) helperText,
      if (characterCount != null && maxLength != null)
        '$characterCount of $maxLength characters', // l10n
    ];

    return Semantics(
      label: semanticLabel,
      hint: hintParts.isNotEmpty ? hintParts.join('. ') : null,
      textField: true,
      child: child,
    );
  }

  /// Makes a widget a "live region" to announce dynamic content changes.
  static Widget liveRegion({
    required Widget child,
    required String message,
    LiveRegionPoliteness politeness = LiveRegionPoliteness.polite,
  }) {
    return Semantics(
      label: message,
      liveRegion: true,
      child: child,
    );
  }

  /// Announces a status message to the screen reader.
  static void announceStatus(
    BuildContext context,
    String message, {
    LiveRegionPoliteness politeness = LiveRegionPoliteness.polite,
  }) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: politeness == LiveRegionPoliteness.assertive
          ? Assertiveness.assertive
          : Assertiveness.polite,
    );
  }

  /// Safely requests focus for a given [focusNode].
  static void requestFocus(FocusNode focusNode, {Duration? delay}) {
    void _requestFocus() {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    }

    if (delay != null) {
      Future.delayed(delay, _requestFocus);
    } else {
      _requestFocus();
    }
  }

  /// Calculates the contrast ratio between two colors per WCAG guidelines.
  ///
  /// A ratio of 4.5:1 is the minimum for normal text (AA), and 3:1 for large text.
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final lighter = max(fgLuminance, bgLuminance);
    final darker = min(fgLuminance, bgLuminance);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if a color combination meets a specific WCAG level.
  static bool meetsWCAGRequirements(
    Color foreground,
    Color background, {
    WCAGLevel level = WCAGLevel.AA,
    bool isLargeText = false,
  }) {
    final ratio = calculateContrastRatio(foreground, background);
    switch (level) {
      case WCAGLevel.AA:
        return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
      case WCAGLevel.AAA:
        return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
    }
  }

  /// Finds an accessible color by adjusting the [baseColor] against a [background].
  ///
  /// This method darkens or lightens the `baseColor` until it meets the
  /// required contrast ratio.
  static Color findAccessibleColor(
    Color baseColor,
    Color background, {
    WCAGLevel level = WCAGLevel.AA,
    bool isLargeText = false,
  }) {
    if (meetsWCAGRequirements(baseColor, background, level: level, isLargeText: isLargeText)) {
      return baseColor;
    }

    // Try darkening first
    for (int i = 1; i <= 10; i++) {
      final adjusted = Color.lerp(baseColor, Colors.black, i * 0.1)!;
      if (meetsWCAGRequirements(adjusted, background, level: level, isLargeText: isLargeText)) {
        return adjusted;
      }
    }

    // Then try lightening
    for (int i = 1; i <= 10; i++) {
      final adjusted = Color.lerp(baseColor, Colors.white, i * 0.1)!;
      if (meetsWCAGRequirements(adjusted, background, level: level, isLargeText: isLargeText)) {
        return adjusted;
      }
    }

    // As a last resort, return black or white.
    return calculateContrastRatio(Colors.black, background) >
            calculateContrastRatio(Colors.white, background)
        ? Colors.black
        : Colors.white;
  }

  // TODO: Implement this testing utility with a testing framework like `flutter_test`.
  /// **NOTE: This is a placeholder for a test utility.**
  ///
  /// In a real test environment, this would use `find.bySemanticsLabel` and
  /// other matchers to verify the accessibility properties of a widget.
  static void verifySemantics({
    required String semanticLabel,
    String? hint,
    bool isButton = false,
    bool isTextField = false,
    bool enabled = true,
  }) {
    // Example implementation for a test:
    // expect(find.bySemanticsLabel(semanticLabel), findsOneWidget);
  }
}

/// Defines how urgently screen readers should announce live region changes.
enum LiveRegionPoliteness {
  /// Waits for the user to pause before making an announcement.
  polite,
  /// Interrupts the current speech to make an announcement immediately.
  assertive,
}

/// Defines the WCAG accessibility compliance levels.
enum WCAGLevel {
  /// Level AA - The recommended minimum standard for most web content.
  AA,
  /// Level AAA - The enhanced "gold standard" for accessibility.
  AAA,
}

/// A collection of common, accessibility-related constants.
abstract class AccessibilityConstants {
  AccessibilityConstants._();
  static const double minTouchTarget = 48.0;
  static const double minReadableTextSize = 14.0;
  static const double largeTextSize = 18.0;

  // --- WCAG Contrast Ratios ---
  static const double minContrastRatioNormal = 4.5;
  static const double minContrastRatioLarge = 3.0;
  static const double enhancedContrastRatioNormal = 7.0;
  static const double enhancedContrastRatioLarge = 4.5;

  // --- Animation Durations ---
  static const Duration focusAnimationDuration = Duration(milliseconds: 200);
  static const Duration announceDelay = Duration(milliseconds: 100);

  // --- Common Labels (should be localized) ---
  static const String closeButtonLabel = 'Close'; // l10n
  static const String backButtonLabel = 'Back'; // l10n
  static const String menuButtonLabel = 'Open menu'; // l10n
  static const String searchButtonLabel = 'Search'; // l10n
  static const String addButtonLabel = 'Add'; // l10n
  static const String editButtonLabel = 'Edit'; // l10n
  static const String deleteButtonLabel = 'Delete'; // l10n
  static const String saveButtonLabel = 'Save'; // l10n
  static const String cancelButtonLabel = 'Cancel'; // l10n
}