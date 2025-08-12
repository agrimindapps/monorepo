/// Widget para resolução manual de conflitos de sincronização
library;

// Flutter imports:
import 'package:flutter/material.dart';

import '../models/conflict_resolution.dart';
// Project imports:
import '../models/task_model.dart';

/// Dialog para permitir que o usuário resolva conflitos manualmente
class ConflictResolutionDialog extends StatefulWidget {
  /// Conflito a ser resolvido
  final TaskConflict conflict;

  /// Callback chamado quando o usuário escolhe uma resolução
  final Function(ConflictResolutionStrategy strategy, Task? customTask)
      onResolved;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    required this.onResolved,
  });

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  ConflictResolutionStrategy? _selectedStrategy;
  bool _showDetailedComparison = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildConflictDescription(),
            const SizedBox(height: 24),
            _buildVersionComparison(),
            const SizedBox(height: 24),
            _buildResolutionOptions(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Conflito Detectado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Task: "${widget.conflict.localVersion.title}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildConflictDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição do Conflito:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(widget.conflict.description),
          const SizedBox(height: 8),
          Text(
            'Campos em conflito: ${widget.conflict.conflictingFields.join(", ")}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Comparação de Versões',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _showDetailedComparison = !_showDetailedComparison;
                });
              },
              child: Text(_showDetailedComparison
                  ? 'Ocultar Detalhes'
                  : 'Ver Detalhes'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildVersionCard(
                    'Sua Versão', widget.conflict.localVersion, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildVersionCard('Versão do Servidor',
                    widget.conflict.remoteVersion, Colors.green)),
          ],
        ),
        if (_showDetailedComparison) ...[
          const SizedBox(height: 16),
          _buildDetailedComparison(),
        ],
      ],
    );
  }

  Widget _buildVersionCard(String title, Task task, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 8),
          Text('Versão: ${task.version}'),
          Text(
              'Modificado: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(task.updatedAt))}'),
          if (task.isCompleted != widget.conflict.localVersion.isCompleted ||
              task.isStarred != widget.conflict.localVersion.isStarred) ...[
            const SizedBox(height: 8),
            if (task.isCompleted)
              const Text('✓ Completada', style: TextStyle(color: Colors.green)),
            if (task.isStarred)
              const Text('⭐ Favorita', style: TextStyle(color: Colors.amber)),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparação Detalhada',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...widget.conflict.conflictingFields
              .map((field) => _buildFieldComparison(field)),
        ],
      ),
    );
  }

  Widget _buildFieldComparison(String field) {
    final local = widget.conflict.localVersion;
    final remote = widget.conflict.remoteVersion;

    final String localValue = _getFieldValue(local, field);
    final String remoteValue = _getFieldValue(remote, field);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$field:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    localValue,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                const Text(' → '),
                Expanded(
                  child: Text(
                    remoteValue,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como deseja resolver este conflito?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildStrategyOption(
          ConflictResolutionStrategy.lastWriteWins,
          'Manter versão mais recente',
          'Automaticamente escolhe a versão que foi modificada por último',
          Icons.schedule,
        ),
        _buildStrategyOption(
          ConflictResolutionStrategy.firstWriteWins,
          'Manter versão mais antiga',
          'Mantém a primeira versão e descarta as modificações mais recentes',
          Icons.history,
        ),
        _buildStrategyOption(
          ConflictResolutionStrategy.autoMerge,
          'Tentar combinar automaticamente',
          'Combina as modificações de ambas as versões quando possível',
          Icons.merge_type,
        ),
      ],
    );
  }

  Widget _buildStrategyOption(
    ConflictResolutionStrategy strategy,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedStrategy == strategy;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStrategy = strategy;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          children: [
            Radio<ConflictResolutionStrategy>(
              value: strategy,
              groupValue: _selectedStrategy,
              onChanged: (value) {
                setState(() {
                  _selectedStrategy = value;
                });
              },
            ),
            Icon(icon,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedStrategy != null
                ? () {
                    widget.onResolved(_selectedStrategy!, null);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Resolver'),
          ),
        ),
      ],
    );
  }

  String _getFieldValue(Task task, String field) {
    switch (field) {
      case 'title':
        return task.title;
      case 'description':
        return task.description ?? '(vazio)';
      case 'isCompleted':
        return task.isCompleted ? 'Sim' : 'Não';
      case 'isStarred':
        return task.isStarred ? 'Sim' : 'Não';
      case 'priority':
        return task.priority.name;
      case 'position':
        return task.position.toString();
      case 'dueDate':
        return task.dueDate?.toString() ?? '(nenhuma)';
      case 'reminderDate':
        return task.reminderDate?.toString() ?? '(nenhum)';
      default:
        return '(não disponível)';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
