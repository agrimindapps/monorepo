// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/date_field_widget.dart';
import '../../../../../widgets/observation_field_widget.dart';
import '../../../../../widgets/text_field_widget.dart';

class MedicamentoFormFields extends StatelessWidget {
  final String nomeMedicamento;
  final String dosagem;
  final String frequencia;
  final String duracao;
  final DateTime inicioTratamento;
  final DateTime fimTratamento;
  final String? observacoes;
  final Function(String) onNomeMedicamentoChanged;
  final Function(String) onDosagemChanged;
  final Function(String) onFrequenciaChanged;
  final Function(String) onDuracaoChanged;
  final Function(DateTime) onInicioTratamentoChanged;
  final Function(DateTime) onFimTratamentoChanged;
  final Function(String?) onObservacoesChanged;
  final String? Function(String?)? frequenciaValidator;

  const MedicamentoFormFields({
    super.key,
    required this.nomeMedicamento,
    required this.dosagem,
    required this.frequencia,
    required this.duracao,
    required this.inicioTratamento,
    required this.fimTratamento,
    this.observacoes,
    required this.onNomeMedicamentoChanged,
    required this.onDosagemChanged,
    required this.onFrequenciaChanged,
    required this.onDuracaoChanged,
    required this.onInicioTratamentoChanged,
    required this.onFimTratamentoChanged,
    required this.onObservacoesChanged,
    this.frequenciaValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldWidget(
          label: 'Nome do Medicamento',
          hint: 'Digite o nome do medicamento',
          initialValue: nomeMedicamento,
          maxLength: 80,
          textCapitalization: TextCapitalization.sentences,
          onSaved: (value) => onNomeMedicamentoChanged(value ?? ''),
        ),
        const SizedBox(height: 16),
        TextFieldWidget(
          label: 'Dosagem',
          hint: 'Ex: 1 comprimido, 10ml, etc.',
          initialValue: dosagem,
          maxLength: 50,
          textCapitalization: TextCapitalization.sentences,
          onSaved: (value) => onDosagemChanged(value ?? ''),
        ),
        const SizedBox(height: 16),
        TextFieldWidget(
          label: 'Frequência',
          hint: 'Ex: 2 vezes ao dia, a cada 8 horas, etc.',
          initialValue: frequencia,
          maxLength: 50,
          textCapitalization: TextCapitalization.sentences,
          validator: frequenciaValidator,
          onSaved: (value) => onFrequenciaChanged(value ?? ''),
        ),
        const SizedBox(height: 16),
        TextFieldWidget(
          label: 'Duração',
          hint: 'Ex: 7 dias, 2 semanas, etc.',
          initialValue: duracao,
          maxLength: 50,
          textCapitalization: TextCapitalization.sentences,
          onSaved: (value) => onDuracaoChanged(value ?? ''),
        ),
        const SizedBox(height: 16),
        DateFieldWidget(
          label: 'Início do Tratamento',
          initialDate: inicioTratamento,
          onDateSelected: onInicioTratamentoChanged,
        ),
        const SizedBox(height: 16),
        DateFieldWidget(
          label: 'Fim do Tratamento',
          initialDate: fimTratamento,
          firstDate: inicioTratamento,
          onDateSelected: onFimTratamentoChanged,
        ),
        const SizedBox(height: 16),
        ObservationFieldWidget(
          label: 'Observações',
          hint: 'Observações adicionais sobre o medicamento',
          initialValue: observacoes,
          onSaved: onObservacoesChanged,
          isRequired: false,
        ),
      ],
    );
  }
}
