// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import '../services/formatting_service.dart';
import 'generic_form_fields.dart';

class LitrosField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const LitrosField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GenericNumericField(
      fieldKey: const ValueKey('litros_field'),
      textController: controller.litrosController,
      label: 'Litros',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}[,.]?\d{0,3}')),
        FormattingService().litrosFormatter,
      ],
      validator: controller.validateLitros,
      onChanged: (value) {
        if (value.isNotEmpty) {
          final cleanValue = value.replaceAll(',', '.');
          controller.updateLitros(double.tryParse(cleanValue) ?? 0.0);
        } else {
          controller.updateLitros(0.0);
        }
      },
      onSaved: (value) {
        if (value?.isNotEmpty ?? false) {
          final cleanValue = value!.replaceAll(',', '.');
          controller.updateLitros(double.parse(cleanValue));
        }
      },
      suffixIcon: Obx(() {
        return controller.formModel.litros > 0
            ? IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.clear),
                onPressed: controller.clearLitros,
              )
            : const SizedBox.shrink();
      }),
    );
  }
}
