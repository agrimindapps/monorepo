import 'package:flutter/material.dart';

/// Visual indicator of sync status
class SyncStatusIndicator extends StatelessWidget {
  final int pendingCount;
  final int errorCount;
  final bool isSyncing;

  const SyncStatusIndicator({
    super.key,
    required this.pendingCount,
    required this.errorCount,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    String title;
    String subtitle;

    if (isSyncing) {
      backgroundColor = Colors.blue.shade50;
      icon = Icons.sync;
      title = 'Sincronizando...';
      subtitle = 'Aguarde enquanto sincronizamos seus dados';
    } else if (errorCount > 0) {
      backgroundColor = Colors.red.shade50;
      icon = Icons.error;
      title = 'Conflitos detectados';
      subtitle = '$errorCount ${errorCount == 1 ? 'item precisa' : 'itens precisam'} de atenção';
    } else if (pendingCount > 0) {
      backgroundColor = Colors.orange.shade50;
      icon = Icons.cloud_upload;
      title = 'Sincronização pendente';
      subtitle = '$pendingCount ${pendingCount == 1 ? 'item aguardando' : 'itens aguardando'} sincronização';
    } else {
      backgroundColor = Colors.green.shade50;
      icon = Icons.cloud_done;
      title = 'Tudo sincronizado';
      subtitle = 'Seus dados estão seguros na nuvem';
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (isSyncing)
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              )
            else
              Icon(icon, size: 40, color: _getIconColor()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor() {
    if (errorCount > 0) return Colors.red;
    if (pendingCount > 0) return Colors.orange;
    return Colors.green;
  }
}
