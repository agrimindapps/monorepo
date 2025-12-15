import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Campo unificado para seleção de data e hora
///
/// Suporta dois modos de input:
/// 1. **Clique nos ícones**: Abre date/time pickers
/// 2. **Digitação manual**: Permite digitar data (dd/MM/yyyy) e hora (HH:mm)
///
/// Características visuais preservadas:
/// - Material + InkWell para efeito de toque
/// - InputDecorator com borda rounded
/// - Layout em Row com data | separador | hora
/// - Ícones de calendário e relógio
/// - Tema cinza escuro consistente nos pickers
/// - Locale pt-BR padrão
///
/// Exemplo de uso:
/// ```dart
/// DateTimeField(
///   value: provider.formModel.date,
///   onChanged: (newDate) => provider.updateDate(newDate),
///   label: 'Data e Hora',
/// )
/// ```
class DateTimeField extends StatefulWidget {
  const DateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.firstDate,
    this.lastDate,
    this.suffixIcon = Icons.calendar_today,
    this.enabled = true,
    this.helperText,
  });

  /// Valor atual da data/hora
  final DateTime value;

  /// Callback quando a data/hora é alterada
  final ValueChanged<DateTime> onChanged;

  /// Label do campo
  final String label;

  /// Data mínima permitida (padrão: 1 ano atrás)
  final DateTime? firstDate;

  /// Data máxima permitida (padrão: hoje)
  final DateTime? lastDate;

  /// Ícone do sufixo (padrão: calendar_today)
  final IconData suffixIcon;

  /// Se o campo está habilitado
  final bool enabled;

  /// Texto de helper (opcional)
  final String? helperText;

  @override
  State<DateTimeField> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends State<DateTimeField> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.value),
    );
    _timeController = TextEditingController(
      text: DateFormat('HH:mm').format(widget.value),
    );

    _dateFocusNode.addListener(_onDateFocusChanged);
    _timeFocusNode.addListener(_onTimeFocusChanged);
  }

  @override
  void didUpdateWidget(DateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Only update text if not focused to avoid interrupting typing
      if (!_dateFocusNode.hasFocus) {
        _dateController.text = DateFormat('dd/MM/yyyy').format(widget.value);
      }
      if (!_timeFocusNode.hasFocus) {
        _timeController.text = DateFormat('HH:mm').format(widget.value);
      }
    }
  }

  @override
  void dispose() {
    _dateFocusNode.removeListener(_onDateFocusChanged);
    _timeFocusNode.removeListener(_onTimeFocusChanged);
    _dateController.dispose();
    _timeController.dispose();
    _dateFocusNode.dispose();
    _timeFocusNode.dispose();
    super.dispose();
  }

  void _onDateFocusChanged() {
    if (!_dateFocusNode.hasFocus) {
      // Revert to valid value on blur if current text is invalid
      _validateAndRevertDate();
    } else {
      // Select all on focus for easy editing
      _dateController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _dateController.text.length,
      );
    }
  }

  void _onTimeFocusChanged() {
    if (!_timeFocusNode.hasFocus) {
      _validateAndRevertTime();
    } else {
      _timeController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _timeController.text.length,
      );
    }
  }

  void _validateAndRevertDate() {
    final text = _dateController.text;
    if (text.length != 10) {
      _revertDate();
      return;
    }
    try {
      final parts = text.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      // Basic validation
      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
        _revertDate();
      }
      // Date validity check (e.g. 31/02)
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        _revertDate();
      }
    } catch (_) {
      _revertDate();
    }
  }

  void _revertDate() {
    _dateController.text = DateFormat('dd/MM/yyyy').format(widget.value);
  }

  void _validateAndRevertTime() {
    final text = _timeController.text;
    if (text.length != 5) {
      _revertTime();
      return;
    }
    try {
      final parts = text.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        _revertTime();
      }
    } catch (_) {
      _revertTime();
    }
  }

  void _revertTime() {
    _timeController.text = DateFormat('HH:mm').format(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Row(
          children: [
            // Campo de Data
            Expanded(
              flex: 3,
              child: TextField(
                controller: _dateController,
                focusNode: _dateFocusNode,
                enabled: widget.enabled,
                style: const TextStyle(fontSize: 16),
                decoration: _buildDecoration(
                  context,
                  'dd/MM/yyyy',
                  widget.suffixIcon,
                  () => _openDatePicker(context),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  _DateInputFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: _onDateTextChanged,
                onSubmitted: (_) => _timeFocusNode.requestFocus(),
              ),
            ),
            const SizedBox(width: 12),
            // Campo de Hora
            Expanded(
              flex: 2,
              child: TextField(
                controller: _timeController,
                focusNode: _timeFocusNode,
                enabled: widget.enabled,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
                decoration: _buildDecoration(
                  context,
                  'HH:mm',
                  Icons.access_time,
                  () => _openTimePicker(context),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  _TimeInputFormatter(),
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: _onTimeTextChanged,
              ),
            ),
          ],
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _buildDecoration(
    BuildContext context,
    String hint,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      suffixIcon: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: widget.enabled ? onPressed : null,
        tooltip: 'Selecionar',
        color: theme.colorScheme.onSurfaceVariant,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: theme.brightness == Brightness.dark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  void _onDateTextChanged(String value) {
    if (value.length == 10) {
      final parts = value.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        
        if (day != null && month != null && year != null) {
          if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
            try {
              final newDate = DateTime(
                year,
                month,
                day,
                widget.value.hour,
                widget.value.minute,
              );
              widget.onChanged(newDate);
              // Auto-focus time field when date is complete
              _timeFocusNode.requestFocus();
            } catch (e) {
              // Data inválida, ignora
            }
          }
        }
      }
    }
  }

  void _onTimeTextChanged(String value) {
    if (value.length == 5) {
      final parts = value.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        if (hour != null && minute != null) {
          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            final newDateTime = DateTime(
              widget.value.year,
              widget.value.month,
              widget.value.day,
              hour,
              minute,
            );
            widget.onChanged(newDateTime);
          }
        }
      }
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final defaultFirstDate =
        widget.firstDate ?? DateTime.now().subtract(const Duration(days: 365));
    final defaultLastDate = widget.lastDate ?? DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: widget.value,
      firstDate: defaultFirstDate,
      lastDate: defaultLastDate,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final combinedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        widget.value.hour,
        widget.value.minute,
      );
      widget.onChanged(combinedDateTime);
    }
  }

  Future<void> _openTimePicker(BuildContext context) async {
    final currentTime = TimeOfDay.fromDateTime(widget.value);
    
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Localizations.override(
            context: context,
            locale: const Locale('pt', 'BR'),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      final combinedDateTime = DateTime(
        widget.value.year,
        widget.value.month,
        widget.value.day,
        time.hour,
        time.minute,
      );
      widget.onChanged(combinedDateTime);
    }
  }
}

