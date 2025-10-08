import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/sync_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/plantis_colors.dart';
import '../../../shared/widgets/base_page_scaffold.dart';

class DataSyncSection extends ConsumerWidget {
  const DataSyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final syncState = ref.watch(syncProvider);
    final isSyncing = syncState.isSyncing;
    final lastSyncMessage = syncState.statusMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Dados e Sincronização'),
        const SizedBox(height: 16),
        PlantisCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSyncing ? Icons.sync : Icons.cloud_done,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  isSyncing ? 'Sincronizando...' : 'Dados Sincronizados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isSyncing
                      ? lastSyncMessage
                      : 'Todos os dados estão atualizados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing:
                    isSyncing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : IconButton(
                          onPressed: () {
                            ref.read(syncProvider.notifier).triggerManualSync();
                          },
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Sincronizar agora',
                        ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: PlantisColors.primary,
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_view,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar CSV'),
                subtitle: const Text('Baixar dados em planilha para análise'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDialog(context, 'CSV'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  void _showExportDialog(BuildContext context, String format) {
    // Navigate to the dedicated data export page
    context.push(AppRouter.dataExport);
  }
}
