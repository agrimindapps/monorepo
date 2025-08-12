// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../../core/style/shadcn_style.dart';
import '../../../../database/enums.dart';
import '../controller/abastecimento_form_controller.dart';

class CombustivelDropdownField extends StatelessWidget {
  final AbastecimentoFormController controller;

  const CombustivelDropdownField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<TipoCombustivel>(
          decoration: ShadcnStyle.inputDecoration(
            label: 'Tipo de Combustível',
            prefixIcon: const Icon(Icons.local_gas_station),
          ),
          value: controller.formModel.tipoCombustivel,
          dropdownColor: ShadcnStyle.backgroundColor,
          items: TipoCombustivel.values.map((tipo) {
            return DropdownMenuItem(value: tipo, child: Text(tipo.descricao));
          }).toList(),
          onChanged: (TipoCombustivel? value) {
            if (value != null) {
              controller.updateTipoCombustivel(value);
            }
          },
          validator: controller.validateTipoCombustivel,
        ));
  }
}
