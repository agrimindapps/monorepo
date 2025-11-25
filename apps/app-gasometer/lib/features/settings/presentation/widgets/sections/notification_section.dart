import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_notifier.dart';
import '../shared/settings_card.dart';
import '../shared/settings_item.dart';

/// Seção de notificações - gerencia configurações de notificações
class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final notificationsEnabled =
        settingsAsync.value?.notificationsEnabled ?? true;

    return SettingsCard(
      title: 'Notificações',
      icon: Icons.notifications,
      children: [
        SettingsItem(
          icon: Icons.notifications_active,
          title: 'Receber Notificações',
          subtitle: 'Ativar ou desativar todas as notificações',
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: settingsAsync.isLoading
                ? null
                : (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(value);
                  },
          ),
        ),
      ],
    );
  }
}
