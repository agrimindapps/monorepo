import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/nebulalist_database.dart';
import '../../../core/providers/dependency_providers.dart';

/// Dialog que exibe items que falharam na sincronização
///
/// Permite:
/// - Ver lista de items que falharam (≥3 tentativas)
/// - Ver erro detalhado de cada item
/// - Retry individual ou em massa
/// - Remover da fila (desistir)
///
/// **Uso:**
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => const FailedSyncItemsDialog(),
/// )
/// ```
class FailedSyncItemsDialog extends ConsumerStatefulWidget {
  final int maxRetries;

  const FailedSyncItemsDialog({
    super.key,
    this.maxRetries = 3,
  });

  @override
  ConsumerState<FailedSyncItemsDialog> createState() =>
      _FailedSyncItemsDialogState();
}

class _FailedSyncItemsDialogState
    extends ConsumerState<FailedSyncItemsDialog> {
  List<NebulalistSyncQueueData> _failedItems = [];
  bool _isLoading = true;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _loadFailedItems();
  }

  Future<void> _loadFailedItems() async {
    setState(() => _isLoading = true);

    final syncQueueService = ref.read(syncQueueServiceProvider);
    final items = await syncQueueService.getFailedItems(
      maxRetries: widget.maxRetries,
    );

    if (mounted) {
      setState(() {
        _failedItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryAll() async {
    setState(() => _isRetrying = true);

    final syncQueueService = ref.read(syncQueueServiceProvider);

    // Reset attempts para permitir retry
    for (final item in _failedItems) {
      // Recria o item com attempts = 0
      await syncQueueService.enqueue(
        modelType: item.modelType,
        modelId: item.modelId,
        operation: item.operation,
        data: jsonDecode(item.data) as Map<String, dynamic>,
      );
      // Remove o item antigo
      await syncQueueService.markAsSynced(item.id);
    }

    if (mounted) {
      setState(() => _isRetrying = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tentando sincronizar novamente...'),
        ),
      );
    }
  }

  Future<void> _removeItem(NebulalistSyncQueueData item) async {
    final syncQueueService = ref.read(syncQueueServiceProvider);

    // Marca como synced para remover da fila
    await syncQueueService.markAsSynced(item.id);

    await _loadFailedItems();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removido da fila')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          const Text('Sincronização Falhada'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _failedItems.isEmpty
                ? const Text('Nenhum item com falha de sincronização.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _failedItems.length,
                    itemBuilder: (context, index) {
                      final item = _failedItems[index];
                      return _FailedItemTile(
                        item: item,
                        onRemove: () => _removeItem(item),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
        if (_failedItems.isNotEmpty && !_isRetrying)
          FilledButton.icon(
            onPressed: _retryAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        if (_isRetrying) const CircularProgressIndicator(),
      ],
    );
  }
}

/// Tile individual de item falhado
class _FailedItemTile extends StatelessWidget {
  final NebulalistSyncQueueData item;
  final VoidCallback onRemove;

  const _FailedItemTile({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          _getIconForOperation(item.operation),
          color: theme.colorScheme.error,
        ),
        title: Text('${item.modelType} - ${item.operation}'),
        subtitle: Text(
          'Falhou após ${item.attempts} tentativas',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remover da fila',
          onPressed: onRemove,
        ),
        children: [
          if (item.lastError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.lastError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForOperation(String operation) {
    switch (operation) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      default:
        return Icons.help_outline;
    }
  }
}
