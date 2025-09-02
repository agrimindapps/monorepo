import 'package:flutter/material.dart';

/// Widget responsible for vaccine scheduling functionality following SRP
/// 
/// Single responsibility: Handle vaccine date scheduling and series configuration
class VaccineSchedulingForm extends StatefulWidget {
  final DateTime scheduledDate;
  final DateTime? nextDueDate;
  final bool isSeriesVaccine;
  final int seriesCount;
  final int seriesIntervalDays;
  final ValueChanged<DateTime> onScheduledDateChanged;
  final ValueChanged<DateTime?> onNextDueDateChanged;
  final ValueChanged<bool> onIsSeriesChanged;
  final ValueChanged<int> onSeriesCountChanged;
  final ValueChanged<int> onSeriesIntervalChanged;

  const VaccineSchedulingForm({
    super.key,
    required this.scheduledDate,
    this.nextDueDate,
    required this.isSeriesVaccine,
    required this.seriesCount,
    required this.seriesIntervalDays,
    required this.onScheduledDateChanged,
    required this.onNextDueDateChanged,
    required this.onIsSeriesChanged,
    required this.onSeriesCountChanged,
    required this.onSeriesIntervalChanged,
  });

  @override
  State<VaccineSchedulingForm> createState() => _VaccineSchedulingFormState();
}

class _VaccineSchedulingFormState extends State<VaccineSchedulingForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateScheduling(theme),
          const SizedBox(height: 24),
          _buildSeriesConfiguration(theme),
          const SizedBox(height: 16),
          _buildNextDueDate(theme),
        ],
      ),
    );
  }

  Widget _buildDateScheduling(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data de Aplicação',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectScheduledDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Agendada',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.scheduledDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesConfiguration(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              title: const Text('Vacina em Série'),
              subtitle: const Text('Aplicação em múltiplas doses'),
              value: widget.isSeriesVaccine,
              onChanged: widget.onIsSeriesChanged,
              activeColor: theme.colorScheme.primary,
            ),
            if (widget.isSeriesVaccine) ...[
              const Divider(),
              _buildSeriesControls(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesControls(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Número de Doses',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.seriesCount > 1
                            ? () => widget.onSeriesCountChanged(widget.seriesCount - 1)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${widget.seriesCount}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: widget.seriesCount < 10
                            ? () => widget.onSeriesCountChanged(widget.seriesCount + 1)
                            : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intervalo (dias)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: widget.seriesIntervalDays,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [7, 14, 21, 30, 45, 60].map((days) {
                      return DropdownMenuItem(
                        value: days,
                        child: Text('$days dias'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onSeriesIntervalChanged(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextDueDate(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Próxima Dose',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.nextDueDate != null)
                  TextButton(
                    onPressed: () => widget.onNextDueDateChanged(null),
                    child: const Text('Remover'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.nextDueDate != null)
              InkWell(
                onTap: _selectNextDueDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_repeat,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(widget.nextDueDate!),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _selectNextDueDate,
                icon: const Icon(Icons.add),
                label: const Text('Agendar Próxima Dose'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectScheduledDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      widget.onScheduledDateChanged(picked);
    }
  }

  Future<void> _selectNextDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.nextDueDate ?? widget.scheduledDate.add(const Duration(days: 30)),
      firstDate: widget.scheduledDate,
      lastDate: DateTime.now().add(const Duration(days: 1095)), // 3 years
    );

    if (picked != null) {
      widget.onNextDueDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}