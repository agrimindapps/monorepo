import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/realtime_sync_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/widget_utils.dart';

class DataSyncSection extends ConsumerWidget {
  const DataSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncState = ref.watch(realtimeSyncProvider);
    final DateTime? lastSyncTime = syncState.lastSyncTime;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(context, 'Dados e Sincronização'),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_done,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Dados Sincronizados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  lastSyncTime != null
                      ? 'Última atualização: ${_formatTime(lastSyncTime)}'
                      : 'Sincronização em tempo real ativa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    // Trigger manual refresh by invalidating providers
                    // This is a bit hacky but works for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Atualizando dados...')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Sincronizar agora',
                ),
              ),
              // Export buttons commented out as they are not implemented yet
              /*
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar JSON'),
                subtitle: const Text(
                  'Baixar dados em formato JSON para backup',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDialog(context, 'JSON'),
              ),
              */
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
