// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/abastecimento_form_controller.dart';

class DateTimeField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const DateTimeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var data = controller.formModel.data;
      data = data > 0 ? data : DateTime.now().millisecondsSinceEpoch;
      final currentDate = DateTime.fromMillisecondsSinceEpoch(data);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          InputDecorator(
            decoration: ShadcnStyle.inputDecoration(
              label: 'Data e Hora',
              suffixIcon: Icon(
                Icons.calendar_today,
                size: 20,
                color: ShadcnStyle.labelColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showDatePicker(context, currentDate),
                    child: Text(DateFormat('dd/MM/yyyy').format(currentDate)),
                  ),
                ),
                const SizedBox(width: 40),
                Container(height: 20, width: 1, color: ShadcnStyle.borderColor),
                Expanded(
                  child: InkWell(
                    onTap: () => _showTimePicker(context, currentDate),
                    child: Text(
                      DateFormat('HH:mm').format(currentDate),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showDatePicker(
      BuildContext context, DateTime currentDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      helpText: 'Selecione a data',
      currentDate: DateTime.now(),
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
      controller.updateData(newDateTime.millisecondsSinceEpoch);
    }
  }

  Future<void> _showTimePicker(
      BuildContext context, DateTime currentDate) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
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
      controller.updateData(newDateTime.millisecondsSinceEpoch);
    }
  }
}
