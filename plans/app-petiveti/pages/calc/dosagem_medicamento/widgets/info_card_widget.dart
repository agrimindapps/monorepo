// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/dosagem_medicamentos_controller.dart';

class InfoCardWidget extends StatelessWidget {
  final DosagemMedicamentosController controller;

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
                    'Calculadora de Dosagem de Medicamentos',
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
                'Esta calculadora ajuda a determinar a quantidade de medicamento a ser administrada com base no peso do animal, '
                'na dosagem recomendada e na concentração do medicamento.\n\n'
                'Fórmula: Volume (ml) = [Peso (kg) × Dosagem (mg/kg)] ÷ Concentração (mg/ml)',
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
