import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync_providers.dart';
import '../widgets/manual_sync_button.dart';
import '../widgets/sync_entity_card.dart';
import '../widgets/sync_status_indicator.dart';
import 'sync_conflicts_page.dart';
import 'sync_history_page.dart';
import 'sync_settings_page.dart';

/// Main sync status page showing global sync status
class SyncStatusPage extends ConsumerWidget {
  const SyncStatusPage({super.key});

  static const String routeName = '/sync-status';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () {
              Navigator.of(context).pushNamed(SyncHistoryPage.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).pushNamed(SyncSettingsPage.routeName);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncStatusProvider.notifier).loadSyncStatus();
        },
        child: syncState.isLoading && syncState.statusByEntity.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : syncState.error != null
                ? _buildErrorView(context, ref, syncState.error!)
                : _buildSyncStatusList(context, ref, syncState),
      ),
      floatingActionButton: ManualSyncButton(
        onSyncAll: () async {
          await ref.read(syncStatusProvider.notifier).forceSync();
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(syncStatusProvider.notifier).loadSyncStatus();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusList(
    BuildContext context,
    WidgetRef ref,
    SyncStatusState state,
  ) {
    if (state.statusByEntity.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhuma sincronização pendente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final entities = state.statusByEntity.entries.toList();

    // Calculate global stats
    final totalPending = entities.fold<int>(
      0,
      (sum, entry) => sum + entry.value.pendingCount,
    );
    final totalErrors = entities.fold<int>(
      0,
      (sum, entry) => sum + entry.value.errorCount,
    );

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Global status indicator
        SyncStatusIndicator(
          pendingCount: totalPending,
          errorCount: totalErrors,
          isSyncing: state.isLoading,
        ),
        const SizedBox(height: 16),

        // Conflicts banner
        if (totalErrors > 0) ...[
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Conflitos detectados'),
              subtitle: Text('$totalErrors itens precisam de atenção'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pushNamed(SyncConflictsPage.routeName);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Section header
        Text(
          'Por tipo de dados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Entity cards
        ...entities.map((entry) {
          return SyncEntityCard(
            entityType: entry.key,
            status: entry.value,
            onSync: () async {
              await ref
                  .read(syncStatusProvider.notifier)
                  .forceSync(entityType: entry.key);
            },
          );
        }),
      ],
    );
  }
}
