import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/settings_notifier.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';
import '../shared/settings_list_tile.dart';

/// Seção de Notificações nas configurações
class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Notificações',
          icon: Icons.notifications,
          showIcon: false,
        ),
        SettingsCard(
          child: settingsState.when(
            data: (state) => SettingsListTile(
              leadingIcon: Icons.notifications_active,
              title: 'Notificações push',
              subtitle: 'Receber notificações do app',
              trailing: Switch.adaptive(
                value: state.notificationsEnabled,
                onChanged: (bool value) async {
                  await ref
                      .read(settingsNotifierProvider.notifier)
                      .setNotificationsEnabled(value);
                },
              ),
              onTap: () async {
                await ref
                    .read(settingsNotifierProvider.notifier)
                    .setNotificationsEnabled(!state.notificationsEnabled);
              },
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Erro: $error'),
            ),
          ),
        ),
      ],
    );
  }
}
