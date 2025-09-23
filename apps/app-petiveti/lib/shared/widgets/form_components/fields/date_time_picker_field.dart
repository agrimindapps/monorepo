import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// **Date Time Picker Field Component**
///
/// Componente reutilizável para seleção de data, hora ou data/hora em formulários.
/// Unifica todas as funcionalidades relacionadas a pickers temporais.
///
/// **Modos Suportados:**
/// - `date`: Apenas data
/// - `time`: Apenas hora
/// - `dateTime`: Data e hora combinadas
/// - `dateRange`: Período de datas
///
/// **Funcionalidades:**
/// - Interface consistente em todos os modos
/// - Validação integrada
/// - Formatação automática
/// - Estados de erro e disabled
/// - Textos descritivos automáticos
///
/// **Uso:**
/// ```dart
/// DateTimePickerField.date(
///   value: selectedDate,
///   onChanged: (date) => setState(() => selectedDate = date),
///   label: 'Data de Nascimento',
/// )
/// ```
enum DateTimePickerMode {
  date,
  time,
  dateTime,
  dateRange,
}

class DateTimePickerField extends StatelessWidget {
  /// Modo do picker
  final DateTimePickerMode mode;

  /// Valor atual
  final DateTime? value;

  /// Valor de início (para dateRange)
  final DateTime? startValue;

  /// Valor de fim (para dateRange)
  final DateTime? endValue;

  /// Callback para mudança de valor
  final ValueChanged<DateTime?>? onChanged;

  /// Callback para mudança de período (dateRange)
  final void Function(DateTime? start, DateTime? end)? onRangeChanged;

  /// Label do campo
  final String? label;

  /// Texto de hint
  final String? hint;

  /// Função de validação
  final String? Function(DateTime?)? validator;

  /// Se o campo está habilitado
  final bool enabled;

  /// Data mínima permitida
  final DateTime? firstDate;

  /// Data máxima permitida
  final DateTime? lastDate;

  /// Ícone personalizado
  final IconData? icon;

  /// Texto de ajuda adicional
  final String? helperText;

  const DateTimePickerField._({
    super.key,
    required this.mode,
    this.value,
    this.startValue,
    this.endValue,
    this.onChanged,
    this.onRangeChanged,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.icon,
    this.helperText,
  });

  /// Construtor para seleção apenas de data
  factory DateTimePickerField.date({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    String? label,
    String? hint,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helperText,
  }) {
    return DateTimePickerField._(
      key: key,
      mode: DateTimePickerMode.date,
      value: value,
      onChanged: onChanged,
      label: label ?? 'Data',
      hint: hint ?? 'Selecione uma data',
      validator: validator,
      enabled: enabled,
      firstDate: firstDate,
      lastDate: lastDate,
      icon: Icons.calendar_today,
      helperText: helperText,
    );
  }

  /// Construtor para seleção apenas de hora
  factory DateTimePickerField.time({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    String? label,
    String? hint,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    String? helperText,
  }) {
    return DateTimePickerField._(
      key: key,
      mode: DateTimePickerMode.time,
      value: value,
      onChanged: onChanged,
      label: label ?? 'Hora',
      hint: hint ?? 'Selecione uma hora',
      validator: validator,
      enabled: enabled,
      icon: Icons.access_time,
      helperText: helperText,
    );
  }

  /// Construtor para seleção de data e hora
  factory DateTimePickerField.dateTime({
    Key? key,
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    String? label,
    String? hint,
    String? Function(DateTime?)? validator,
    bool enabled = true,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helperText,
  }) {
    return DateTimePickerField._(
      key: key,
      mode: DateTimePickerMode.dateTime,
      value: value,
      onChanged: onChanged,
      label: label ?? 'Data e Hora',
      hint: hint ?? 'Selecione data e hora',
      validator: validator,
      enabled: enabled,
      firstDate: firstDate,
      lastDate: lastDate,
      icon: Icons.event,
      helperText: helperText,
    );
  }

