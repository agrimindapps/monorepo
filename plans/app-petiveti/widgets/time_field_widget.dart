// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Um campo para seleção de hora que exibe um TimePicker quando clicado.
class TimeFieldWidget extends StatelessWidget {
  /// Label do campo
  final String label;

  /// Hora inicial selecionada
  final TimeOfDay initialTime;

  /// Callback chamado quando uma nova hora é selecionada
  final ValueChanged<TimeOfDay> onTimeSelected;

  /// Formato para exibição da hora (12h ou 24h)
  final bool use24hFormat;

  const TimeFieldWidget({
    super.key,
    required this.label,
    required this.initialTime,
    required this.onTimeSelected,
    this.use24hFormat = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          initialEntryMode: TimePickerEntryMode.input,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: use24hFormat,
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onTimeSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: ShadcnStyle.inputDecoration(
          label: label,
          suffixIcon: const Icon(Icons.access_time, size: 18),
        ),
        child: Text(
          _formatTime(initialTime),
          style: ShadcnStyle.inputStyle,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
