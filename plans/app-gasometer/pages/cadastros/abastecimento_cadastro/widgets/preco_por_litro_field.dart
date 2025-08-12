// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import 'generic_form_fields.dart';

class PrecoPorLitroField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const PrecoPorLitroField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CurrencyInputField(
      textController: controller.valorPorLitroController,
      label: 'Preço por Litro',
      validator: controller.validateValorPorLitro,
      onChanged: (value) {
        if (value.isNotEmpty) {
          final cleanValue = value.replaceAll(',', '.');
          controller.updateValorPorLitro(double.tryParse(cleanValue) ?? 0.0);
        } else {
          controller.updateValorPorLitro(0.0);
        }
      },
      onSaved: (value) {
        if (value?.isNotEmpty ?? false) {
          final cleanValue = value!.replaceAll(',', '.');
          controller.updateValorPorLitro(double.parse(cleanValue));
        }
      },
    );
  }
}
