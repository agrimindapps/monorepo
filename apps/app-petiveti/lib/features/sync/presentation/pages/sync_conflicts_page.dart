import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sync_conflict.dart';
import '../../domain/usecases/resolve_sync_conflict_usecase.dart';
import '../../providers/sync_providers.dart';
import '../widgets/sync_conflict_dialog.dart';

/// Page for viewing and resolving sync conflicts
class SyncConflictsPage extends ConsumerWidget {
  const SyncConflictsPage({super.key});

  static const String routeName = '/sync-conflicts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conflictsAsync = ref.watch(syncConflictsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflitos de Sincronização'),
      ),
      body: conflictsAsync.when(
        data: (conflicts) {
          if (conflicts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum conflito pendente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(_getEntityDisplayName(conflict.entityType)),
                  subtitle: Text(
                    'Detectado em ${_formatDate(conflict.detectedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showConflictDialog(context, ref, conflict);
                  },
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
                  'Erro ao carregar conflitos',
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

  void _showConflictDialog(
    BuildContext context,
    WidgetRef ref,
    SyncConflict conflict,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => SyncConflictDialog(
        conflict: conflict,
        onResolve: (resolution) async {
          final useCase = await ref.read(
            resolveSyncConflictUseCaseProvider.future,
          );
          await useCase(ResolveSyncConflictParams(
            conflictId: conflict.id,
            resolution: resolution,
          ));

          // Refresh conflicts list
          ref.invalidate(syncConflictsProvider);
        },
      ),
    );
  }

  String _getEntityDisplayName(String entityType) {
    const Map<String, String> displayNames = {
      'animals': 'Animal',
      'medications': 'Medicamento',
      'vaccines': 'Vacina',
      'appointments': 'Consulta',
      'weight': 'Peso',
      'expenses': 'Despesa',
      'reminders': 'Lembrete',
    };

    return displayNames[entityType] ?? entityType;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
