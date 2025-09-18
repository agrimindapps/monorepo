import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';

import '../providers/realtime_sync_provider.dart';

/// Widget que exibe o status atual da sincronização
/// Pode ser usado na AppBar ou em qualquer lugar da UI
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({
    super.key,
    this.showText = true,
    this.compact = false,
  });

  final bool showText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Consumer<RealtimeSyncProvider>(
      builder: (context, syncProvider, child) {
        return GestureDetector(
          onTap: () => _showSyncDetailsDialog(context, syncProvider),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(syncProvider.statusColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              border: Border.all(
                color: _getStatusColor(syncProvider.statusColor).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusIcon(syncProvider),
                if (showText && !compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    _getShortStatusText(syncProvider),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(syncProvider.statusColor),
                    ),
                  ),
                ],
                if (syncProvider.pendingChanges > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${syncProvider.pendingChanges}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(RealtimeSyncProvider syncProvider) {
    final color = _getStatusColor(syncProvider.statusColor);

    if (syncProvider.currentSyncStatus == SyncStatus.syncing) {
      return SizedBox(
        width: compact ? 12 : 16,
        height: compact ? 12 : 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    IconData iconData;
    switch (syncProvider.statusColor) {
      case SyncIndicatorColor.success:
        iconData = Icons.cloud_done;
        break;
      case SyncIndicatorColor.info:
        iconData = Icons.cloud_sync;
        break;
      case SyncIndicatorColor.syncing:
        iconData = Icons.sync;
        break;
      case SyncIndicatorColor.warning:
        iconData = Icons.cloud_off;
        break;
      case SyncIndicatorColor.error:
        iconData = Icons.cloud_off;
        break;
    }

    return Icon(
      iconData,
      size: compact ? 12 : 16,
      color: color,
    );
  }

  Color _getStatusColor(SyncIndicatorColor indicatorColor) {
    switch (indicatorColor) {
      case SyncIndicatorColor.success:
        return Colors.green;
      case SyncIndicatorColor.info:
        return Colors.blue;
      case SyncIndicatorColor.syncing:
        return Colors.orange;
      case SyncIndicatorColor.warning:
        return Colors.amber;
      case SyncIndicatorColor.error:
        return Colors.red;
    }
  }

  String _getShortStatusText(RealtimeSyncProvider syncProvider) {
    if (!syncProvider.isOnline) {
      return 'Offline';
    }

    if (syncProvider.currentSyncStatus == SyncStatus.syncing) {
      return 'Sync...';
    }

    return syncProvider.isRealtimeActive ? 'Real-time' : 'Intervalos';
  }

  void _showSyncDetailsDialog(BuildContext context, RealtimeSyncProvider syncProvider) {
    showDialog<void>(
      context: context,
      builder: (context) => SyncDetailsDialog(syncProvider: syncProvider),
    );
  }
}

/// Dialog com detalhes completos do status de sincronização
class SyncDetailsDialog extends StatelessWidget {
  const SyncDetailsDialog({
    super.key,
    required this.syncProvider,
  });

  final RealtimeSyncProvider syncProvider;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sync, size: 24),
          SizedBox(width: 8),
          Text('Status de Sincronização'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusSection(),
            const Divider(),
            _buildControlsSection(context),
            const Divider(),
            _buildRecentEventsSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (syncProvider.isOnline)
          ElevatedButton(
            onPressed: () {
              syncProvider.forceSync();
              Navigator.of(context).pop();
            },
            child: const Text('Sincronizar Agora'),
          ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Atual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              syncProvider.isOnline ? Icons.wifi : Icons.wifi_off,
              color: syncProvider.isOnline ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(syncProvider.isOnline ? 'Online' : 'Offline'),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              syncProvider.isRealtimeActive ? Icons.speed : Icons.schedule,
              color: syncProvider.isRealtimeActive ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(syncProvider.isRealtimeActive
                ? 'Sincronização em tempo real'
                : 'Sincronização por intervalos'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          syncProvider.statusMessage,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (syncProvider.lastSyncTime != null) ...[
          const SizedBox(height: 4),
          Text(
            'Última sincronização: ${_formatDateTime(syncProvider.lastSyncTime!)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildControlsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Sincronização em tempo real'),
          subtitle: const Text('Receber mudanças instantaneamente'),
          value: syncProvider.isRealtimeActive,
          onChanged: syncProvider.isOnline ? (value) => syncProvider.toggleRealtimeSync() : null,
          secondary: const Icon(Icons.speed),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Notificações de sync'),
          subtitle: const Text('Mostrar notificações de sincronização'),
          value: syncProvider.showSyncNotifications,
          onChanged: (value) => syncProvider.setSyncNotifications(value),
          secondary: const Icon(Icons.notifications),
          dense: true,
        ),
        SwitchListTile(
          title: const Text('Sync em background'),
          subtitle: const Text('Continuar sincronizando em segundo plano'),
          value: syncProvider.enableBackgroundSync,
          onChanged: (value) => syncProvider.setBackgroundSync(value),
          secondary: const Icon(Icons.swap_horiz),
          dense: true,
        ),
      ],
    );
  }

  Widget _buildRecentEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Eventos Recentes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => syncProvider.clearRecentEvents(),
              child: const Text('Limpar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (syncProvider.recentEvents.isEmpty)
          const Text(
            'Nenhum evento recente',
            style: TextStyle(color: Colors.grey),
          )
        else
          ...syncProvider.recentEvents.take(5).map((event) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  event,
                  style: const TextStyle(fontSize: 12),
                ),
              )),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Widget compacto para mostrar apenas o indicador de status
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyncStatusWidget(
      showText: false,
      compact: true,
    );
  }
}

/// Widget para AppBar com status de sync
class AppBarSyncStatus extends StatelessWidget {
  const AppBarSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyncStatusWidget(
      showText: true,
      compact: false,
    );
  }
}