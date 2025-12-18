import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/recurrence_entity.dart';

/// Dialog for configuring task recurrence
class RecurrenceConfigDialog extends ConsumerStatefulWidget {
  final RecurrencePattern? initialPattern;

  const RecurrenceConfigDialog({super.key, this.initialPattern});

  @override
  ConsumerState<RecurrenceConfigDialog> createState() =>
      _RecurrenceConfigDialogState();
}

class _RecurrenceConfigDialogState
    extends ConsumerState<RecurrenceConfigDialog> {
  late RecurrenceType _type;
  late int _interval;
  late List<int> _daysOfWeek;
  late int? _dayOfMonth;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final pattern = widget.initialPattern ?? const RecurrencePattern();
    _type = pattern.type;
    _interval = pattern.interval;
    _daysOfWeek = pattern.daysOfWeek ?? [];
    _dayOfMonth = pattern.dayOfMonth;
    _endDate = pattern.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar recorrência'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recurrence Type
            DropdownButtonFormField<RecurrenceType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo de recorrência',
                border: OutlineInputBorder(),
              ),
              items: RecurrenceType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),

            if (_type != RecurrenceType.none) ...[
              const SizedBox(height: 16),

              // Interval
              TextFormField(
                initialValue: _interval.toString(),
                decoration: InputDecoration(
                  labelText: _getIntervalLabel(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _interval = parsed;
                    });
                  }
                },
              ),

              // Weekly: Days of week
              if (_type == RecurrenceType.weekly) ...[
                const SizedBox(height: 16),
                const Text(
                  'Repetir nos dias:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildDayChip(1, 'Seg'),
                    _buildDayChip(2, 'Ter'),
                    _buildDayChip(3, 'Qua'),
                    _buildDayChip(4, 'Qui'),
                    _buildDayChip(5, 'Sex'),
                    _buildDayChip(6, 'Sáb'),
                    _buildDayChip(7, 'Dom'),
                  ],
                ),
              ],

              // Monthly: Day of month
              if (_type == RecurrenceType.monthly) ...[
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _dayOfMonth?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Dia do mês (1-31)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed >= 1 && parsed <= 31) {
                      setState(() {
                        _dayOfMonth = parsed;
                      });
                    }
                  },
                ),
              ],

              const SizedBox(height: 16),

              // End date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de término'),
                subtitle: Text(
                  _endDate != null
                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                      : 'Sem data de término',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _endDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickEndDate,
                    ),
                  ],
                ),
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
        FilledButton(onPressed: _saveRecurrence, child: const Text('Salvar')),
      ],
    );
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _daysOfWeek.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _daysOfWeek.add(day);
            _daysOfWeek.sort();
          } else {
            _daysOfWeek.remove(day);
          }
        });
      },
    );
  }

  String _getIntervalLabel() {
    switch (_type) {
      case RecurrenceType.daily:
        return 'Repetir a cada X dias';
      case RecurrenceType.weekly:
        return 'Repetir a cada X semanas';
      case RecurrenceType.monthly:
        return 'Repetir a cada X meses';
      case RecurrenceType.yearly:
        return 'Repetir a cada X anos';
      default:
        return 'Intervalo';
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveRecurrence() {
    final pattern = RecurrencePattern(
      type: _type,
      interval: _interval,
      daysOfWeek: _type == RecurrenceType.weekly && _daysOfWeek.isNotEmpty
          ? _daysOfWeek
          : null,
      dayOfMonth: _type == RecurrenceType.monthly ? _dayOfMonth : null,
      endDate: _endDate,
    );

    Navigator.pop(context, pattern);
  }
}
