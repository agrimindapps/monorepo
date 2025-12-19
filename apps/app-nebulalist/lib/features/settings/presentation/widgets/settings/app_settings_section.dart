import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_constants.dart';
import '../../dialogs/dialogs.dart';
import '../settings_item.dart';
import '../settings_section.dart';

/// App settings section (notifications, theme)
class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Aplicativo',
      children: [
        SettingsItem(
          icon: Icons.notifications,
          title: 'Notificações',
          subtitle: kIsWeb
              ? 'Não disponível na web'
              : 'Configure seus lembretes',
          onTap: () {
            if (!kIsWeb) {
              context.push(AppConstants.notificationsRoute);
            }
          },
        ),
        SettingsItem(
          icon: Icons.palette,
          title: 'Tema',
          subtitle: 'Escolha entre claro, escuro ou automático',
          onTap: () => _showThemeDialog(context),
        ),
      ],
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const ThemeSelectionDialog(),
    );
  }
}
