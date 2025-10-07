import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// A centralized collection of standardized [TextStyle]s for the Gasometer app.
///
/// This class ensures typographic consistency by providing a predefined set of
/// styles derived from [GasometerDesignTokens].
class AppTextStyles {
  AppTextStyles._();

  // --- TYPOGRAPHY SCALE ---

  /// For very large, important text or numerals.
  static const TextStyle display = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f32,
    fontWeight: GasometerDesignTokens.Typography.bold,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// For large headlines and section titles.
  static const TextStyle headline = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f24,
    fontWeight: GasometerDesignTokens.Typography.bold,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// For titles of components like cards and dialogs.
  static const TextStyle title = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f20,
    fontWeight: GasometerDesignTokens.Typography.semiBold,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// For subtitles and medium-emphasis text.
  static const TextStyle subtitle = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f16,
    fontWeight: GasometerDesignTokens.Typography.medium,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// The default style for body text and paragraphs.
  static const TextStyle body = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f14,
    fontWeight: GasometerDesignTokens.Typography.regular,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// For secondary body text with less emphasis.
  static final TextStyle bodySecondary = body.copyWith(
    color: GasometerDesignTokens.Colors.textSecondary,
  );

  /// For captions, metadata, and other small text.
  static const TextStyle caption = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f12,
    fontWeight: GasometerDesignTokens.Typography.regular,
    color: GasometerDesignTokens.Colors.textSecondary,
  );

  /// For labels on form fields and other UI elements.
  static const TextStyle label = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f12,
    fontWeight: GasometerDesignTokens.Typography.medium,
    color: GasometerDesignTokens.Colors.textSecondary,
  );

  /// For small, uppercase labels or tags.
  static const TextStyle overline = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f11,
    fontWeight: GasometerDesignTokens.Typography.semiBold,
    letterSpacing: 0.5,
    color: GasometerDesignTokens.Colors.textSecondary,
  );

  // --- SEMANTIC & COMPONENT-SPECIFIC STYLES ---

  /// The default text style for buttons.
  static const TextStyle button = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f16,
    fontWeight: GasometerDesignTokens.Typography.semiBold,
    letterSpacing: 0.5,
  );

  /// A prominent style for displaying prices or important metrics.
  static const TextStyle price = TextStyle(
    fontSize: GasometerDesignTokens.Typography.f24,
    fontWeight: GasometerDesignTokens.Typography.bold,
    color: GasometerDesignTokens.Colors.textPrimary,
  );

  /// A style for titles within premium feature sections.
  static final TextStyle premiumTitle = headline.copyWith(
    color: GasometerDesignTokens.Colors.premiumAccent,
  );

  /// A style for prices within premium feature sections.
  static final TextStyle premiumPrice = display.copyWith(
    color: GasometerDesignTokens.Colors.primary,
  );
}