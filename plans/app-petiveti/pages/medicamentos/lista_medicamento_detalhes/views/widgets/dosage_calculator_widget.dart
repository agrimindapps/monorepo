// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/lista_medicamento_detalhes_controller.dart';

class DosageCalculatorWidget extends StatelessWidget {
  final ListaMedicamentoDetalhesController controller;
  final double textScaleFactor;

  const DosageCalculatorWidget({
    super.key,
    required this.controller,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculadora de Dosagem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.pesoController,
                    decoration: const InputDecoration(
                      labelText: 'Peso do animal (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: controller.calcularDosagem,
                  child: const Text('Calcular'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.resultadoDosagem.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Text(
                  controller.resultadoDosagem,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[800],
                  ),
                  textScaler: TextScaler.linear(textScaleFactor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
