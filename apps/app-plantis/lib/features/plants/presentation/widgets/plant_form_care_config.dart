import 'package:core/core.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/state/plant_form_state_notifier.dart';
import '../../../../core/theme/plantis_colors.dart';

class PlantFormCareConfig extends ConsumerStatefulWidget {
  const PlantFormCareConfig({super.key});

  @override
  ConsumerState<PlantFormCareConfig> createState() =>
      _PlantFormCareConfigState();
}

class _PlantFormCareConfigState extends ConsumerState<PlantFormCareConfig> {
  /// Converte dias em texto legível formatado
  String _formatIntervalText(int days) {
    if (days == 1) return '1 dia';
    if (days < 7) return '$days dias';
    if (days == 7) return '1 semana';
    if (days == 14) return '2 semanas';
    if (days == 30) return '1 mês';
    if (days == 60) return '2 meses';
    if (days == 90) return '3 meses';
    if (days == 180) return '6 meses';
    if (days == 365) return '1 ano';
    return '$days dias';
  }

  String _getIntervalText(int? days) {
    if (days == null) return _formatIntervalText(7); // Default: 1 semana
    return _formatIntervalText(days);
  }

  int _getIntervalDays(String interval) {
    // Extrai o número de dias do texto formatado
    final match = RegExp(r'(\d+)').firstMatch(interval);
    if (match == null) return 7; // default

    final num = int.tryParse(match.group(1)!) ?? 7;

    // Converte unidades para dias
    if (interval.contains('semana')) {
      return num * 7;
    } else if (interval.contains('mês') || interval.contains('meses')) {
      return num * 30;
    } else if (interval.contains('ano')) {
      return num * 365;
    }
    return num; // já está em dias
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final formState = ref.watch(plantFormStateNotifierProvider);
        final formNotifier = ref.read(plantFormStateNotifierProvider.notifier);
        final fieldErrors = formState
            .fieldErrors; // Get validation errors for real-time display

        return Column(
          children: [
            _buildCareSection(
              title: 'Água',
              icon: Icons.water_drop,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enableWateringCare ?? false,
              onToggle: (value) =>
                  formNotifier.setWateringConfig(enabled: value),
              interval: _getIntervalText(formState.wateringIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setWateringConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastWateringDate,
              onDateChanged: (date) =>
                  formNotifier.setWateringConfig(lastDate: date),
              errorText:
                  fieldErrors['wateringInterval'], // Show validation error
            ),
            const SizedBox(height: 20),
            _buildCareSection(
              title: 'Adubo',
              icon: Icons.eco,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enableFertilizerCare ?? false,
              onToggle: (value) =>
                  formNotifier.setFertilizerConfig(enabled: value),
              interval: _getIntervalText(formState.fertilizingIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setFertilizerConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastFertilizerDate,
              onDateChanged: (date) =>
                  formNotifier.setFertilizerConfig(lastDate: date),
              errorText:
                  fieldErrors['fertilizingInterval'], // Show validation error
            ),
            const SizedBox(height: 20),
            _buildCareSection(
              title: 'Luz solar',
              icon: Icons.wb_sunny,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enableSunlightCare ?? false,
              onToggle: (value) =>
                  formNotifier.setSunlightConfig(enabled: value),
              interval: _getIntervalText(formState.sunlightIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setSunlightConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastSunlightDate,
              onDateChanged: (date) =>
                  formNotifier.setSunlightConfig(lastDate: date),
            ),
            const SizedBox(height: 20),
            _buildCareSection(
              title: 'Verificação de pragas',
              icon: Icons.bug_report,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enablePestInspection ?? false,
              onToggle: (value) =>
                  formNotifier.setPestInspectionConfig(enabled: value),
              interval: _getIntervalText(formState.pestInspectionIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setPestInspectionConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastPestInspectionDate,
              onDateChanged: (date) =>
                  formNotifier.setPestInspectionConfig(lastDate: date),
            ),
            const SizedBox(height: 20),
            _buildCareSection(
              title: 'Poda',
              icon: Icons.content_cut,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enablePruning ?? false,
              onToggle: (value) =>
                  formNotifier.setPruningConfig(enabled: value),
              interval: _getIntervalText(formState.pruningIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setPruningConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastPruningDate,
              onDateChanged: (date) =>
                  formNotifier.setPruningConfig(lastDate: date),
              errorText:
                  fieldErrors['pruningInterval'], // Show validation error
            ),
            const SizedBox(height: 20),
            _buildCareSection(
              title: 'Replantio',
              icon: Icons.grass,
              iconColor: PlantisColors.primary,
              isEnabled: formState.enableReplanting ?? false,
              onToggle: (value) =>
                  formNotifier.setReplantingConfig(enabled: value),
              interval: _getIntervalText(formState.replantingIntervalDays),
              onIntervalChanged: (interval) {
                formNotifier.setReplantingConfig(
                  intervalDays: _getIntervalDays(interval),
                );
              },
              lastDate: formState.lastReplantingDate,
              onDateChanged: (date) =>
                  formNotifier.setReplantingConfig(lastDate: date),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCareSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required String interval,
    required ValueChanged<String> onIntervalChanged,
    required DateTime? lastDate,
    required ValueChanged<DateTime?> onDateChanged,
    String? errorText, // Add error text parameter
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : const Color(0xFFFFFFFF), // Branco puro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null
              ? theme
                    .colorScheme
                    .error // Show error border
              : (isEnabled
                    ? iconColor.withValues(
                        alpha: 0.5,
                      ) // Stronger border when enabled
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
          width: isEnabled ? 2.0 : 1.5, // Thicker border when enabled
        ),
        boxShadow: [
          BoxShadow(
            color: isEnabled
                ? iconColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isEnabled ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: iconColor,
                inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[400],
                inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (isEnabled) ...[
                  const SizedBox(height: 16),
                  _buildExpandedContent(
                    interval: interval,
                    onIntervalChanged: onIntervalChanged,
                    lastDate: lastDate,
                    onDateChanged: onDateChanged,
                    iconColor: iconColor,
                  ),
                ],
                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent({
    required String interval,
    required ValueChanged<String> onIntervalChanged,
    required DateTime? lastDate,
    required ValueChanged<DateTime?> onDateChanged,
    required Color iconColor,
  }) {
    return Column(
      children: [
        _buildIntervalSelector(
          label: 'Intervalo',
          value: interval,
          onChanged: onIntervalChanged,
          iconColor: iconColor,
        ),
        const SizedBox(height: 12),
        _buildDateSelector(
          label: 'Última vez',
          value: lastDate,
          onChanged: onDateChanged,
          iconColor: iconColor,
        ),
      ],
    );
  }

  Widget _buildIntervalSelector({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showIntervalPicker(value, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit, color: iconColor, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showDatePicker(value, onChanged),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value != null ? _formatDate(value) : 'Hoje',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_calendar, color: iconColor, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    // Extrai o número de dias do texto atual
    int currentDays = 7; // default
    final match = RegExp(r'(\d+)').firstMatch(currentValue);
    if (match != null) {
      final num = int.tryParse(match.group(1)!);
      if (num != null) {
        // Converte unidades para dias
        if (currentValue.contains('semana')) {
          currentDays = num * 7;
        } else if (currentValue.contains('mês') ||
            currentValue.contains('meses')) {
          currentDays = num * 30;
        } else if (currentValue.contains('ano')) {
          currentDays = num * 365;
        } else {
          currentDays = num;
        }
      }
    }
    currentDays = currentDays.clamp(1, 365);

    showDialog<int>(
      context: context,
      builder: (context) => _IntervalPickerDialog(
        initialDays: currentDays,
        formatIntervalText: _formatIntervalText,
      ),
    ).then((selectedDays) {
      if (selectedDays != null) {
        onChanged(_formatIntervalText(selectedDays));
      }
    });
  }

  void _showDatePicker(
    DateTime? currentValue,
    ValueChanged<DateTime?> onChanged,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentValue ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (date != null) {
      onChanged(date);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hoje';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == yesterday) {
      return 'Ontem';
    }

    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}

/// Dialog central com CupertinoPicker para seleção de intervalo (estilo iOS)
class _IntervalPickerDialog extends StatefulWidget {
  final int initialDays;
  final String Function(int) formatIntervalText;

  const _IntervalPickerDialog({
    required this.initialDays,
    required this.formatIntervalText,
  });

  @override
  State<_IntervalPickerDialog> createState() => _IntervalPickerDialogState();
}

class _IntervalPickerDialogState extends State<_IntervalPickerDialog> {
  late int _selectedDays;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialDays.clamp(1, 365);
    // O índice é days - 1 porque o array começa em 0 mas os dias começam em 1
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedDays - 1,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                'Selecionar Intervalo',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Texto formatado do intervalo selecionado
              Text(
                widget.formatIntervalText(_selectedDays),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: PlantisColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // CupertinoPicker
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  itemExtent: 44,
                  diameterRatio: 1.2,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: PlantisColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDays = index + 1; // índice 0 = 1 dia
                    });
                  },
                  children: List.generate(365, (index) {
                    final days = index + 1;
                    final isSelected = days == _selectedDays;
                    return Center(
                      child: Text(
                        '$days ${days == 1 ? 'dia' : 'dias'}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? PlantisColors.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selectedDays),
                      style: FilledButton.styleFrom(
                        backgroundColor: PlantisColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
