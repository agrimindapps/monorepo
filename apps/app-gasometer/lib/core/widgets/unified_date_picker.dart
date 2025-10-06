import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/unified_design_tokens.dart';

/// Seletor de data unificado com design consistente
/// 
/// Características:
/// - Design Material 3 padronizado
/// - Suporte a diferentes tipos de seleção (data, hora, data+hora)
/// - Formatação brasileira padrão
/// - Validação de intervalos
/// - Integração com UnifiedFormField
/// - Estados de erro e validação
class UnifiedDatePicker {
  /// Seleciona uma data usando o Material Date Picker
  static Future<DateTime?> selectDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? confirmText,
    String? cancelText,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  }) async {
    final theme = Theme.of(context);
    
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: helpText ?? 'Selecione uma data',
      confirmText: confirmText ?? 'Confirmar',
      cancelText: cancelText ?? 'Cancelar',
      locale: const Locale('pt', 'BR'),
      initialEntryMode: initialEntryMode,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
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
  }
  
  /// Seleciona um horário usando o Material Time Picker
  static Future<TimeOfDay?> selectTime(
    BuildContext context, {
    TimeOfDay? initialTime,
    String? helpText,
    String? confirmText,
    String? cancelText,
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  }) async {
    final theme = Theme.of(context);
    
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: helpText ?? 'Selecione um horário',
      confirmText: confirmText ?? 'Confirmar',
      cancelText: cancelText ?? 'Cancelar',
      initialEntryMode: initialEntryMode,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
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
  }
  
  /// Seleciona data e horário em sequência
  static Future<DateTime?> selectDateTime(
    BuildContext context, {
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateHelpText,
    String? timeHelpText,
  }) async {
    final date = await selectDate(
      context,
      initialDate: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: dateHelpText ?? 'Selecione a data',
    );
    
    if (date == null || !context.mounted) return null;
    final time = await selectTime(
      context,
      initialTime: initialDateTime != null
          ? TimeOfDay.fromDateTime(initialDateTime)
          : TimeOfDay.now(),
      helpText: timeHelpText ?? 'Selecione o horário',
    );
    
    if (time == null) return date; // Retorna só a data se cancelar o horário
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}

/// Campo de formulário específico para seleção de datas
class UnifiedDateField extends StatefulWidget {
  const UnifiedDateField({
    super.key,
    required this.label,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
    this.required = false,
    this.enabled = true,
    this.format = 'dd/MM/yyyy',
    this.prefixIcon,
    this.hint,
    this.helpText,
  });

  final String label;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onDateChanged;
  final bool required;
  final bool enabled;
  final String format;
  final IconData? prefixIcon;
  final String? hint;
  final String? helpText;

  @override
  State<UnifiedDateField> createState() => _UnifiedDateFieldState();
}

class _UnifiedDateFieldState extends State<UnifiedDateField> {
  DateTime? _selectedDate;
  late DateFormat _dateFormatter;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _dateFormatter = DateFormat(widget.format, 'pt_BR');
  }

  @override
  void didUpdateWidget(UnifiedDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate;
    }
    if (widget.format != oldWidget.format) {
      _dateFormatter = DateFormat(widget.format, 'pt_BR');
    }
  }

  Future<void> _selectDate() async {
    final date = await UnifiedDatePicker.selectDate(
      context,
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      widget.onDateChanged?.call(date);
    }
  }

  String get _displayText {
    if (_selectedDate == null) return '';
    return _dateFormatter.format(_selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: UnifiedDesignTokens.spacingSM),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: UnifiedDesignTokens.fontWeightMedium,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: UnifiedDesignTokens.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        InkWell(
          onTap: widget.enabled ? _selectDate : null,
          borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UnifiedDesignTokens.spacingLG,
              vertical: UnifiedDesignTokens.spacingMD,
            ),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? theme.colorScheme.surface
                  : UnifiedDesignTokens.colorSurfaceVariant,
              border: Border.all(
                color: theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: widget.enabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 20,
                  ),
                  const SizedBox(width: UnifiedDesignTokens.spacingMD),
                ],
                Expanded(
                  child: Text(
                    _displayText.isEmpty
                        ? widget.hint ?? 'Selecionar data'
                        : _displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _displayText.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : (widget.enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: widget.enabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (widget.helpText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: UnifiedDesignTokens.spacingSM,
              left: UnifiedDesignTokens.spacingMD,
            ),
            child: Text(
              widget.helpText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Campo de formulário para seleção de horário
class UnifiedTimeField extends StatefulWidget {
  const UnifiedTimeField({
    super.key,
    required this.label,
    this.initialTime,
    this.onTimeChanged,
    this.required = false,
    this.enabled = true,
    this.use24HourFormat = true,
    this.prefixIcon,
    this.hint,
    this.helpText,
  });

  final String label;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final bool required;
  final bool enabled;
  final bool use24HourFormat;
  final IconData? prefixIcon;
  final String? hint;
  final String? helpText;

  @override
  State<UnifiedTimeField> createState() => _UnifiedTimeFieldState();
}

class _UnifiedTimeFieldState extends State<UnifiedTimeField> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  void didUpdateWidget(UnifiedTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTime != oldWidget.initialTime) {
      _selectedTime = widget.initialTime;
    }
  }

  Future<void> _selectTime() async {
    final time = await UnifiedDatePicker.selectTime(
      context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
      widget.onTimeChanged?.call(time);
    }
  }

  String get _displayText {
    if (_selectedTime == null) return '';
    if (widget.use24HourFormat) {
      return '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    }
    return _selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: UnifiedDesignTokens.spacingSM),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: UnifiedDesignTokens.fontWeightMedium,
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  if (widget.required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: UnifiedDesignTokens.fontWeightMedium,
                      ),
                    ),
                ],
              ),
            ),
          ),
        InkWell(
          onTap: widget.enabled ? _selectTime : null,
          borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UnifiedDesignTokens.spacingLG,
              vertical: UnifiedDesignTokens.spacingMD,
            ),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? theme.colorScheme.surface
                  : UnifiedDesignTokens.colorSurfaceVariant,
              border: Border.all(
                color: theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(UnifiedDesignTokens.radiusInput),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Icon(
                    widget.prefixIcon,
                    color: widget.enabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 20,
                  ),
                  const SizedBox(width: UnifiedDesignTokens.spacingMD),
                ],
                Expanded(
                  child: Text(
                    _displayText.isEmpty
                        ? widget.hint ?? 'Selecionar horário'
                        : _displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _displayText.isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : (widget.enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: widget.enabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (widget.helpText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: UnifiedDesignTokens.spacingSM,
              left: UnifiedDesignTokens.spacingMD,
            ),
            child: Text(
              widget.helpText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}