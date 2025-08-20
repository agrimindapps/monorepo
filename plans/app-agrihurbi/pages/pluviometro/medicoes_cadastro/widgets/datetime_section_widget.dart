// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';
import '../services/formatters/medicoes_formatters.dart';
import '../services/validators/medicoes_validator.dart';

class DateTimeSectionWidget extends StatelessWidget {
  final int dtMedicao;
  final Function(int) onDateTimeChanged;
  final String? errorMessage;

  const DateTimeSectionWidget({
    super.key,
    required this.dtMedicao,
    required this.onDateTimeChanged,
    this.errorMessage,
  });

  static final _formatter = MedicoesFormatters();

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(dtMedicao);

    // Validação em tempo real
    final validationResult = MedicoesValidator.validateData(dtMedicao);
    final hasError = !validationResult.isValid;
    final hasWarning = validationResult.warnings.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        InputDecorator(
          decoration: ShadcnStyle.inputDecoration(
            label: 'Data e Hora da Medição',
            suffixIcon: Icon(
              Icons.calendar_today,
              size: 20,
              color: hasError ? Colors.red : ShadcnStyle.labelColor,
            ),
          ).copyWith(
            errorText: hasError ? validationResult.errors.values.first : null,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      cancelText: 'Cancelar',
                      confirmText: 'Confirmar',
                      helpText: 'Selecione a data',
                      currentDate: DateTime.now(),
                      initialDate: currentDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      locale: const Locale('pt', 'BR'),
                      initialDatePickerMode: DatePickerMode.day,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );

                    if (pickedDate != null) {
                      final newDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        currentDate.hour,
                        currentDate.minute,
                      );

                      // Validação antes de aplicar mudança
                      final validation = MedicoesValidator.validateData(
                          newDateTime.millisecondsSinceEpoch);
                      if (validation.isValid) {
                        onDateTimeChanged(newDateTime.millisecondsSinceEpoch);
                      } else {
                        // Mostrar erro ao usuário
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(validation.errors.values.first),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    _formatter.formatDate(currentDate),
                    style: ShadcnStyle.inputStyle,
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: ShadcnStyle.borderColor,
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialEntryMode: TimePickerEntryMode.inputOnly,
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            alwaysUse24HourFormat: true,
                          ),
                          child: child!,
                        );
                      },
                      hourLabelText: 'Hora',
                      minuteLabelText: 'Minuto',
                      helpText: 'Selecione a hora',
                      cancelText: 'Cancelar',
                      confirmText: 'Confirmar',
                      initialTime: TimeOfDay(
                        hour: currentDate.hour,
                        minute: currentDate.minute,
                      ),
                    );

                    if (pickedTime != null) {
                      final newDateTime = DateTime(
                        currentDate.year,
                        currentDate.month,
                        currentDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      onDateTimeChanged(newDateTime.millisecondsSinceEpoch);
                    }
                  },
                  child: Text(
                    _formatter.formatTime(currentDate),
                    style: ShadcnStyle.inputStyle,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasWarning && !hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    validationResult.warnings.first,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
