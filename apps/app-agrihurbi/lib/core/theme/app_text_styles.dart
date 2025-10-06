import 'package:flutter/material.dart';

/// Centralized text styles with constant values
/// This provides consistency and eliminates scattered TextStyle definitions
class AppTextStyles {
  AppTextStyles._();
  
  /// Display Large - For large headlines (32sp)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Display Medium - For medium headlines (28sp)
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
    height: 1.2,
  );

  /// Display Small - For small headlines (24sp)
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
    height: 1.2,
  );
  
  /// Headline Large - For section headers (22sp)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Headline Medium - For subsection headers (20sp)
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Headline Small - For small headers (18sp)
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
    height: 1.4,
  );
  
  /// Title Large - For card titles and important labels (16sp)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Title Medium - For medium titles (14sp)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Title Small - For small titles (12sp)
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF212121),
    height: 1.4,
  );
  
  /// Body Large - For main body text (16sp)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF212121),
    height: 1.6,
  );

  /// Body Medium - For secondary body text (14sp)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF212121),
    height: 1.6,
  );

  /// Body Small - For small body text (12sp)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
    height: 1.6,
  );
  
  /// Label Large - For prominent labels and buttons (14sp)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Label Medium - For medium labels (12sp)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF757575),
    height: 1.4,
  );

  /// Label Small - For small labels and captions (10sp)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF757575),
    height: 1.4,
  );
  
  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Card title style
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFF212121),
    height: 1.4,
  );

  /// Card subtitle style
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
    height: 1.4,
  );

  /// App bar title style
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  );

  /// Tab label style
  static const TextStyle tabLabel = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  /// Price display style - for market prices
  static const TextStyle priceDisplay = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    color: Color(0xFF212121),
  );

  /// Price change style - for market price changes
  static const TextStyle priceChange = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  /// Caption style - for small explanatory text
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
    height: 1.4,
  );

  /// Overline style - for categories and tags
  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF757575),
    letterSpacing: 0.5,
    height: 1.4,
  );
  
  /// Success text style
  static const TextStyle success = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF388E3C),
  );

  /// Error text style
  static const TextStyle error = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFFD32F2F),
  );

  /// Warning text style
  static const TextStyle warning = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFFF57C00),
  );

  /// Info text style
  static const TextStyle info = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1976D2),
  );
  
  /// Get market trend text style based on value
  static TextStyle getMarketTrendStyle(double changeValue) {
    if (changeValue > 0) {
      return priceChange.copyWith(color: const Color(0xFF4CAF50));
    } else if (changeValue < 0) {
      return priceChange.copyWith(color: const Color(0xFFD32F2F));
    }
    return priceChange.copyWith(color: const Color(0xFF9E9E9E));
  }

  /// Get status text style based on status type
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

  /// Get responsive text style based on screen size
  static TextStyle getResponsiveStyle(BuildContext context, TextStyle baseStyle) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * 1.2,
      );
    } else if (width >= 768) {
      return baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14) * 1.1,
      );
    }
    return baseStyle;
  }
}