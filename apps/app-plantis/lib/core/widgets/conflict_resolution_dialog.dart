import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/plants/domain/entities/plant.dart';

part 'conflict_resolution_dialog.g.dart';

/// Dialog for resolving sync conflicts between local and remote versions
class ConflictResolutionDialog extends StatefulWidget {
  const ConflictResolutionDialog({
    super.key,
    required this.localVersion,
    required this.remoteVersion,
    required this.onResolve,
  });

  final Plant localVersion;
  final Plant remoteVersion;
  final Future<void> Function(Plant chosenVersion) onResolve;

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  Plant? _selectedVersion;
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          const Text('Conflito de Sincronização'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A planta "${widget.localVersion.name}" foi editada em outro dispositivo. Escolha qual versão manter:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildVersionComparison(),
            const SizedBox(height: 16),
            const Text(
              'Diferenças encontradas:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildDifferencesList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResolving ? null : () => Navigator.of(context).pop(),
          child: const Text('Decidir Depois'),
        ),
        ElevatedButton(
          onPressed:
              _selectedVersion != null && !_isResolving
                  ? _resolveConflict
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child:
              _isResolving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Confirmar Escolha'),
        ),
      ],
    );
  }

  Widget _buildVersionComparison() {
    return Column(
      children: [
        _buildVersionOption(
          'Sua versão (local)',
          widget.localVersion,
          _selectedVersion == widget.localVersion,
          () => setState(() => _selectedVersion = widget.localVersion),
        ),
        const SizedBox(height: 12),
        _buildVersionOption(
          'Versão remota',
          widget.remoteVersion,
          _selectedVersion == widget.remoteVersion,
          () => setState(() => _selectedVersion = widget.remoteVersion),
        ),
      ],
    );
  }

  Widget _buildVersionOption(
    String label,
    Plant version,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.shade50 : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade700,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue.shade700,
                    size: 16,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            _buildPlantSummary(version),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantSummary(Plant plant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nome: ${plant.name}'),
        if (plant.species != null) Text('Espécie: ${plant.species}'),
        if (plant.notes != null && plant.notes!.isNotEmpty)
          Text('Observações: ${plant.notes}'),
        Text(
          'Última edição: ${_formatDateTime(plant.updatedAt ?? plant.createdAt ?? DateTime.now())}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDifferencesList() {
    final differences = _calculateDifferences();

    if (differences.isEmpty) {
      return const Text(
        'Nenhuma diferença encontrada.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          differences.map((diff) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(diff, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  List<String> _calculateDifferences() {
    final differences = <String>[];

    if (widget.localVersion.name != widget.remoteVersion.name) {
      differences.add(
        'Nome: "${widget.localVersion.name}" vs "${widget.remoteVersion.name}"',
      );
    }

    if (widget.localVersion.species != widget.remoteVersion.species) {
      differences.add(
        'Espécie: "${widget.localVersion.species ?? 'N/A'}" vs "${widget.remoteVersion.species ?? 'N/A'}"',
      );
    }

    if (widget.localVersion.notes != widget.remoteVersion.notes) {
      differences.add('Observações diferentes');
    }

    if (widget.localVersion.wateringFrequency !=
        widget.remoteVersion.wateringFrequency) {
      differences.add(
        'Frequência de rega: ${widget.localVersion.wateringFrequency} vs ${widget.remoteVersion.wateringFrequency} dias',
      );
    }

    return differences;
  }

  Future<void> _resolveConflict() async {
    if (_selectedVersion == null) return;

    setState(() => _isResolving = true);

    try {
      await widget.onResolve(_selectedVersion!);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conflito resolvido com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao resolver conflito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia(s) atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora(s) atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto(s) atrás';
    } else {
      return 'Agora';
    }
  }
}

/// Provider for managing conflict resolution state
@riverpod
class ConflictResolution extends _$ConflictResolution {
  @override
  ConflictResolutionState build() {
    return const ConflictResolutionState();
  }

  void showConflict(Plant localVersion, Plant remoteVersion) {
    state = state.copyWith(
      hasPendingConflict: true,
      localVersion: localVersion,
      remoteVersion: remoteVersion,
    );
  }

  void resolveConflict() {
    state = const ConflictResolutionState();
  }

  void dismissConflict() {
    state = const ConflictResolutionState();
  }
}

class ConflictResolutionState {
  final bool hasPendingConflict;
  final Plant? localVersion;
  final Plant? remoteVersion;

  const ConflictResolutionState({
    this.hasPendingConflict = false,
    this.localVersion,
    this.remoteVersion,
  });

  ConflictResolutionState copyWith({
    bool? hasPendingConflict,
    Plant? localVersion,
    Plant? remoteVersion,
  }) {
    return ConflictResolutionState(
      hasPendingConflict: hasPendingConflict ?? this.hasPendingConflict,
      localVersion: localVersion ?? this.localVersion,
      remoteVersion: remoteVersion ?? this.remoteVersion,
    );
  }
}
