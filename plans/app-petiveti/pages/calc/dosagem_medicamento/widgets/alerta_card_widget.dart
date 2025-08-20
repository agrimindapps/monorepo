// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controller/dosagem_medicamentos_controller.dart';

class AlertaCardWidget extends StatelessWidget {
  final DosagemMedicamentosController controller;

  const AlertaCardWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Card(
        color: Colors.red.shade50,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ALERTA DE SEGURANÇA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: controller.toggleAlertaCard,
                    tooltip: 'Fechar alerta',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IMPORTANTE - USO RESTRITO:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Esta calculadora destina-se apenas para referência educacional\n'
                      '• Deve ser usada SOMENTE por médicos veterinários qualificados\n'
                      '• As dosagens sugeridas são apenas guias gerais\n'
                      '• Fatores individuais podem alterar a dose apropriada\n'
                      '• Sempre considere a condição clínica do paciente\n'
                      '• Monitore constantemente a resposta ao tratamento\n'
                      '• Consulte a bula do medicamento para informações específicas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
