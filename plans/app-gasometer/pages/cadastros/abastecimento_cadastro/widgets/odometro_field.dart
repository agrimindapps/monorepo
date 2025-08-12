// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import '../services/formatting_service.dart';
import 'generic_form_fields.dart';

class OdometroField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const OdometroField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GenericNumericField(
      fieldKey: const ValueKey('odometro_field'),
      textController: controller.odometroController,
      label: 'Odometro',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        FormattingService().odometroFormatter,
      ],
      validator: controller.validateOdometro,
      onChanged: (value) {
        if (value.isNotEmpty) {
          final cleanValue = value.replaceAll(',', '.');
          controller.updateOdometro((double.tryParse(cleanValue) ?? 0).round());
        } else {
          controller.updateOdometro(0);
        }
      },
      onSaved: (value) {
        if (value?.isNotEmpty ?? false) {
          final cleanValue = value!.replaceAll(',', '.');
          controller.updateOdometro(double.parse(cleanValue).round());
        }
      },
      suffixIcon: IconButton(
        iconSize: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.clear),
        onPressed: controller.clearOdometro,
      ),
    );
  }
}
