import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/sync_providers.dart';

/// Page showing sync operation history
class SyncHistoryPage extends ConsumerWidget {
  const SyncHistoryPage({super.key});

  static const String routeName = '/sync-history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(syncHistoryProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Sincronização'),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum histórico disponível',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final operation = history[index];
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

              return Card(
                child: ListTile(
                  leading: Icon(
                    operation.success ? Icons.check_circle : Icons.error,
                    color: operation.success ? Colors.green : Colors.red,
                  ),
                  title: Text(_getEntityDisplayName(operation.entityType)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getOperationTypeLabel(operation.operationType),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        dateFormat.format(operation.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (operation.error != null)
                        Text(
                          operation.error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: operation.itemsAffected > 0
                      ? Chip(
                          label: Text('${operation.itemsAffected}'),
                          backgroundColor: Colors.blue.shade100,
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar histórico',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEntityDisplayName(String entityType) {
    const Map<String, String> displayNames = {
      'animals': 'Animais',
      'medications': 'Medicamentos',
      'vaccines': 'Vacinas',
      'appointments': 'Consultas',
      'weight': 'Peso',
      'expenses': 'Despesas',
      'reminders': 'Lembretes',
      'all': 'Todos os dados',
    };

    return displayNames[entityType] ?? entityType;
  }

  String _getOperationTypeLabel(dynamic operationType) {
    final typeStr = operationType.toString().split('.').last;
    const Map<String, String> labels = {
      'create': 'Criação',
      'update': 'Atualização',
      'delete': 'Exclusão',
      'full': 'Sincronização completa',
    };

    return labels[typeStr] ?? typeStr;
  }
}
