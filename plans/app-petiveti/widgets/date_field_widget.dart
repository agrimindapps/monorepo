// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Um campo para seleção de data que exibe um DatePicker quando clicado.
class DateFieldWidget extends StatelessWidget {
  /// Label do campo
  final String label;

  /// Data inicial selecionada
  final DateTime initialDate;

  /// Data mínima permitida (opcional)
  final DateTime? firstDate;

  /// Data máxima permitida (opcional)
  final DateTime? lastDate;

  /// Ícone para o sufixo (opcional)
  final Icon? suffixIcon;

  /// Callback chamado quando uma nova data é selecionada
  final ValueChanged<DateTime> onDateSelected;

  /// Formato para exibição da data (padrão: dd/MM/yyyy)
  final String dateFormat;

  const DateFieldWidget({
    super.key,
    required this.label,
    required this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.suffixIcon,
    this.dateFormat = 'dd/MM/yyyy',
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat(dateFormat);

    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );

        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: ShadcnStyle.inputDecoration(
          label: label,
          suffixIcon: suffixIcon ?? const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          formatter.format(initialDate),
          style: ShadcnStyle.inputStyle,
        ),
      ),
    );
  }
}
