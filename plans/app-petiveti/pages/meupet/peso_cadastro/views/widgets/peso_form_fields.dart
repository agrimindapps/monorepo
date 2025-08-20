// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/date_field_widget.dart';
import '../../../../../widgets/numeric_field_widget.dart';
import '../../../../../widgets/observation_field_widget.dart';

class PesoFormFields extends StatelessWidget {
  final DateTime initialDate;
  final double? initialPeso;
  final String initialObservacoes;
  final Function(DateTime) onDateChanged;
  final Function(double) onPesoChanged;
  final Function(String) onObservacoesChanged;
  final String? Function(double?)? pesoValidator;

  const PesoFormFields({
    super.key,
    required this.initialDate,
    this.initialPeso,
    this.initialObservacoes = '',
    required this.onDateChanged,
    required this.onPesoChanged,
    required this.onObservacoesChanged,
    this.pesoValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DateFieldWidget(
          label: 'Data da Pesagem',
          initialDate: initialDate,
          lastDate: DateTime.now(),
          onDateSelected: onDateChanged,
        ),
        const SizedBox(height: 16),
        NumericFieldWidget(
          label: 'Peso',
          suffix: 'kg',
          initialValue: initialPeso,
          minValue: 0.01,
          maxValue: 500,
          validator: pesoValidator,
          onSaved: (value) => onPesoChanged(value),
        ),
        const SizedBox(height: 16),
        ObservationFieldWidget(
          label: 'Observações',
          initialValue: initialObservacoes,
          isRequired: false,
          onSaved: (value) => onObservacoesChanged(value ?? ''),
        ),
      ],
    );
  }
}