/// Formatter para input de data (dd/MM/yyyy)
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < text.length && i < 10; i++) {
      if (text[i] != '/') {
        newText.write(text[i]);
        if ((newText.length == 2 || newText.length == 5) && i < text.length - 1) {
          newText.write('/');
          if (i >= newValue.selection.end - 1) {
            selectionIndex++;
          }
        }
      }
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Formatter para input de hora (HH:mm)
class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    for (int i = 0; i < text.length && i < 5; i++) {
      if (text[i] != ':') {
        newText.write(text[i]);
        if (newText.length == 2 && i < text.length - 1) {
          newText.write(':');
          if (i >= newValue.selection.end - 1) {
            selectionIndex++;
          }
        }
      }
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Variação do DateTimeField para casos onde pode ser opcional/futuro
class FutureDateTimeField extends StatelessWidget {
  const FutureDateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.placeholder = 'Selecionar data',
    this.suffixIcon = Icons.schedule,
    this.enabled = true,
    this.helperText,
  });
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String label;
  final String placeholder;
  final IconData suffixIcon;
  final bool enabled;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _selectDateTime(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(suffixIcon, size: 24),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Theme.of(context).colorScheme.surface,
            helperText: helperText,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value != null
                      ? DateFormat('dd/MM/yyyy').format(value!)
                      : placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: value != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 16),
                Container(
                  height: 20,
                  width: 1,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    TimeOfDay.fromDateTime(value!).format(context),
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final currentDate = value ?? DateTime.now().add(const Duration(days: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.grey.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      final currentTime = value != null
          ? TimeOfDay.fromDateTime(value!)
          : const TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM

      final time = await showTimePicker(
        context: context,
        initialTime: currentTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: Localizations.override(
              context: context,
              locale: const Locale('pt', 'BR'),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: child!,
              ),
            ),
          );
        },
      );

      if (time != null) {
        final combinedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(combinedDateTime);
      }
    }
  }
}

/// Variação simplificada para casos específicos com ranges customizados
class CustomRangeDateTimeField extends StatelessWidget {
  const CustomRangeDateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.firstDate,
    required this.lastDate,
    this.suffixIcon = Icons.calendar_today,
    this.enabled = true,
  });
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final DateTime firstDate;
  final DateTime lastDate;
  final IconData suffixIcon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      value: value,
      onChanged: onChanged,
      label: label,
      firstDate: firstDate,
      lastDate: lastDate,
      suffixIcon: suffixIcon,
      enabled: enabled,
    );
  }
}
