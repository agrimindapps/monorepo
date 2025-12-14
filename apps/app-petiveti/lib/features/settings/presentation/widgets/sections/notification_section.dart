import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_providers.dart';
import '../shared/new_settings_card.dart';
import '../shared/new_settings_list_tile.dart';
import '../shared/section_header.dart';

/// Seção de notificações - gerencia configurações de notificações
class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final notificationsEnabled =
        settingsAsync.value?.notificationsEnabled ?? true;
    const isWebPlatform = kIsWeb;

    return Column(
      children: [
        const SectionHeader(title: 'Notificações'),
        NewSettingsCard(
          child: NewSettingsListTile(
            leadingIcon: isWebPlatform
                ? Icons.notifications_off_outlined
                : Icons.notifications_active,
            title: 'Receber Notificações',
            subtitle: isWebPlatform
                ? 'Não disponível na versão web'
                : 'Ativar ou desativar todas as notificações',
            enabled: !isWebPlatform,
            trailing: Switch.adaptive(
              value: isWebPlatform ? false : notificationsEnabled,
              onChanged: isWebPlatform || settingsAsync.isLoading
                  ? null
                  : (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateNotificationsEnabled(value);
                    },
            ),
          ),
        ),
      ],
    );
  }
}
