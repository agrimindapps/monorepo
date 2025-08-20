// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/peso_ideal_controller.dart';
import '../utils/peso_ideal_utils.dart';

/// Componente que exibe os resultados do cálculo de peso ideal
class PesoIdealResultCard extends StatelessWidget {
  final PesoIdealController controller;

  const PesoIdealResultCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final model = controller.model;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (model.pesoIdeal != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.lightBlue.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildResultRow('Peso atual:',
                              '${model.pesoAtual!.toStringAsFixed(1)} kg'),
                          _buildResultRow(
                            'Peso ideal estimado:',
                            '${model.pesoIdeal!.toStringAsFixed(1)} kg',
                            emphasize: true,
                          ),
                          _buildResultRow(
                            'Diferença de peso:',
                            '${model.diferencaPeso!.toStringAsFixed(1)} kg',
                            textColor: model.diferencaPeso! < -0.1
                                ? Colors.red
                                : (model.diferencaPeso! > 0.1
                                    ? Colors.orange
                                    : Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Necessidades calóricas
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.lightGreen.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Necessidades Calóricas Estimadas:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${model.kcalAjustadas!.toStringAsFixed(0)} kcal/dia',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (model.diferencaPeso!.abs() > 0.1)
                            Text(
                              'Tempo estimado para atingir o peso ideal: '
                              '${model.tempoEstimadoSemanas} semanas',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recomendações
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.orange.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recomendações:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(PesoIdealUtils.gerarRecomendacoes(model)),
                          const SizedBox(height: 8),
                          const Text(
                            'Nota: Estas são apenas estimativas. Consulte sempre um veterinário para um plano individualizado.',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Preencha os campos acima para calcular o peso ideal.',
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool emphasize = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              fontSize: emphasize ? 16 : 14,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.bold : FontWeight.normal,
              fontSize: emphasize ? 16 : 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
