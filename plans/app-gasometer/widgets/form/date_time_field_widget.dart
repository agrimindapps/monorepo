// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';

/// Widget reutilizável para seleção de data e hora nos formulários.
class DateTimeFieldWidget extends StatefulWidget {
  final String label;
  final int initialValue; // timestamp em milliseconds
  final void Function(int)? onChanged;
  final bool showTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateTimeFieldWidget({
    super.key,
    required this.label,
    required this.initialValue,
    this.onChanged,
    this.showTime = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<DateTimeFieldWidget> createState() => _DateTimeFieldWidgetState();
}

class _DateTimeFieldWidgetState extends State<DateTimeFieldWidget> {
  late int _timestamp;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.initialValue;
    _dateTime = DateTime.fromMillisecondsSinceEpoch(_timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: ShadcnStyle.inputDecoration(
            label: widget.label,
            suffixIcon: Icon(
              Icons.calendar_today,
              size: 20,
              color: ShadcnStyle.labelColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date picker
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_dateTime),
                    style: ShadcnStyle.inputStyle,
                  ),
                ),
              ),

              if (widget.showTime) ...[
                const SizedBox(width: 40),
                Container(height: 20, width: 1, color: ShadcnStyle.borderColor),
                // Time picker
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: Text(
                      DateFormat('HH:mm').format(_dateTime),
                      style: ShadcnStyle.inputStyle,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      helpText: 'Selecione a data',
      currentDate: DateTime.now(),
      initialDate: _dateTime,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('pt', 'BR'),
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      setState(() {
        _dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _dateTime.hour,
          _dateTime.minute,
        );

        _updateTimestamp();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
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
        hour: _dateTime.hour,
        minute: _dateTime.minute,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _dateTime = DateTime(
          _dateTime.year,
          _dateTime.month,
          _dateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _updateTimestamp();
      });
    }
  }

  void _updateTimestamp() {
    _timestamp = _dateTime.millisecondsSinceEpoch;
    if (widget.onChanged != null) {
      widget.onChanged!(_timestamp);
    }
  }
}
