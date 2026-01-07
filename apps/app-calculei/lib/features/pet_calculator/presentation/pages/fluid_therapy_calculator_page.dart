import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/fluid_therapy_calculator.dart';

/// Página da calculadora de Fluidoterapia
class FluidTherapyCalculatorPage extends StatefulWidget {
  const FluidTherapyCalculatorPage({super.key});

  @override
  State<FluidTherapyCalculatorPage> createState() =>
      _FluidTherapyCalculatorPageState();
}

class _FluidTherapyCalculatorPageState
    extends State<FluidTherapyCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _dehydrationController = TextEditingController();

  FluidTherapyResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _dehydrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fluidoterapia'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Card
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'APENAS ORIENTATIVO',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fluidoterapia deve ser prescrita por veterinário. Este cálculo não substitui avaliação profissional.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cálculo de Fluidos',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule volumes de manutenção e reposição para fluidoterapia veterinária.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Dados do paciente',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Weight
                            StandardInputField(
                              label: 'Peso do pet',
                              controller: _weightController,
                              suffix: 'kg',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                }
                                final num = double.tryParse(value);
                                if (num == null || num <= 0 || num > 100) {
                                  return 'Entre 0 e 100 kg';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Dehydration
                            StandardInputField(
                              label: 'Desidratação estimada',
                              controller: _dehydrationController,
                              suffix: '%',
                              hint: '5-12',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                }
                                final num = double.tryParse(value);
                                if (num == null || num < 0 || num > 15) {
                                  return 'Entre 0 e 15%';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 12),

                            // Dehydration guide
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guia de Desidratação:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._buildDehydrationGuide(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Fluidoterapia',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result
                  if (_result != null)
                    _FluidTherapyResultCard(
                      result: _result!,
                      weight: double.parse(_weightController.text),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDehydrationGuide() {
    final guides = [
      '< 5%: Leve - mucosas secas',
      '5-8%: Moderada - turgor reduzido',
      '8-12%: Severa - olhos encovados',
      '> 12%: Crítica - emergência',
    ];

    return guides
        .map((guide) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(guide, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = FluidTherapyCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      dehydrationPercentage: double.parse(_dehydrationController.text),
    );

    setState(() => _result = result);
  }
}

class _FluidTherapyResultCard extends StatelessWidget {
  final FluidTherapyResult result;
  final double weight;

  const _FluidTherapyResultCard({
    required this.result,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: '''
📋 Fluidoterapia - Calculei App

⚖️ Peso: ${weight.toStringAsFixed(1)} kg
💧 Desidratação: ${result.dehydrationPercent.toStringAsFixed(1)}%

📊 Volumes:
• Manutenção: ${result.maintenanceVolumeMl.toStringAsFixed(0)} ml/24h
• Déficit: ${result.deficitVolumeMl.toStringAsFixed(0)} ml
• Total 24h: ${result.totalVolume24h.toStringAsFixed(0)} ml

⏱️ Taxa: ${result.hourlyRateMl.toStringAsFixed(1)} ml/h
💧 Gotas: ${result.dropsPerMinute.toStringAsFixed(0)} gts/min

⚠️ Cálculo orientativo - prescrição veterinária obrigatória

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.totalVolume24h.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' ml',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'volume total 24h',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Manutenção',
                    value: '${result.maintenanceVolumeMl.toStringAsFixed(0)} ml',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Déficit (${result.dehydrationPercent}%)',
                    value: '${result.deficitVolumeMl.toStringAsFixed(0)} ml',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Taxa horária',
                    value: '${result.hourlyRateMl.toStringAsFixed(1)} ml/h',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Gotas/minuto',
                    value: '${result.dropsPerMinute.toStringAsFixed(0)} gts/min',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommendations
            Text(
              'Recomendações',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      rec.startsWith('⚠️') || rec.startsWith('🚨')
                          ? Icons.warning
                          : Icons.check_circle,
                      size: 18,
                      color: rec.startsWith('⚠️') || rec.startsWith('🚨')
                          ? Colors.orange
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(rec, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
