// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/dosagem_medicamentos_controller.dart';

class ResultCardWidget extends StatelessWidget {
  final DosagemMedicamentosController controller;

  const ResultCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                controller.model.resultado == null
                    ? 'Aguardando cálculo...'
                    : 'Volume a administrar: ${controller.model.resultado!.toStringAsFixed(2)} ${controller.model.unidadeResultado}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              if (controller.model.resultado != null &&
                  controller.model.resultado! < 0.1)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'ATENÇÃO: O volume calculado é muito pequeno. Considere diluir o medicamento ou consultar um veterinário para métodos de administração adequados.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
