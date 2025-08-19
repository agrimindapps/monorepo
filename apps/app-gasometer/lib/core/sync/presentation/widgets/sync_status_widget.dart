import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sync_status_provider.dart';
import '../../services/sync_service.dart';

/// Widget que exibe o status atual da sincronização
class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    super.key,
    this.showDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncStatusProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status header
                  Row(
                    children: [
                      // Status icon
                      Text(
                        syncProvider.statusIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      
                      // Status text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusDisplayName(syncProvider.status),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (showDetails)
                              Text(
                                syncProvider.friendlyMessage,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      
                      // Loading indicator
                      if (syncProvider.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  
                  if (showDetails && syncProvider.hasQueueItems) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 4),
                    
                    // Queue statistics
                    _buildQueueStats(context, syncProvider),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQueueStats(BuildContext context, SyncStatusProvider provider) {
    final stats = provider.getItemsCountByStatus();
    final statsByType = provider.getStatsByModelType();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall stats
        Text(
          'Fila de Sincronização',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        
        Wrap(
          spacing: 8,
          children: [
            if (stats['pending']! > 0)
              _buildStatChip(
                '${stats['pending']} pendentes',
                Colors.orange.shade100,
                Colors.orange.shade800,
              ),
            if (stats['synced']! > 0)
              _buildStatChip(
                '${stats['synced']} sincronizados',
                Colors.green.shade100,
                Colors.green.shade800,
              ),
            if (stats['failed']! > 0)
              _buildStatChip(
                '${stats['failed']} falharam',
                Colors.red.shade100,
                Colors.red.shade800,
              ),
            if (stats['retrying']! > 0)
              _buildStatChip(
                '${stats['retrying']} tentando novamente',
                Colors.blue.shade100,
                Colors.blue.shade800,
              ),
          ],
        ),
        
        // Stats by model type
        if (statsByType.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Por Tipo:',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: statsByType.entries.map((entry) {
              return _buildStatChip(
                '${_getModelDisplayName(entry.key)}: ${entry.value}',
                Colors.grey.shade100,
                Colors.grey.shade700,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusDisplayName(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Aguardando';
      case SyncStatus.syncing:
        return 'Sincronizando';
      case SyncStatus.error:
        return 'Erro';
      case SyncStatus.success:
        return 'Sucesso';
      case SyncStatus.conflict:
        return 'Conflito';
      case SyncStatus.offline:
        return 'Offline';
    }
  }

  String _getModelDisplayName(String modelType) {
    switch (modelType) {
      case 'VehicleModel':
        return 'Veículos';
      case 'FuelSupplyModel':
        return 'Abastecimentos';
      case 'MaintenanceModel':
        return 'Manutenções';
      case 'ExpenseModel':
        return 'Despesas';
      case 'OdometerModel':
        return 'Odômetro';
      default:
        return modelType;
    }
  }
}

/// Widget compacto para mostrar apenas o status da sincronização
class SyncStatusIndicator extends StatelessWidget {
  final double size;

  const SyncStatusIndicator({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncStatusProvider>(
      builder: (context, syncProvider, child) {
        if (!syncProvider.isInitialized) {
          return SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getStatusColor(syncProvider),
          ),
          child: Center(
            child: syncProvider.isLoading
                ? SizedBox(
                    width: size * 0.6,
                    height: size * 0.6,
                    child: const CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _getStatusIcon(syncProvider),
                    size: size * 0.6,
                    color: Colors.white,
                  ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(SyncStatusProvider provider) {
    if (provider.isOffline) return Colors.grey;
    if (provider.hasError) return Colors.red;
    if (provider.isLoading) return Colors.blue;
    if (provider.hasQueueItems) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(SyncStatusProvider provider) {
    if (provider.isOffline) return Icons.wifi_off;
    if (provider.hasError) return Icons.error_outline;
    if (provider.hasQueueItems) return Icons.schedule;
    return Icons.check;
  }
}