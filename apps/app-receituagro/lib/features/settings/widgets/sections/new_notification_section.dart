import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../presentation/providers/index.dart';
import '../shared/section_header.dart';
import '../shared/settings_card.dart';

/// Notification Settings Section
/// Allows users to control notification preferences
class NewNotificationSection extends ConsumerWidget {
  const NewNotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationSettingsProvider);

    return Column(
      children: [
        const SectionHeader(title: 'Notificações'),
        SettingsCard(
          child: Column(
            children: [
              _buildNotificationsToggle(context, ref, notificationState),
              if (notificationState.isLoading ||
                  notificationState.error != null)
                const Divider(height: 1),
              if (notificationState.isLoading) _buildLoadingIndicator(),
              if (notificationState.error != null)
                _buildErrorMessage(context, notificationState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsToggle(
    BuildContext context,
    WidgetRef ref,
    NotificationState notificationState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificações Gerais',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Receba alertas e atualizações importantes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: notificationState.settings.notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleNotifications();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    NotificationState notificationState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notificationState.error ?? 'Erro desconhecido',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
