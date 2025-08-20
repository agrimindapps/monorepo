// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/dosagem_anestesicos_controller.dart';

class InfoAnestesicoCard extends StatelessWidget {
  final DosagemAnestesicosController controller;

  const InfoAnestesicoCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.anestesicoSelecionado == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Informações sobre ${controller.anestesicoSelecionado}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Descrição: ${controller.model.descricoes[controller.anestesicoSelecionado]}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Advertências e Contraindicações:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.model
                          .advertencias[controller.anestesicoSelecionado]!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Notas adicionais:\n'
                '• A administração deve ser realizada lentamente e com monitoramento constante.\n'
                '• Tenha sempre medicamentos de reversão e equipamentos de emergência disponíveis.\n'
                '• Realize exames pré-anestésicos para garantir a segurança do procedimento.\n'
                '• Ajuste a dose conforme o estado físico, idade e condições pré-existentes do paciente.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
