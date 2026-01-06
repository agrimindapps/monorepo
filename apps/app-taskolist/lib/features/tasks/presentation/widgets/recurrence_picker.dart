import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/recurrence_entity.dart';

/// Widget para configurar recorrência de tarefas
class RecurrencePicker extends ConsumerStatefulWidget {
  final RecurrencePattern initialPattern;
  final ValueChanged<RecurrencePattern> onChanged;

  const RecurrencePicker({
    super.key,
    required this.initialPattern,
    required this.onChanged,
  });

  @override
  ConsumerState<RecurrencePicker> createState() => _RecurrencePickerState();
}

class _RecurrencePickerState extends ConsumerState<RecurrencePicker> {
  late RecurrencePattern _pattern;

  @override
  void initState() {
    super.initState();
    _pattern = widget.initialPattern;
  }

  void _updatePattern(RecurrencePattern newPattern) {
    setState(() {
      _pattern = newPattern;
    });
    widget.onChanged(newPattern);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de recorrência
        ListTile(
          leading: const Icon(Icons.repeat),
          title: const Text('Repetir'),
          subtitle: Text(_pattern.toString()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showRecurrenceTypeDialog(),
        ),
        const Divider(height: 1),

        // Configurações adicionais baseadas no tipo
        if (_pattern.type != RecurrenceType.none) ...[
          // Intervalo
          if (_pattern.type != RecurrenceType.weekly) ...[
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(_getIntervalLabel()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _pattern.interval > 1
                        ? () => _updatePattern(_pattern.copyWith(
                              interval: _pattern.interval - 1,
                            ))
                        : null,
                  ),
                  Text('${_pattern.interval}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _updatePattern(_pattern.copyWith(
                      interval: _pattern.interval + 1,
                    )),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Dias da semana (apenas para Weekly)
          if (_pattern.type == RecurrenceType.weekly) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Repetir em:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDayChip('Seg', 1),
                      _buildDayChip('Ter', 2),
                      _buildDayChip('Qua', 3),
                      _buildDayChip('Qui', 4),
                      _buildDayChip('Sex', 5),
                      _buildDayChip('Sáb', 6),
                      _buildDayChip('Dom', 7),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Dia do mês (apenas para Monthly)
          if (_pattern.type == RecurrenceType.monthly) ...[
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Dia do mês'),
              trailing: DropdownButton<int>(
                value: _pattern.dayOfMonth ?? DateTime.now().day,
                items: List.generate(
                  31,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) => _updatePattern(_pattern.copyWith(
                  dayOfMonth: value,
                )),
              ),
            ),
            const Divider(height: 1),
          ],

          // Data final (opcional)
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Termina em'),
            subtitle: Text(
              _pattern.endDate != null
                  ? '${_pattern.endDate!.day}/${_pattern.endDate!.month}/${_pattern.endDate!.year}'
                  : 'Nunca',
            ),
            trailing: _pattern.endDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _updatePattern(_pattern.copyWith(
                      endDate: null,
                    )),
                  )
                : null,
            onTap: () => _showEndDatePicker(),
          ),
        ],
      ],
    );
  }

  Widget _buildDayChip(String label, int weekday) {
    final selectedDays = _pattern.daysOfWeek ?? [];
    final isSelected = selectedDays.contains(weekday);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        final newDays = List<int>.from(selectedDays);
        if (selected) {
          newDays.add(weekday);
        } else {
          newDays.remove(weekday);
        }
        newDays.sort();
        _updatePattern(_pattern.copyWith(daysOfWeek: newDays));
      },
    );
  }

  String _getIntervalLabel() {
    switch (_pattern.type) {
      case RecurrenceType.daily:
        return _pattern.interval == 1 ? 'Todo dia' : 'A cada ${_pattern.interval} dias';
      case RecurrenceType.weekly:
        return _pattern.interval == 1 ? 'Toda semana' : 'A cada ${_pattern.interval} semanas';
      case RecurrenceType.monthly:
        return _pattern.interval == 1 ? 'Todo mês' : 'A cada ${_pattern.interval} meses';
      case RecurrenceType.yearly:
        return _pattern.interval == 1 ? 'Todo ano' : 'A cada ${_pattern.interval} anos';
      default:
        return 'Intervalo';
    }
  }

  void _showRecurrenceTypeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tipo de repetição'),
        children: RecurrenceType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _updatePattern(RecurrencePattern(
                type: type,
                interval: 1,
                daysOfWeek: type == RecurrenceType.weekly ? [DateTime.now().weekday] : null,
                dayOfMonth: type == RecurrenceType.monthly ? DateTime.now().day : null,
              ));
            },
            child: ListTile(
              leading: Icon(
                type == _pattern.type ? Icons.check : Icons.repeat,
              ),
              title: Text(type.label),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showEndDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pattern.endDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      _updatePattern(_pattern.copyWith(endDate: picked));
    }
  }
}
