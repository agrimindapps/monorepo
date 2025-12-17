import 'package:flutter/material.dart';

import '../../domain/entities/sync_conflict.dart';

/// Dialog for resolving sync conflicts
class SyncConflictDialog extends StatelessWidget {
  final SyncConflict conflict;
  final void Function(ConflictResolution) onResolve;

  const SyncConflictDialog({
    super.key,
    required this.conflict,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Resolver Conflito'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Um conflito foi detectado entre os dados locais e remotos:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildDataSection(
              context,
              'Dados Locais (Este dispositivo)',
              conflict.localData,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildDataSection(
              context,
              'Dados Remotos (Nuvem)',
              conflict.remoteData,
              Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Como deseja resolver este conflito?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            onResolve(ConflictResolution.useLocal);
            Navigator.of(context).pop();
          },
          child: const Text('Usar Local'),
        ),
        TextButton(
          onPressed: () {
            onResolve(ConflictResolution.useRemote);
            Navigator.of(context).pop();
          },
          child: const Text('Usar Remoto'),
        ),
        ElevatedButton(
          onPressed: () {
            onResolve(ConflictResolution.merge);
            Navigator.of(context).pop();
          },
          child: const Text('Mesclar'),
        ),
      ],
    );
  }

  Widget _buildDataSection(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      '${entry.key}:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value?.toString() ?? 'null',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
