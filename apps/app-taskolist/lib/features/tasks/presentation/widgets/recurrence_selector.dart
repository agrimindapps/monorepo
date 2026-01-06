import 'package:flutter/material.dart';

/// Widget para seleção de recorrência de tarefa
class RecurrenceSelector extends StatelessWidget {
  final String? currentRule;
  final void Function(String?) onChanged;

  const RecurrenceSelector({
    super.key,
    this.currentRule,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.repeat),
          title: const Text('Repetir'),
          subtitle: Text(_getRuleDescription(currentRule)),
          onTap: () => _showRecurrenceDialog(context),
        ),
      ],
    );
  }

  void _showRecurrenceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => _RecurrenceDialog(
        currentRule: currentRule,
        onSelected: onChanged,
      ),
    );
  }

  String _getRuleDescription(String? rule) {
    if (rule == null) return 'Não repetir';
    
    final parts = rule.split(':');
    if (parts.length != 2) return 'Não repetir';
    
    final type = parts[0];
    final interval = int.tryParse(parts[1]) ?? 1;
    
    switch (type) {
      case 'daily':
        return interval == 1 ? 'Diariamente' : 'A cada $interval dias';
      case 'weekly':
        return interval == 1 ? 'Semanalmente' : 'A cada $interval semanas';
      case 'monthly':
        return interval == 1 ? 'Mensalmente' : 'A cada $interval meses';
      case 'yearly':
        return interval == 1 ? 'Anualmente' : 'A cada $interval anos';
      default:
        return 'Não repetir';
    }
  }
}

class _RecurrenceDialog extends StatefulWidget {
  final String? currentRule;
  final void Function(String?) onSelected;

  const _RecurrenceDialog({
    this.currentRule,
    required this.onSelected,
  });

  @override
  State<_RecurrenceDialog> createState() => _RecurrenceDialogState();
}

class _RecurrenceDialogState extends State<_RecurrenceDialog> {
  String? selectedType;
  int interval = 1;

  @override
  void initState() {
    super.initState();
    if (widget.currentRule != null) {
      final parts = widget.currentRule!.split(':');
      if (parts.length == 2) {
        selectedType = parts[0];
        interval = int.tryParse(parts[1]) ?? 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Repetir tarefa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opção: Não repetir
            RadioListTile<String?>(
              title: const Text('Não repetir'),
              value: null,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),
            
            // Opção: Diariamente
            RadioListTile<String>(
              title: const Text('Diariamente'),
              value: 'daily',
              groupValue: selectedType,
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),
            
            // Opção: Semanalmente
            RadioListTile<String>(
              title: const Text('Semanalmente'),
              value: 'weekly',
              groupValue: selectedType,
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),
            
            // Opção: Mensalmente
            RadioListTile<String>(
              title: const Text('Mensalmente'),
              value: 'monthly',
              groupValue: selectedType,
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),
            
            // Opção: Anualmente
            RadioListTile<String>(
              title: const Text('Anualmente'),
              value: 'yearly',
              groupValue: selectedType,
              onChanged: (value) {
                setState(() => selectedType = value);
              },
            ),
            
            // Intervalo personalizado
            if (selectedType != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('A cada'),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: interval.toString(),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setState(() => interval = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(_getIntervalLabel(selectedType!)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final rule = selectedType != null 
                ? '$selectedType:$interval' 
                : null;
            widget.onSelected(rule);
            Navigator.pop(context);
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  String _getIntervalLabel(String type) {
    switch (type) {
      case 'daily':
        return interval == 1 ? 'dia' : 'dias';
      case 'weekly':
        return interval == 1 ? 'semana' : 'semanas';
      case 'monthly':
        return interval == 1 ? 'mês' : 'meses';
      case 'yearly':
        return interval == 1 ? 'ano' : 'anos';
      default:
        return '';
    }
  }
}
