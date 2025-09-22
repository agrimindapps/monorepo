/// Financial Sync Status Indicator Widget
/// Shows sync status for financial data with appropriate visual cues
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../financial_sync_service.dart';

/// Financial sync status indicator widget
class FinancialSyncIndicator extends StatelessWidget {
  final String? entityId;
  final bool showLabel;
  final double size;
  final bool showDetails;

  const FinancialSyncIndicator({
    super.key,
    this.entityId,
    this.showLabel = true,
    this.size = 24.0,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FinancialSyncService>(
      builder: (context, syncService, child) {
        final status = entityId != null
            ? syncService.getSyncStatus(entityId!)
            : _getOverallStatus(syncService);

        return _buildIndicator(context, status, syncService);
      },
    );
  }

  Widget _buildIndicator(BuildContext context, FinancialSyncStatus status, FinancialSyncService syncService) {
    final theme = Theme.of(context);
    final config = _getStatusConfig(status, theme);

    if (showDetails) {
      return _buildDetailedIndicator(context, status, syncService, config);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          config.icon,
          color: config.color,
          size: size,
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            config.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedIndicator(
    BuildContext context,
    FinancialSyncStatus status,
    FinancialSyncService syncService,
    _StatusConfig config,
  ) {
    final theme = Theme.of(context);
    final stats = syncService.getQueueStats();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  config.icon,
                  color: config.color,
                  size: size,
                ),
                const SizedBox(width: 8),
                Text(
                  config.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (status == FinancialSyncStatus.syncing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(config.color),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              config.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (status != FinancialSyncStatus.synced) ...[
              const SizedBox(height: 8),
              _buildSyncStats(context, stats),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStats(BuildContext context, Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final pendingFinancial = stats['financial_queued'] as int? ?? 0;
    final highPriority = stats['high_priority_queued'] as int? ?? 0;
    final retrying = stats['retrying'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingFinancial > 0)
          _buildStatRow(
            context,
            Icons.account_balance_wallet,
            'Dados financeiros pendentes',
            pendingFinancial.toString(),
            Colors.orange,
          ),
        if (highPriority > 0)
          _buildStatRow(
            context,
            Icons.priority_high,
            'Alta prioridade',
            highPriority.toString(),
            Colors.red,
          ),
        if (retrying > 0)
          _buildStatRow(
            context,
            Icons.refresh,
            'Tentando novamente',
            retrying.toString(),
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  FinancialSyncStatus _getOverallStatus(FinancialSyncService syncService) {
    final stats = syncService.getQueueStats();
    final isSyncing = stats['is_syncing'] as bool? ?? false;
    final pending = stats['total_queued'] as int? ?? 0;
    final retrying = stats['retrying'] as int? ?? 0;

    if (isSyncing) return FinancialSyncStatus.syncing;
    if (retrying > 0) return FinancialSyncStatus.retrying;
    if (pending > 0) return FinancialSyncStatus.pending;
    return FinancialSyncStatus.synced;
  }

  _StatusConfig _getStatusConfig(FinancialSyncStatus status, ThemeData theme) {
    switch (status) {
      case FinancialSyncStatus.synced:
        return _StatusConfig(
          icon: Icons.check_circle,
          color: Colors.green,
          label: 'Sincronizado',
          description: 'Todos os dados financeiros estão sincronizados',
        );

      case FinancialSyncStatus.pending:
        return _StatusConfig(
          icon: Icons.schedule,
          color: Colors.orange,
          label: 'Pendente',
          description: 'Dados financeiros aguardando sincronização',
        );

      case FinancialSyncStatus.syncing:
        return _StatusConfig(
          icon: Icons.sync,
          color: Colors.blue,
          label: 'Sincronizando',
          description: 'Sincronizando dados financeiros...',
        );

      case FinancialSyncStatus.retrying:
        return _StatusConfig(
          icon: Icons.refresh,
          color: Colors.amber,
          label: 'Tentando novamente',
          description: 'Tentando sincronizar novamente após falha',
        );

      case FinancialSyncStatus.failed:
        return _StatusConfig(
          icon: Icons.error,
          color: Colors.red,
          label: 'Falhou',
          description: 'Falha na sincronização dos dados financeiros',
        );

      case FinancialSyncStatus.validationFailed:
        return _StatusConfig(
          icon: Icons.warning,
          color: Colors.deepOrange,
          label: 'Validação falhou',
          description: 'Dados financeiros contêm erros que impedem a sincronização',
        );
    }
  }
}

/// Status configuration class
class _StatusConfig {
  final IconData icon;
  final Color color;
  final String label;
  final String description;

  const _StatusConfig({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
  });
}