// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/necessidades_caloricas_model.dart';

class ResultCardWidget extends StatelessWidget {
  final NecessidadesCaloricas? resultado;

  const ResultCardWidget({
    super.key,
    this.resultado,
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
                resultado == null
                    ? 'Aguardando cálculo...'
                    : 'Necessidade calórica diária: ${resultado!.resultado.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              if (resultado != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    resultado!.recomendacao,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
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
