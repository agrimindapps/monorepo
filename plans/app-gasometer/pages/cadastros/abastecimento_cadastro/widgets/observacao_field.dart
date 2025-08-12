// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../controller/abastecimento_form_controller.dart';

class ObservacaoField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const ObservacaoField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const ValueKey('observacao_field'),
      controller: controller.observacaoController,
      maxLines: 3,
      decoration: ShadcnStyle.inputDecoration(
        label: 'Observações (opcional)',
        hint: 'Informações adicionais sobre o abastecimento...',
      ),
      onChanged: (value) {
        controller.updateObservacao(value);
      },
      onSaved: (value) {
        controller.updateObservacao(value ?? '');
      },
    );
  }
}
