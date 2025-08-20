// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controller/diabetes_insulina_controller.dart';
import '../utils/diabetes_insulina_utils.dart';

/// Card de resultado para a calculadora de diabetes e insulina
class DiabetesInsulinaResultCard extends StatelessWidget {
  final DiabetesInsulinaController controller;

  const DiabetesInsulinaResultCard({
    super.key,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final glicemia = controller.model.glicemiaController.text.isEmpty
        ? 0
        : int.tryParse(controller.model.glicemiaController.text) ?? 0;

    Color glicemiaColor = Colors.black;
    if (glicemia > 0) {
      glicemiaColor = DiabetesInsulinaUtils.getGlicemiaColor(glicemia);
    }

    final hasResult = controller.model.resultado != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasResult
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hasResult ? Icons.check_circle : Icons.medical_services,
                        color: hasResult ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Resultado da Dosagem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (hasResult)
                      IconButton(
                        onPressed: () => _shareResult(),
                        icon: const Icon(Icons.share),
                        tooltip: 'Compartilhar resultado',
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                if (glicemia > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: glicemiaColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: glicemiaColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bloodtype,
                              color: glicemiaColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Nível de Glicemia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: glicemiaColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$glicemia mg/dL',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: glicemiaColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: glicemiaColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DiabetesInsulinaUtils.getGlicemiaStatus(
                                glicemia, controller.model.especieSelecionada),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: glicemiaColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hasResult) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.1),
                          Colors.green.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.medication,
                              color: Colors.green,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Dose Recomendada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${controller.model.resultado!.toStringAsFixed(1)} unidades',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Dosagem calculada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.model.recomendacao != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Recomendação',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            controller.model.recomendacao!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aguardando cálculo...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Preencha os campos acima e clique em "Calcular"',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareResult() {
    if (controller.model.resultado == null) return;

    final glicemia = controller.model.glicemiaController.text.isEmpty
        ? 0
        : int.tryParse(controller.model.glicemiaController.text) ?? 0;

    final peso = controller.model.pesoController.text;
    final especie = controller.model.especieSelecionada ?? '';
    final tipoInsulina = controller.model.tipoInsulinaSelecionada ?? '';
    final resultado = controller.model.resultado!.toStringAsFixed(1);

    Share.share(
      'Cálculo de Dosagem de Insulina 💉\n\n'
      'Espécie: $especie\n'
      'Peso: $peso kg\n'
      'Glicemia: $glicemia mg/dL\n'
      'Tipo de Insulina: $tipoInsulina\n\n'
      '✅ Dose recomendada: $resultado unidades\n\n'
      '⚠️ Esta dosagem é apenas orientativa.\n'
      'Sempre consulte um veterinário!\n\n'
      '📱 Calculado com fNutriTuti',
      subject: 'Cálculo de Dosagem de Insulina',
    );
  }
}
