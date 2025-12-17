import 'package:flutter/material.dart';

// Helper to suppress unawaited_futures warning  
void unawaited(Future<void> future) {}

/// Floating action button for manual sync operations
class ManualSyncButton extends StatelessWidget {
  final Future<void> Function() onSyncAll;

  const ManualSyncButton({
    super.key,
    required this.onSyncAll,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sincronizar Agora'),
            content: const Text(
              'Deseja sincronizar todos os dados agora? '
              'Isso pode levar alguns instantes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sincronizar'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          // Show loading indicator
          final loadingFuture = showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Sincronizando...'),
                    ],
                  ),
                ),
              ),
            ),
          );
          
          // Don't await - we want to show it while syncing happens
          unawaited(loadingFuture);

          try {
            await onSyncAll();

            if (context.mounted) {
              Navigator.of(context).pop(); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronização concluída com sucesso'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro na sincronização: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        }
      },
      icon: const Icon(Icons.sync),
      label: const Text('Sincronizar'),
    );
  }
}
