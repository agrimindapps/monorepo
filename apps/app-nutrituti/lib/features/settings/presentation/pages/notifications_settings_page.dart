import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/app_colors.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_switch_item.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: AppColors.contentColorCyan,
        foregroundColor: Colors.white,
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Configure seus lembretes e notificações',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificações Gerais',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SettingsSwitchItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações Push',
                    subtitle: 'Receber alertas e lembretes',
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .setNotificationsEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lembretes Específicos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SettingsSwitchItem(
                    icon: Icons.restaurant_outlined,
                    title: 'Lembretes de Refeições',
                    subtitle: 'Lembrar horários das refeições',
                    value: settings.mealReminders,
                    onChanged: settings.notificationsEnabled
                        ? (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setMealReminders(value);
                          }
                        : null,
                  ),
                  SettingsSwitchItem(
                    icon: Icons.water_drop_outlined,
                    title: 'Lembretes de Hidratação',
                    subtitle: 'Lembrar de beber água',
                    value: settings.waterReminders,
                    onChanged: settings.notificationsEnabled
                        ? (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setWaterReminders(value);
                          }
                        : null,
                  ),
                  SettingsSwitchItem(
                    icon: Icons.fitness_center_outlined,
                    title: 'Lembretes de Exercícios',
                    subtitle: 'Lembrar dos exercícios diários',
                    value: settings.exerciseReminders,
                    onChanged: settings.notificationsEnabled
                        ? (value) {
                            ref
                                .read(settingsProvider.notifier)
                                .setExerciseReminders(value);
                          }
                        : null,
                  ),
                ],
              ),
            ),
            if (!settings.notificationsEnabled)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '⚠️ Ative as notificações gerais para configurar lembretes específicos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
      ),
    );
  }
}
