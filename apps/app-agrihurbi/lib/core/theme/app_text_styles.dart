import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:flutter/material.dart';

/// A centralized collection of standardized [TextStyle]s for the application.
///
/// This class ensures typographic consistency by providing a predefined set of
/// styles that are derived from the [DesignTokens].
class AppTextStyles {
  AppTextStyles._();

  // --- TYPOGRAPHY SCALE ---

  /// Display styles are reserved for very large, important text or numerals.
  static const TextStyle displayLarge = TextStyle(
    fontSize: DesignTokens.Typography.f32,
    fontWeight: DesignTokens.Typography.bold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightTight,
    letterSpacing: DesignTokens.Typography.letterSpacingTight,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: DesignTokens.Typography.f28,
    fontWeight: DesignTokens.Typography.bold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightTight,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: DesignTokens.Typography.f24,
    fontWeight: DesignTokens.Typography.bold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightTight,
  );

  /// Headline styles are best for titles and section headers.
  static const TextStyle headlineLarge = TextStyle(
    fontSize: DesignTokens.Typography.f22,
    fontWeight: DesignTokens.Typography.semiBold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: DesignTokens.Typography.f20,
    fontWeight: DesignTokens.Typography.semiBold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: DesignTokens.Typography.f18,
    fontWeight: DesignTokens.Typography.semiBold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );

  /// Title styles are well-suited for card titles and important labels.
  static const TextStyle titleLarge = TextStyle(
    fontSize: DesignTokens.Typography.f16,
    fontWeight: DesignTokens.Typography.semiBold,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: DesignTokens.Typography.f14,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: DesignTokens.Typography.f12,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );

  /// Body styles are ideal for paragraphs and other long-form content.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: DesignTokens.Typography.f16,
    fontWeight: DesignTokens.Typography.regular,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightRelaxed,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: DesignTokens.Typography.f14,
    fontWeight: DesignTokens.Typography.regular,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightRelaxed,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: DesignTokens.Typography.f12,
    fontWeight: DesignTokens.Typography.regular,
    color: DesignTokens.Colors.textSecondary,
    height: DesignTokens.Typography.lineHeightRelaxed,
  );

  /// Label styles are used for buttons, captions, and other supplementary text.
  static const TextStyle labelLarge = TextStyle(
    fontSize: DesignTokens.Typography.f14,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textPrimary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: DesignTokens.Typography.f12,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textSecondary,
    height: DesignTokens.Typography.lineHeightNormal,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: DesignTokens.Typography.f10,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textSecondary,
    height: DesignTokens.Typography.lineHeightNormal,
  );

  // --- SPECIFIC & SEMANTIC STYLES ---

  /// The default style for button text.
  static const TextStyle button = TextStyle(
    fontSize: DesignTokens.Typography.f16,
    fontWeight: DesignTokens.Typography.semiBold,
    letterSpacing: DesignTokens.Typography.letterSpacingWide,
  );

  /// The default style for card titles. Alias for [headlineSmall].
  static const TextStyle cardTitle = headlineSmall;

  /// The default style for card subtitles.
  static final TextStyle cardSubtitle = bodyMedium.copyWith(
    color: DesignTokens.Colors.textSecondary,
  );

  /// The default style for app bar titles.
  static final TextStyle appBarTitle = headlineMedium.copyWith(
    color: DesignTokens.Colors.textLight,
  );

  /// The default style for tab labels.
  static const TextStyle tabLabel = titleMedium;

  /// A prominent style for displaying prices.
  static const TextStyle priceDisplay = TextStyle(
    fontSize: DesignTokens.Typography.f20,
    fontWeight: DesignTokens.Typography.bold,
    color: DesignTokens.Colors.textPrimary,
  );

  /// The style for indicating a price change.
  static const TextStyle priceChange = titleMedium;

  /// A style for small, explanatory text. Alias for [bodySmall].
  static const TextStyle caption = bodySmall;

  /// A style for categories and tags.
  static const TextStyle overline = TextStyle(
    fontSize: DesignTokens.Typography.f10,
    fontWeight: DesignTokens.Typography.medium,
    color: DesignTokens.Colors.textSecondary,
    letterSpacing: DesignTokens.Typography.letterSpacingWide,
    height: DesignTokens.Typography.lineHeightNormal,
  );

  // --- STATUS STYLES ---

  /// A text style for success messages.
  static final TextStyle success = labelLarge.copyWith(color: DesignTokens.Colors.success);

  /// A text style for error messages.
  static final TextStyle error = labelLarge.copyWith(color: DesignTokens.Colors.error);

  /// A text style for warning messages.
  static final TextStyle warning = labelLarge.copyWith(color: DesignTokens.Colors.warning);

  /// A text style for informational messages.
  static final TextStyle info = labelLarge.copyWith(color: DesignTokens.Colors.info);

  // --- HELPER METHODS ---

  /// Returns a [TextStyle] for market trends based on the change value.
  static TextStyle getMarketTrendStyle(double changeValue) {
    if (changeValue > 0) return priceChange.copyWith(color: DesignTokens.Colors.marketUp);
    if (changeValue < 0) return priceChange.copyWith(color: DesignTokens.Colors.marketDown);
    return priceChange.copyWith(color: DesignTokens.Colors.marketNeutral);
  }

  /// Returns a [TextStyle] appropriate for a given status string.
  static TextStyle getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'completed':
        return success;
      case 'error':
      case 'failed':
      case 'inactive':
        return error;
      case 'warning':
      case 'pending':
        return warning;
      case 'info':
      default:
        return info;
    }
  }

  /// Returns a responsive [TextStyle] by scaling the font size based on screen width.
  static TextStyle getResponsiveStyle(BuildContext context, TextStyle baseStyle) {
    if (DesignTokens.isDesktop(context)) {
      return baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14) * 1.2);
    }
    if (DesignTokens.isTablet(context)) {
      return baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14) * 1.1);
    }
    return baseStyle;
  }
}