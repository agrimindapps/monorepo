// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/diabetes_insulina_controller.dart';

/// Card de informações sobre diabetes e insulina
class DiabetesInsulinaInfoCard extends StatelessWidget {
  final DiabetesInsulinaController controller;

  const DiabetesInsulinaInfoCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAlertaCard(),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildAlertaCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Card(
        color: Colors.red.shade100,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ALERTA DE SEGURANÇA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Esta calculadora é apenas uma ferramenta de auxílio e NÃO substitui a orientação veterinária. '
                'O tratamento de diabetes em animais requer supervisão profissional constante. '
                'Nunca altere a dosagem de insulina sem consultar um médico veterinário.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Calculadora de Diabetes e Controle de Insulina',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
                'Esta calculadora ajuda a estimar a dosagem de insulina com base no peso do animal, '
                'nível de glicemia e histórico de tratamento. É uma ferramenta de apoio para tutores '
                'de animais diabéticos, sempre sob orientação veterinária.\n\n'
                'Valores normais de referência para glicemia:\n'
                'Cães: 70-120 mg/dL\n'
                'Gatos: 70-150 mg/dL',
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
