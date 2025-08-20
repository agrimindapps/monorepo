// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/peso_ideal_controller.dart';

/// Componente que exibe a escala de condição corporal
class PesoIdealECCCard extends StatelessWidget {
  final PesoIdealController controller;

  const PesoIdealECCCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escala de Condição Corporal (ECC)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (controller.model.escalaECCSelecionada != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ECC ${controller.model.escalaECCSelecionada!.toInt()}/9: ${controller.model.descricaoECC[controller.model.escalaECCSelecionada]?['titulo'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(controller.model.descricaoECC[controller
                              .model.escalaECCSelecionada]?['descricao'] ??
                          ''),
                    ],
                  ),
                )
              else
                const Text(
                  'Selecione uma condição corporal acima para ver a descrição detalhada.',
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              const Text(
                'Referências:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('- ECC 1-3: Animal abaixo do peso ideal'),
              const Text('- ECC 4-5: Peso ideal'),
              const Text('- ECC 6-7: Sobrepeso'),
              const Text('- ECC 8-9: Obesidade'),
            ],
          ),
        ),
      ),
    );
  }
}
