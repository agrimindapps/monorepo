import 'package:flutter/material.dart';

import '../../../domain/entities/data_migration/data_conflict_result.dart';
import '../../../domain/entities/data_migration/data_resolution_choice.dart';

/// Dialog widget for displaying data conflicts and allowing user to choose resolution
/// 
/// This widget presents a comparison between anonymous and account data,
/// and allows the user to select how to resolve the conflict. It includes
/// confirmation dialogs for destructive actions.
class DataConflictDialog extends StatefulWidget {
  const DataConflictDialog({
    Key? key,
    required this.conflictResult,
    required this.onChoiceMade,
    this.title = 'Conflito de Dados Detectado',
    this.allowCancel = true,
    this.showDetails = true,
  }) : super(key: key);

  /// The conflict result to display
  final DataConflictResult conflictResult;
  
  /// Callback when user makes a choice
  final Function(DataResolutionChoice) onChoiceMade;
  
  /// Dialog title
  final String title;
  
  /// Whether to allow cancel option
  final bool allowCancel;
  
  /// Whether to show detailed data comparison
  final bool showDetails;

  @override
  State<DataConflictDialog> createState() => _DataConflictDialogState();
}

class _DataConflictDialogState extends State<DataConflictDialog> {
  DataResolutionChoice? _selectedChoice;
  bool _showConfirmation = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_showConfirmation) {
      return _buildConfirmationDialog();
    }
    
    return _buildMainDialog();
  }

  Widget _buildMainDialog() {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conflict description
            Text(
              widget.conflictResult.conflictDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Severity indicator
            _buildSeverityIndicator(),
            const SizedBox(height: 16),
            
            // Data comparison if details are enabled
            if (widget.showDetails) ...[
              _buildDataComparison(),
              const SizedBox(height: 16),
            ],
            
            // Recommendation if available
            if (widget.conflictResult.recommendedActionText != null) ...[
              _buildRecommendation(),
              const SizedBox(height: 16),
            ],
            
            // Choice selection
            _buildChoiceSelection(),
          ],
        ),
      ),
      actions: [
        if (widget.allowCancel)
          TextButton(
            onPressed: _isLoading ? null : () => _handleChoice(DataResolutionChoice.cancel),
            child: const Text('Cancelar'),
          ),
        ElevatedButton(
          onPressed: _isLoading || _selectedChoice == null 
              ? null 
              : () => _handleChoice(_selectedChoice!),
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildConfirmationDialog() {
    final choice = _selectedChoice!;
    
    return AlertDialog(
      title: const Text('Confirmar Ação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você está prestes a: ${choice.displayName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(choice.description),
          const SizedBox(height: 16),
          
          if (choice.warningMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      choice.warningMessage!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          const Text('Esta ação não pode ser desfeita. Deseja continuar?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            setState(() {
              _showConfirmation = false;
            });
          },
          child: const Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _executeChoice(),
          style: choice.isDestructive 
              ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
              : null,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(choice.isDestructive ? 'Confirmar e Remover' : 'Confirmar'),
        ),
      ],
    );
  }

  Widget _buildSeverityIndicator() {
    final severity = widget.conflictResult.severity;
    final color = _getSeverityColor(severity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            'Nível: ${severity.displayName}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDataComparison() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparação de Dados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildDataSummary(
                    'Dados Anônimos',
                    widget.conflictResult.anonymousData?.summary ?? 'Nenhum dado',
                    widget.conflictResult.anonymousData?.recordCount ?? 0,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDataSummary(
                    'Dados da Conta',
                    widget.conflictResult.accountData?.summary ?? 'Nenhum dado',
                    widget.conflictResult.accountData?.recordCount ?? 0,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary(String title, String summary, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count registros',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.conflictResult.recommendedActionText!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como deseja resolver este conflito?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        ...widget.conflictResult.availableChoices.map((choice) {
          return RadioListTile<DataResolutionChoice>(
            title: Text(choice.displayName),
            subtitle: Text(choice.description),
            value: choice,
            groupValue: _selectedChoice,
            onChanged: (value) {
              setState(() {
                _selectedChoice = value;
              });
            },
            activeColor: choice.isDestructive ? Colors.red : null,
          );
        }),
      ],
    );
  }

  Color _getSeverityColor(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.none:
        return Colors.green;
      case ConflictSeverity.low:
        return Colors.orange;
      case ConflictSeverity.high:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.none:
        return Icons.check_circle;
      case ConflictSeverity.low:
        return Icons.warning;
      case ConflictSeverity.high:
        return Icons.error;
    }
  }

  void _handleChoice(DataResolutionChoice choice) {
    setState(() {
      _selectedChoice = choice;
    });
    
    if (choice == DataResolutionChoice.cancel) {
      widget.onChoiceMade(choice);
      return;
    }
    
    if (choice.requiresConfirmation) {
      setState(() {
        _showConfirmation = true;
      });
    } else {
      _executeChoice();
    }
  }

  void _executeChoice() {
    setState(() {
      _isLoading = true;
    });
    
    widget.onChoiceMade(_selectedChoice!);
  }

  /// Static method to show the dialog
  static Future<DataResolutionChoice?> show({
    required BuildContext context,
    required DataConflictResult conflictResult,
    String title = 'Conflito de Dados Detectado',
    bool allowCancel = true,
    bool showDetails = true,
  }) async {
    DataResolutionChoice? result;
    
    await showDialog<DataResolutionChoice>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataConflictDialog(
        conflictResult: conflictResult,
        title: title,
        allowCancel: allowCancel,
        showDetails: showDetails,
        onChoiceMade: (choice) {
          result = choice;
          Navigator.of(context).pop(choice);
        },
      ),
    );
    
    return result;
  }
}