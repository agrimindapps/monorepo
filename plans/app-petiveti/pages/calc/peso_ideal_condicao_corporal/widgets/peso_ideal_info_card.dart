// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/peso_ideal_controller.dart';

/// Componente que exibe informações sobre a calculadora de peso ideal
class PesoIdealInfoCard extends StatelessWidget {
  final PesoIdealController controller;

  const PesoIdealInfoCard({
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
                    'Calculadora de Peso Ideal por Condição Corporal',
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
                'Esta calculadora estima o peso ideal do seu animal com base no peso atual e na condição corporal observada. '
                'Ela utiliza a escala de condição corporal (ECC) de 9 pontos, onde 4-5 representa a condição ideal.\n\n'
                'Além do peso ideal, a calculadora também fornece uma estimativa de calorias diárias e tempo necessário para atingir o peso ideal de forma saudável.',
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
