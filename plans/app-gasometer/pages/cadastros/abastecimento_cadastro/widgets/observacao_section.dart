// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/abastecimento_form_controller.dart';
import './generic_form_fields.dart';
import './observacao_field.dart';

class ObservacaoSectionWidget extends StatelessWidget {
  final AbastecimentoFormController controller;

  const ObservacaoSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Observações',
      icon: Icons.event_note,
      child: Column(children: [ObservacaoField(controller: controller)]),
    );
  }
}
