// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class ObservacoesInput extends StatelessWidget {
  final ConsultaFormController controller;

  const ObservacoesInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observações',
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.getFieldError('observacoes') != null;
          final currentValue = controller.model.observacoes ?? '';

          return TextFormField(
            initialValue: currentValue,
            decoration: ConsultaFormStyles.getInputDecoration(
              labelText: 'Observações adicionais',
              hintText: 'Informações complementares, recomendações...',
              hasError: hasError,
            ),
            maxLength: 1000,
            maxLines: 5,
            minLines: 2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1000),
            ],
            onChanged: (String value) {
              controller.updateObservacoes(value);
            },
            validator: (String? value) {
              if (value != null && value.length > 1000) {
                return 'Observações muito longas (máx. 1000 caracteres)';
              }
              return null;
            },
            style: ConsultaFormStyles.inputStyle,
            textCapitalization: TextCapitalization.sentences,
          );
        }),
        Obx(() {
          final error = controller.getFieldError('observacoes');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: ConsultaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
