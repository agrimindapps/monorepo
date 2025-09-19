import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

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
          showIcon: true,
        ),
        SettingsCard(
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return InkWell(
                onTap: () async {
                  await settingsProvider.setNotificationsEnabled(
                    !settingsProvider.notificationsEnabled,
                  );
                },
                borderRadius: BorderRadius.circular(SettingsDesignTokens.cardBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: SettingsDesignTokens.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificações push',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Receber notificações do app',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (bool value) async {
                          await settingsProvider.setNotificationsEnabled(value);
                        },
                        activeColor: SettingsDesignTokens.primaryColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}