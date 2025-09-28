import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Seção de Notificações nas configurações
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Notificações',
          icon: Icons.notifications,
          showIcon: false,
        ),
        SettingsCard(
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return SettingsListTile(
                leadingIcon: Icons.notifications_active,
                title: 'Notificações push',
                subtitle: 'Receber notificações do app',
                trailing: Switch(
                  value: settingsProvider.notificationsEnabled,
                  onChanged: (bool value) async {
                    await settingsProvider.setNotificationsEnabled(value);
                  },
                  activeColor: SettingsDesignTokens.primaryColor,
                ),
                onTap: () async {
                  await settingsProvider.setNotificationsEnabled(
                    !settingsProvider.notificationsEnabled,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}