// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/fluidoterapia_model.dart';

class ResultCardWidget extends StatelessWidget {
  final FluidoterapiaModel model;

  const ResultCardWidget({
    super.key,
    required this.model,
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
              if (model.volumeTotal != null)
                Column(
                  children: [
                    Text(
                      'Volume total: ${model.volumeTotal!.toStringAsFixed(1)} ml',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taxa de gotejamento (equipo macrogotas): ${model.gotasPorMinuto!.toStringAsFixed(1)} gotas/minuto',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.blue.shade50,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informações importantes:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '• O cálculo assume o uso de um equipo macrogotas (20 gotas/ml)\n'
                            '• Para microgotas (60 gotas/ml), multiplique a taxa de gotejamento por 3\n'
                            '• Monitore os sinais vitais durante a administração de fluidos\n'
                            '• Ajuste a taxa conforme necessário com base na resposta do animal',
                          ),
                        ],
                      ),
                    )
                  ],
                )
              else
                const Text(
                  'Preencha os campos acima para calcular.',
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
