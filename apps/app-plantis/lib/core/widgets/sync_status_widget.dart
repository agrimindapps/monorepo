import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../providers/repository_providers.dart';
import '../services/plantis_sync_service.dart';

/// Widget que exibe o status atual da sincronização
/// Pode ser usado na AppBar ou em qualquer lugar da UI
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({
    super.key,
    this.showText = true,
    this.compact = false,
  });

  final bool showText;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantisSyncService = ref.watch(plantisSyncServiceProvider);

    return StreamBuilder<SyncServiceStatus>(
      stream: plantisSyncService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncServiceStatus.idle;

        return GestureDetector(
          onTap: () => _showSyncDetailsDialog(context, plantisSyncService),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: _getBackgroundColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(compact ? 12 : 16),
              border: Border.all(
                color: _getBackgroundColor(status).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getStatusIcon(status),
                if (showText && !compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getBackgroundColor(status),
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

  Color _getBackgroundColor(SyncServiceStatus status) {
    switch (status) {
      case SyncServiceStatus.syncing:
        return Colors.orange;
      case SyncServiceStatus.completed:
        return Colors.green;
      case SyncServiceStatus.failed:
        return Colors.red;
      case SyncServiceStatus.idle:
      case SyncServiceStatus.uninitialized:
      case SyncServiceStatus.paused:
      case SyncServiceStatus.disposing:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(SyncServiceStatus status) {
    switch (status) {
      case SyncServiceStatus.syncing:
        return SizedBox(
          width: compact ? 12 : 16,
          height: compact ? 12 : 16,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      case SyncServiceStatus.completed:
        return Icon(
          Icons.cloud_done,
          size: compact ? 12 : 16,
          color: Colors.green,
        );
      case SyncServiceStatus.failed:
        return Icon(
          Icons.sync_problem,
          size: compact ? 12 : 16,
          color: Colors.red,
        );
      case SyncServiceStatus.idle:
      case SyncServiceStatus.uninitialized:
      case SyncServiceStatus.paused:
      case SyncServiceStatus.disposing:
        return Icon(
          Icons.cloud_off,
          size: compact ? 12 : 16,
          color: Colors.grey,
        );
    }
  }

  String _getStatusText(SyncServiceStatus status) {
    switch (status) {
      case SyncServiceStatus.syncing:
        return 'Sincronizando';
      case SyncServiceStatus.completed:
        return 'Sincronizado';
      case SyncServiceStatus.failed:
        return 'Erro de Sync';
      case SyncServiceStatus.idle:
        return 'Pronto';
      case SyncServiceStatus.uninitialized:
        return 'Não inicializado';
      case SyncServiceStatus.paused:
        return 'Pausado';
      case SyncServiceStatus.disposing:
        return 'Finalizando';
    }
  }

  void _showSyncDetailsDialog(
    BuildContext context,
    PlantisSyncService syncService,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => SyncDetailsDialog(syncService: syncService),
    );
  }
}

/// Dialog com detalhes de sincronização
class SyncDetailsDialog extends ConsumerWidget {
  const SyncDetailsDialog({super.key, required this.syncService});

  final PlantisSyncService syncService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<SyncServiceStatus>(
      stream: syncService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncServiceStatus.idle;

        return StreamBuilder<ServiceProgress>(
          stream: syncService.progressStream,
          builder: (context, progressSnapshot) {
            final progress = progressSnapshot.data;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.sync, size: 24),
                  SizedBox(width: 8),
                  Text('Status de Sincronização'),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusRow(status),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      progress.operation,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress.percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.current}/${progress.total} itens',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                  if (status == SyncServiceStatus.failed) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Alguns dados podem não ter sido sincronizados.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                if (status == SyncServiceStatus.failed)
                  TextButton(
                    onPressed: () async {
                      // Trigger manual sync
                      await syncService.sync();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusRow(SyncServiceStatus status) {
    final (icon, text, color) = switch (status) {
      SyncServiceStatus.syncing => (
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        'Sincronizando...',
        Colors.orange,
      ),
      SyncServiceStatus.completed => (
        const Icon(Icons.cloud_done, color: Colors.green, size: 20),
        'Sincronização completa',
        Colors.green,
      ),
      SyncServiceStatus.failed => (
        const Icon(Icons.sync_problem, color: Colors.red, size: 20),
        'Erro de sincronização',
        Colors.red,
      ),
      SyncServiceStatus.idle => (
        const Icon(Icons.cloud_off, color: Colors.grey, size: 20),
        'Pronto para sincronizar',
        Colors.grey,
      ),
      SyncServiceStatus.uninitialized => (
        const Icon(Icons.warning, color: Colors.orange, size: 20),
        'Serviço não inicializado',
        Colors.orange,
      ),
      SyncServiceStatus.paused => (
        const Icon(Icons.pause, color: Colors.blue, size: 20),
        'Sincronização pausada',
        Colors.blue,
      ),
      SyncServiceStatus.disposing => (
        const Icon(Icons.clear, color: Colors.grey, size: 20),
        'Finalizando...',
        Colors.grey,
      ),
    };

    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color)),
      ],
    );
  }
}

/// Widget compacto para mostrar apenas o indicador de status
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyncStatusWidget(showText: false, compact: true);
  }
}

/// Widget para AppBar com status de sync
class AppBarSyncStatus extends StatelessWidget {
  const AppBarSyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const SyncStatusWidget(showText: true, compact: false);
  }
}
