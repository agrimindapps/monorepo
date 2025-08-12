// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import './combustivel_dropdown_field.dart';
import './generic_form_fields.dart';
import './litros_field.dart';
import './preco_por_litro_field.dart';
import './tanque_cheio_field.dart';
import './valor_total_field.dart';

class ValoresSectionWidget extends StatelessWidget {
  final AbastecimentoFormController controller;

  const ValoresSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Valores',
      icon: Icons.attach_money,
      child: Column(
        children: [
          const SizedBox(height: 4),
          CombustivelDropdownField(controller: controller),
          const SizedBox(height: 8),
          LitrosField(controller: controller),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: PrecoPorLitroField(controller: controller)),
              const SizedBox(width: 8),
              Expanded(child: ValorTotalField(controller: controller)),
            ],
          ),
          const SizedBox(height: 8),
          TanqueCheioField(controller: controller),
        ],
      ),
    );
  }
}
