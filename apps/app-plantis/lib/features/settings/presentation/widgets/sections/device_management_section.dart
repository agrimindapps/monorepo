import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../../core/providers/settings_providers.dart';
import '../../../../../core/theme/plantis_colors.dart';
import '../../providers/settings_notifier.dart';
import '../dialogs/device_management_dialog.dart';

/// Seção de gerenciamento de dispositivos conectados
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsNotifierProvider);

    return settingsState.when<Widget>(
      data: (SettingsState state) {
        final deviceCount = state.activeDeviceCount;
        const maxDevices = 3;
        final progress = deviceCount / maxDevices;

        return InkWell(
          onTap: () => _showDeviceManagementDialog(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispositivos Conectados',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$deviceCount de $maxDevices dispositivos ativos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Indicador de progresso
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(progress),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$deviceCount/$maxDevices',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(progress),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de gerenciar
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (Object error, StackTrace _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Erro ao carregar dispositivos',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.66) return Colors.orange;
    return PlantisColors.primary;
  }

  void _showDeviceManagementDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const DeviceManagementDialog(),
    );
  }
}
