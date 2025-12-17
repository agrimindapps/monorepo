import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sync_status.dart';

/// Card displaying sync status for a specific entity type
class SyncEntityCard extends StatelessWidget {
  final String entityType;
  final SyncStatus status;
  final VoidCallback onSync;

  const SyncEntityCard({
    super.key,
    required this.entityType,
    required this.status,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _getEntityDisplayName(entityType);
    final icon = _getEntityIcon(entityType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: status.isSyncing ? null : onSync,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (status.isSyncing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(
                    context,
                    'Sincronizados',
                    status.syncedCount,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  if (status.pendingCount > 0)
                    _buildStat(
                      context,
                      'Pendentes',
                      status.pendingCount,
                      Colors.orange,
                    ),
                  if (status.errorCount > 0) ...[
                    const SizedBox(width: 16),
                    _buildStat(
                      context,
                      'Erros',
                      status.errorCount,
                      Colors.red,
                    ),
                  ],
                ],
              ),
              if (status.lastSyncTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Última sincronização: ${_formatDateTime(status.lastSyncTime!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
              if (status.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Erro: ${status.error}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    if (status.hasErrors) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: 16, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              'Conflito',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (status.hasPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload, size: 16, color: Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(
              'Pendente',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Text(
              'OK',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    int value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _getEntityDisplayName(String entityType) {
    const Map<String, String> displayNames = {
      'animals': 'Animais',
      'medications': 'Medicamentos',
      'vaccines': 'Vacinas',
      'appointments': 'Consultas',
      'weight': 'Registros de Peso',
      'expenses': 'Despesas',
      'reminders': 'Lembretes',
    };

    return displayNames[entityType] ?? entityType;
  }

  IconData _getEntityIcon(String entityType) {
    const Map<String, IconData> icons = {
      'animals': Icons.pets,
      'medications': Icons.medication,
      'vaccines': Icons.vaccines,
      'appointments': Icons.event,
      'weight': Icons.monitor_weight,
      'expenses': Icons.attach_money,
      'reminders': Icons.notifications,
    };

    return icons[entityType] ?? Icons.folder;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Há ${difference.inHours}h';
    } else {
      final format = DateFormat('dd/MM/yyyy HH:mm');
      return format.format(dateTime);
    }
  }
}
