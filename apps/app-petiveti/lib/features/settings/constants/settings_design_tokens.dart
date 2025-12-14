import 'package:flutter/material.dart';

/// Design tokens específicos para as páginas de configurações do PetiVeti
class SettingsDesignTokens {
  // Colors
  static const Color primaryColor = Color(0xFF5C6BC0);
  static const Color primaryDark = Color(0xFF3949AB);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successBackgroundColor = Color(0x1A4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color errorBackgroundColor = Color(0x1AF44336);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color premiumColor = Color(0xFFFFD700);

  // Icons
  static const IconData configIcon = Icons.settings;
  static const IconData premiumIcon = Icons.workspace_premium;
  static const IconData notificationIcon = Icons.notifications_active;
  static const IconData themeIcon = Icons.dark_mode;
  static const IconData themeLightIcon = Icons.light_mode;
  static const IconData checkIcon = Icons.check_circle;
  static const IconData petIcon = Icons.pets;

  // Spacing
  static const EdgeInsets sectionMargin = EdgeInsets.symmetric(vertical: 4.0);
  static const EdgeInsets sectionHeaderPadding =
      EdgeInsets.fromLTRB(16, 16, 16, 8);
  static const double cardElevation = 2.0;
  static const double cardRadius = 16.0;
  static const double sectionIconSize = 20.0;
  static const double maxPageWidth = 1120.0;
  static const double cardBorderRadius = 16.0;
  static const double iconContainerRadius = 8.0;
  static const double sectionSpacing = 16.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(8.0);
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0);
  static const EdgeInsets iconPadding = EdgeInsets.all(8.0);

  static TextStyle getSectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ) ??
        const TextStyle(fontWeight: FontWeight.w600);
  }

  static TextStyle getListTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ) ??
        const TextStyle(fontWeight: FontWeight.w500);
  }

  static TextStyle getListSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ) ??
        const TextStyle();
  }

  static BoxDecoration getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(cardBorderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration getSuccessIconDecoration() {
    return BoxDecoration(
      color: successBackgroundColor,
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }

  static BoxDecoration getErrorIconDecoration() {
    return BoxDecoration(
      color: errorBackgroundColor,
      borderRadius: BorderRadius.circular(iconContainerRadius),
    );
  }

  static SnackBar getSuccessSnackbar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(checkIcon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: successColor,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static SnackBar getErrorSnackbar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: errorColor,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
