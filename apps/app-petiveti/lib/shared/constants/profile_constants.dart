import 'package:flutter/material.dart';

/// A centralized collection of constants for the Profile feature.
///
/// This includes UI strings, accessibility labels, layout values, icons, and
/// routes to ensure consistency and ease of maintenance.
class ProfileConstants {
  ProfileConstants._();

  /// Constants for user-facing UI strings.
  /// These should be moved to a proper localization (l10n) system.
  abstract class UI {
    UI._();
    static const String appName = 'PetiVeti';
    static const String financialSectionTitle = 'Financial';
    static const String settingsSectionTitle = 'Settings';
    static const String supportSectionTitle = 'Support';
    static const String expensesMenuTitle = 'Expense Management';
    static const String subscriptionMenuTitle = 'Subscriptions';
    static const String notificationsMenuTitle = 'Notifications';
    static const String themeMenuTitle = 'Theme';
    static const String languageMenuTitle = 'Language';
    static const String backupMenuTitle = 'Backup & Sync';
    static const String helpMenuTitle = 'Help Center';
    static const String contactSupportMenuTitle = 'Contact Support';
    static const String aboutMenuTitle = 'About the App';
    static const String premiumBadgeText = 'PREMIUM';
    static const String logoutButtonText = 'Log Out';
    static const String logoutDialogTitle = 'Confirm Logout';
    static const String logoutDialogContent = 'Are you sure you want to log out?';
    static const String logoutConfirmText = 'Log Out';
    static const String cancelButtonText = 'Cancel';
    static const String okButtonText = 'OK';
    static const String comingSoonContent = 'Feature in development';
    static const String aboutDescription = 'A complete app for veterinary care';
    static const String aboutTechnology = 'Developed with Flutter';
    static const String supportContactInfo = 'Email: support@petiveti.com\nPhone: (11) 99999-9999';

    static String versionText(String version) => 'Version $version'; // l10n
  }

  /// Default values used as fallbacks or placeholders.
  abstract class Defaults {
    Defaults._();
    static const String appVersion = '1.0.0';
    static const String userName = 'User';
    static const String userEmail = 'email@example.com';
  }

  /// Constants for accessibility labels and hints.
  /// These should also be localized.
  abstract class Accessibility {
    Accessibility._();
    static const String logoutSemanticLabel = 'Log out of user account';
    static const String logoutSemanticHint = 'Logs out and returns to the login screen';
    static const String profilePhotoSemanticLabel = 'User profile photo';
    static const String defaultAvatarSemanticLabel = 'Default user avatar';
    static const String supportContactSemanticLabel = 'Support contact information';

    static String menuItemSemanticHint(String title) => 'Navigate to $title'; // l10n
  }

  /// Constants for navigation routes related to the Profile feature.
  abstract class Routes {
    Routes._();
    static const String expenses = '/expenses';
    static const String subscription = '/subscription';
    static const String login = '/login';
  }

  /// Icon constants for the Profile feature.
  abstract class Icons {
    Icons._();
    static const IconData expenses = Icons.receipt_long;
    static const IconData subscription = Icons.star;
    static const IconData notifications = Icons.notifications;
    static const IconData theme = Icons.palette;
    static const IconData language = Icons.language;
    static const IconData backup = Icons.cloud_sync;
    static const IconData help = Icons.help;
    static const IconData support = Icons.support_agent;
    static const IconData about = Icons.info;
    static const IconData logout = Icons.logout;
    static const IconData defaultPerson = Icons.person;
    static const IconData menuArrow = Icons.chevron_right;
    static const IconData app = Icons.pets;
  }

  /// Layout and dimension constants.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Dimensions {
    Dimensions._();
    static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
    static const EdgeInsets headerPadding = EdgeInsets.all(20.0);
    static const EdgeInsets menuTitlePadding = EdgeInsets.only(left: 4, bottom: 8);
    static const EdgeInsets premiumBadgePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 4);
    static const EdgeInsets logoutButtonPadding = EdgeInsets.symmetric(vertical: 12);
    static const double avatarRadius = 40.0;
    static const double avatarImageSize = 80.0;
    static const double aboutIconSize = 64.0;
    static const double headerBorderRadius = 16.0;
    static const double premiumBadgeBorderRadius = 12.0;
    static const double profileNameFontSize = 20.0;
    static const double profileEmailFontSize = 14.0;
    static const double premiumTextFontSize = 12.0;
    static const FontWeight profileNameFontWeight = FontWeight.bold;
    static const FontWeight premiumTextFontWeight = FontWeight.bold;
    static const double headerTopSpacing = 32.0;
    static const double sectionSpacing = 24.0;
    static const double logoutTopSpacing = 32.0;
    static const double versionBottomSpacing = 16.0;
    static const double avatarToNameSpacing = 12.0;
    static const double nameToEmailSpacing = 4.0;
    static const double emailToPremiumSpacing = 8.0;
  }

  /// Color constants specific to the Profile feature.
  /// TODO: These should be migrated to a centralized PetiVetiDesignTokens file.
  abstract class Colors {
    Colors._();
    static const Color avatarBackground = Colors.white;
    static const Color profileName = Colors.white;
    static const Color profileEmail = Colors.white;
    static const Color avatarIcon = Colors.white;
    static const Color premiumBadgeBackground = Colors.amber;
    static const Color premiumBadgeText = Colors.black;
    static const Color versionText = Colors.grey;
    static const double avatarBackgroundOpacity = 0.2;
    static const double gradientEndOpacity = 0.8;
    static const double emailTextOpacity = 0.9;
  }
}