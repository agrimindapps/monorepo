// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import './date_time_field.dart';
import './generic_form_fields.dart';
import './odometro_field.dart';

class InfoSectionWidget extends StatelessWidget {
  final AbastecimentoFormController controller;

  const InfoSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Informações Básicas',
      icon: Icons.info,
      child: Column(
        children: [
          const SizedBox(height: 4),
          OdometroField(controller: controller),
          const SizedBox(height: 8),
          DateTimeField(controller: controller),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
