// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/gestacao_parto_controller.dart';

class InfoCardWidget extends StatelessWidget {
  final GestacaoPartoController controller;

  const InfoCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calculadora de Gestação e Parto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.toggleInfoCard,
                    tooltip: 'Fechar',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta calculadora estima a data provável do parto e as diferentes fases da gestação com base na data do acasalamento ou em medidas de ultrassom. '
                'A gestação varia conforme a espécie e, em alguns casos, a raça. Os resultados são estimativas e podem variar em casos individuais.\n\n'
                'Você pode calcular usando a data de acasalamento/cobertura ou através de medidas de ultrassonografia para cães e gatos.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
