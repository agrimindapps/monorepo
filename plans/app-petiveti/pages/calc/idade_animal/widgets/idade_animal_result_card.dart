// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/idade_animal_controller.dart';

class IdadeAnimalResultCard extends StatelessWidget {
  final IdadeAnimalController controller;

  const IdadeAnimalResultCard({
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
                controller.model.resultado ??
                    'Preencha os campos acima para calcular.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              if (controller.model.resultado != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: _buildDicasFaseVida(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDicasFaseVida() {
    final dicas = controller.gerarDicasFaseVida();

    if (dicas.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        dicas,
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.left,
      ),
    );
  }
}
