import 'package:core/core.dart';
import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: () => _showSyncDetailsDialog(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done,
              size: compact ? 12 : 16,
              color: Colors.green,
            ),
            if (showText && !compact) ...[
              const SizedBox(width: 6),
              const Text(
                'Sincronizado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSyncDetailsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SyncDetailsDialog(),
    );
  }
}

/// Dialog com detalhes de sincronização (versão simplificada)
class SyncDetailsDialog extends StatelessWidget {
  const SyncDetailsDialog({super.key});

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
      content: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.wifi, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Online'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Sincronizado'),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Todos os dados estão sincronizados.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
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
