import 'package:flutter/material.dart';

/// Unified theme system for Data Inspector across all apps
/// Combines the best visual elements from each implementation while allowing app customization
class DataInspectorTheme {
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Brightness brightness;
  final bool isDeveloperMode;

  const DataInspectorTheme({
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.brightness,
    this.isDeveloperMode = false,
  });

  /// Creates theme from app context (receituagro/gasometer approach)
  factory DataInspectorTheme.fromContext(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return DataInspectorTheme(
      primaryColor: colorScheme.primary,
      accentColor: colorScheme.secondary,
      backgroundColor: theme.scaffoldBackgroundColor,
      cardColor: theme.cardColor,
      surfaceColor: colorScheme.surface,
      onSurfaceColor: colorScheme.onSurface,
      errorColor: colorScheme.error,
      successColor: Colors.green,
      warningColor: Colors.orange,
      brightness: theme.brightness,
    );
  }

  /// Creates developer-focused dark theme (plantis approach)
  factory DataInspectorTheme.developer({
    Color? primaryColor,
    Color? accentColor,
  }) {
    return DataInspectorTheme(
      primaryColor: primaryColor ?? Colors.teal,
      accentColor: accentColor ?? Colors.tealAccent,
      backgroundColor: Colors.black,
      cardColor: Colors.grey.shade900,
      surfaceColor: Colors.grey.shade800,
      onSurfaceColor: Colors.white,
      errorColor: Colors.redAccent,
      successColor: Colors.greenAccent,
      warningColor: Colors.orangeAccent,
      brightness: Brightness.dark,
      isDeveloperMode: true,
    );
  }

  /// Creates custom theme with app-specific colors
  factory DataInspectorTheme.custom({
    required Color primaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? cardColor,
    Brightness? brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    
    return DataInspectorTheme(
      primaryColor: primaryColor,
      accentColor: accentColor ?? primaryColor.withValues(alpha: 0.7),
      backgroundColor: backgroundColor ?? (isDark ? Colors.black : Colors.white),
      cardColor: cardColor ?? (isDark ? Colors.grey.shade900 : Colors.white),
      surfaceColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      onSurfaceColor: isDark ? Colors.white : Colors.black,
      errorColor: isDark ? Colors.redAccent : Colors.red,
      successColor: isDark ? Colors.greenAccent : Colors.green,
      warningColor: isDark ? Colors.orangeAccent : Colors.orange,
      brightness: brightness ?? Brightness.light,
    );
  }

  /// Gets ThemeData for the inspector
  ThemeData get themeData {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      error: errorColor,
    );

    return ThemeData(
      colorScheme: colorScheme,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.white,
        elevation: 0,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: brightness == Brightness.dark ? Colors.white : Colors.white,
        unselectedLabelColor: (brightness == Brightness.dark ? Colors.white : Colors.white).withValues(alpha: 0.7),
        indicatorColor: brightness == Brightness.dark ? Colors.white : Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: brightness == Brightness.dark ? Colors.white : Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontFamily: isDeveloperMode ? 'monospace' : null,
          color: onSurfaceColor,
        ),
      ),
    );
  }

  /// Icon color based on data type (gasometer approach)
  Color getIconColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'hive':
      case 'box':
        return Colors.blue;
      case 'preferences':
      case 'settings':
        return Colors.green;
      case 'cache':
        return Colors.orange;
      case 'favorites':
        return Colors.red;
      case 'offline':
        return Colors.purple;
      default:
        return primaryColor;
    }
  }

  /// Status color for box health (gasometer approach)
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'open':
      case 'available':
        return successColor;
      case 'warning':
      case 'large':
        return warningColor;
      case 'error':
      case 'closed':
      case 'unavailable':
        return errorColor;
      default:
        return onSurfaceColor;
    }
  }

  /// Module-specific colors (gasometer categorization)
  Color getModuleColor(String module) {
    switch (module.toLowerCase()) {
      case 'receituagro':
        return Colors.green;
      case 'plantis':
        return Colors.teal;
      case 'gasometer':
        return Colors.blue;
      case 'petiveti':
        return Colors.purple;
      case 'taskolist':
        return Colors.orange;
      case 'agrihurbi':
        return Colors.brown;
      default:
        return primaryColor;
    }
  }

  /// Copy with modifications
  DataInspectorTheme copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? cardColor,
    Color? surfaceColor,
    Color? onSurfaceColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Brightness? brightness,
    bool? isDeveloperMode,
  }) {
    return DataInspectorTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      onSurfaceColor: onSurfaceColor ?? this.onSurfaceColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      brightness: brightness ?? this.brightness,
      isDeveloperMode: isDeveloperMode ?? this.isDeveloperMode,
    );
  }
}

/// Design tokens for consistent spacing, typography and visual elements
class DataInspectorDesignTokens {
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXl = 48.0;

  // Typography (plantis code display approach)
  static const TextStyle codeTextStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12,
    height: 1.4,
  );

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 14,
    height: 1.3,
  );

  static const TextStyle captionTextStyle = TextStyle(
    fontSize: 12,
    height: 1.2,
  );

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Elevations
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  /// Creates success snackbar (receituagro approach)
  static SnackBar getSuccessSnackbar(String message, {DataInspectorTheme? theme}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: theme?.successColor ?? Colors.green),
          const SizedBox(width: spacingS),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: theme?.successColor ?? Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
    );
  }

  /// Creates error snackbar (receituagro approach)
  static SnackBar getErrorSnackbar(String message, {DataInspectorTheme? theme}) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.error, color: theme?.errorColor ?? Colors.red),
          const SizedBox(width: spacingS),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: theme?.errorColor ?? Colors.red,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusS)),
    );
  }

  /// Creates loading dialog (receituagro approach)
  static Widget getLoadingDialog(String message, {DataInspectorTheme? theme}) {
    return AlertDialog(
      backgroundColor: theme?.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusM)),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme?.primaryColor ?? Colors.blue),
          ),
          const SizedBox(width: spacingM),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}