  /// Construtor para seleção de período
  factory DateTimePickerField.dateRange({
    Key? key,
    DateTime? startValue,
    DateTime? endValue,
    void Function(DateTime? start, DateTime? end)? onRangeChanged,
    String? label,
    String? hint,
    bool enabled = true,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helperText,
  }) {
    return DateTimePickerField._(
      key: key,
      mode: DateTimePickerMode.dateRange,
      startValue: startValue,
      endValue: endValue,
      onRangeChanged: onRangeChanged,
      label: label ?? 'Período',
      hint: hint ?? 'Selecione o período',
      enabled: enabled,
      firstDate: firstDate,
      lastDate: lastDate,
      icon: Icons.date_range,
      helperText: helperText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Campo principal
        if (mode == DateTimePickerMode.dateRange)
          _buildDateRangeField(context)
        else
          _buildSingleField(context),

        // Texto de ajuda
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleField(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _handleTap(context) : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: enabled ? AppColors.primary : AppColors.textSecondary,
          ),
          suffixIcon: enabled
              ? const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Text(
          _getDisplayText(),
          style: TextStyle(
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: enabled ? () => _handleDateRangeTap(context, true) : null,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data de Início',
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                startValue != null ? _formatDate(startValue!) : 'Selecionar',
                style: TextStyle(
                  color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: enabled ? () => _handleDateRangeTap(context, false) : null,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data de Fim',
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                endValue != null ? _formatDate(endValue!) : 'Selecionar',
                style: TextStyle(
                  color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayText() {
    if (value == null) return hint ?? 'Selecionar';

    switch (mode) {
      case DateTimePickerMode.date:
        return _formatDate(value!);
      case DateTimePickerMode.time:
        return _formatTime(value!);
      case DateTimePickerMode.dateTime:
        return '${_formatDate(value!)} às ${_formatTime(value!)}';
      case DateTimePickerMode.dateRange:
        return 'Range mode não suportado aqui';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleTap(BuildContext context) async {
    switch (mode) {
      case DateTimePickerMode.date:
        await _pickDate(context);
        break;
      case DateTimePickerMode.time:
        await _pickTime(context);
        break;
      case DateTimePickerMode.dateTime:
        await _pickDateTime(context);
        break;
      case DateTimePickerMode.dateRange:
        // Handled separately
        break;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'Selecionar data',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (date != null) {
      onChanged?.call(date);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: value != null
          ? TimeOfDay.fromDateTime(value!)
          : TimeOfDay.now(),
      helpText: 'Selecionar hora',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (time != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      onChanged?.call(dateTime);
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    // Primeiro pega a data
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'Selecionar data',
      cancelText: 'Cancelar',
      confirmText: 'Continuar',
    );

    if (date != null) {
      // Depois pega a hora
      final time = await showTimePicker(
        context: context,
        initialTime: value != null
            ? TimeOfDay.fromDateTime(value!)
            : TimeOfDay.now(),
        helpText: 'Selecionar hora',
        cancelText: 'Cancelar',
        confirmText: 'OK',
      );

      if (time != null && context.mounted) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged?.call(dateTime);
      }
    }
  }

  Future<void> _handleDateRangeTap(BuildContext context, bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? startValue : endValue) ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: isStart ? 'Data de início' : 'Data de fim',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (date != null && onRangeChanged != null) {
      if (isStart) {
        onRangeChanged!(date, endValue);
      } else {
        onRangeChanged!(startValue, date);
      }
    }
  }
}

/// **Extensões para casos comuns**
extension DateTimePickerFieldExtensions on DateTimePickerField {
  /// Campo de data de nascimento padrão
  static Widget birthDate({
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    bool enabled = true,
  }) {
    return DateTimePickerField.date(
      value: value,
      onChanged: onChanged,
      label: 'Data de Nascimento',
      hint: 'Selecione a data de nascimento',
      enabled: enabled,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      lastDate: DateTime.now(),
      validator: (value) => value == null ? 'Data de nascimento é obrigatória' : null,
    );
  }

  /// Campo de agendamento de compromissos
  static Widget appointment({
    DateTime? value,
    ValueChanged<DateTime?>? onChanged,
    bool enabled = true,
  }) {
    return DateTimePickerField.dateTime(
      value: value,
      onChanged: onChanged,
      label: 'Data e Hora do Compromisso',
      hint: 'Agendar para quando?',
      enabled: enabled,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      validator: (value) => value == null ? 'Selecione a data e hora' : null,
    );
  }

  /// Campo de período de tratamento
  static Widget treatmentPeriod({
    DateTime? startValue,
    DateTime? endValue,
    void Function(DateTime? start, DateTime? end)? onRangeChanged,
    bool enabled = true,
  }) {
    return DateTimePickerField.dateRange(
      startValue: startValue,
      endValue: endValue,
      onRangeChanged: onRangeChanged,
      label: 'Período do Tratamento',
      enabled: enabled,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
  }
}