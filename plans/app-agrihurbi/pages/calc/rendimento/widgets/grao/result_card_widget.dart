// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/grao_controller.dart';

class GraoResultCardWidget extends StatelessWidget {
  const GraoResultCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<GraoController>(
          builder: (controller) {
            if (controller.resultado == null) {
              return const Center(
                child: Text(
                  'Preencha todos os campos para ver o resultado',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Resultado do Cálculo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildResultRow(
                  'Rendimento em kg/ha:',
                  '${controller.resultado!.toStringAsFixed(2)} kg/ha',
                ),
                const SizedBox(height: 8),
                _buildResultRow(
                  'Rendimento em sacas/ha:',
                  '${controller.sacasPorHa.toStringAsFixed(2)} sc/ha',
                ),
                const SizedBox(height: 8),
                _buildResultRow(
                  'Classificação:',
                  controller.classificacao,
                  isHighlighted: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.blue : null,
          ),
        ),
      ],
    );
  }
}
