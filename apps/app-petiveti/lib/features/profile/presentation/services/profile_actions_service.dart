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
/// final actionsService = getIt<ProfileActionsService>();
/// actionsService.showNotificationsSettings(context);
/// ```
class ProfileActionsService {
  /// Shows coming soon dialog for features under development
  void showComingSoonDialog(BuildContext context, String title) {
    AppDialogs.showComingSoon(context, title);
  }

  /// Shows notifications settings screen
  void showNotificationsSettings(BuildContext context) {
    showComingSoonDialog(context, 'Configurações de Notificação');
  }

  /// Shows theme settings screen
  void showThemeSettings(BuildContext context) {
    showComingSoonDialog(context, 'Configurações de Tema');
  }

  /// Shows language settings screen
  void showLanguageSettings(BuildContext context) {
    showComingSoonDialog(context, 'Configurações de Idioma');
  }

  /// Shows backup and sync settings screen
  void showBackupSettings(BuildContext context) {
    showComingSoonDialog(context, 'Backup e Sincronização');
  }

  /// Shows help center
  void showHelp(BuildContext context) {
    showComingSoonDialog(context, 'Central de Ajuda');
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
