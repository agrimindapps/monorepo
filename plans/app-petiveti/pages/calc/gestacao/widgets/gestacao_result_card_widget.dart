// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/gestacao_controller.dart';

class GestacaoResultCardWidget extends StatelessWidget {
  final GestacaoController controller;

  const GestacaoResultCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
              controller.model.resultado ??
                  'Preencha os campos acima para calcular.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (controller.model.calculado) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recomendações importantes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Acompanhamento veterinário regular é essencial durante toda a gestação.\n'
                        '• Mantenha a alimentação adequada para gestantes conforme orientação veterinária.\n'
                        '• Prepare um local tranquilo, limpo e aquecido para o parto várias semanas antes da data prevista.\n'
                        '• Tenha o contato do seu veterinário facilmente acessível em caso de emergência.',
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: controller.compartilharResultado,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar Resultado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
