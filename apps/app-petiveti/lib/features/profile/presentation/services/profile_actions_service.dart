import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/dialogs/app_dialogs.dart';

/// Service responsible for handling profile page actions and business logic.
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles profile-related actions
/// - **Open/Closed**: Easy to add new actions without modifying existing code
/// - **Dependency Inversion**: Can be mocked for testing
///
/// **Usage:**
/// ```dart
/// final actionsService = ref.read(profileActionsServiceProvider);
/// actionsService.showNotificationsSettings(context);
/// ```
class ProfileActionsService {
  /// Shows coming soon dialog for features under development
  void showComingSoonDialog(BuildContext context, String title) {
    AppDialogs.showComingSoon(context, title);
  }

  /// Navigates to notifications settings page
  void showNotificationsSettings(BuildContext context) {
    context.push('/notifications-settings');
  }

  /// Navigates to settings page (theme and other preferences)
  void showThemeSettings(BuildContext context) {
    context.push('/settings');
  }

  /// Navigates to settings page (language settings)
  void showLanguageSettings(BuildContext context) {
    context.push('/settings');
  }

  /// Navigates to settings page (sync settings)
  void showBackupSettings(BuildContext context) {
    context.push('/settings');
  }

  /// Opens help center URL
  Future<void> showHelp(BuildContext context) async {
    final Uri url = Uri.parse('https://petiveti.com/ajuda');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Shows contact support dialog
  void contactSupport(BuildContext context) {
    AppDialogs.showContactSupport(
      context,
      supportEmail: 'suporte@petiveti.com',
      supportPhone: '(11) 99999-9999',
      showSocialMedia: true,
    );
  }

  /// Shows about app dialog
  void showAbout(BuildContext context) {
    AppDialogs.showAboutApp(
      context,
      appName: 'PetiVeti',
      appIcon: Icon(
        Icons.pets,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
      customDescription:
          'App completo para cuidados veterinários com calculadoras especializadas, controle de medicamentos, agendamento de consultas e muito mais.',
      showTechnicalInfo: true,
    );
  }

  /// Shows logout confirmation dialog
  void showLogoutDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    AppDialogs.showLogoutConfirmation(
      context,
      onConfirm: onConfirm,
    );
  }
}
