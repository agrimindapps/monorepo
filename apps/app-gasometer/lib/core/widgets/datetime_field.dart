import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Campo unificado para seleção de data e hora
///
/// Mantém exatamente o mesmo visual e comportamento que existe
/// atualmente em todos os formulários do app, centralizando
/// apenas a implementação para evitar duplicação de código.
///
/// Características visuais preservadas:
/// - Material + InkWell para efeito de toque
/// - InputDecorator com borda rounded
/// - Layout em Row com data | separador | hora
/// - Ícone de calendário padrão
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
class DateTimeField extends StatelessWidget {

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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _selectDateTime(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: Icon(
              suffixIcon,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            helperText: helperText,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd/MM/yyyy').format(value),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 20,
                width: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  TimeOfDay.fromDateTime(value).format(context),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Método privado que implementa exatamente a mesma lógica
  /// que existe em todos os formulários atualmente
  Future<void> _selectDateTime(BuildContext context) async {
    // Define os limites padrão se não foram fornecidos
    final defaultFirstDate = firstDate ?? DateTime.now().subtract(const Duration(days: 365));
    final defaultLastDate = lastDate ?? DateTime.now();

    // Select date first - usando exatamente o mesmo tema dos formulários existentes
    final date = await showDatePicker(
      context: context,
      initialDate: value,
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

    if (date != null && context.mounted) {
      // Then select time - usando exatamente o mesmo tema dos formulários existentes
      final currentTime = TimeOfDay.fromDateTime(value);
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
        // Update with combined date and time
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
            suffixIcon: Icon(
              suffixIcon,
              size: 24,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
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
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    // Para datas futuras - permite seleção de hoje até 10 anos no futuro
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