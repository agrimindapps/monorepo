// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class VeterinarioInput extends StatelessWidget {
  final ConsultaFormController controller;

  const VeterinarioInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Veterinário *',
          style: ConsultaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.getFieldError('veterinario') != null;
          final currentValue = controller.model.veterinario;

          return TextFormField(
            initialValue: currentValue,
            decoration: ConsultaFormStyles.getInputDecoration(
              labelText: 'Nome do veterinário',
              hintText: 'Ex: Dr. João Silva',
              hasError: hasError,
            ),
            maxLength: 100,
            onChanged: (String value) {
              controller.updateVeterinario(value);
            },
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veterinário é obrigatório';
              }
              if (value.length > 100) {
                return 'Nome muito longo (máx. 100 caracteres)';
              }
              return null;
            },
            style: ConsultaFormStyles.inputStyle,
            textCapitalization: TextCapitalization.words,
          );
        }),
        Obx(() {
          final error = controller.getFieldError('veterinario');
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
