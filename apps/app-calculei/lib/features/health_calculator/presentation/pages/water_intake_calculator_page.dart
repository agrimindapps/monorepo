import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/water_intake_calculator.dart';

/// Página da calculadora de Necessidade Hídrica
class WaterIntakeCalculatorPage extends StatefulWidget {
  const WaterIntakeCalculatorPage({super.key});

  @override
  State<WaterIntakeCalculatorPage> createState() =>
      _WaterIntakeCalculatorPageState();
}

class _WaterIntakeCalculatorPageState extends State<WaterIntakeCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  WaterActivityLevel _activityLevel = WaterActivityLevel.sedentary;
  ClimateType _climate = ClimateType.temperate;
  WaterIntakeResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CalculatorAppBar(
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
                              Text(
                                'Hidratação adequada',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A quantidade ideal de água varia conforme seu peso, '
                            'nível de atividade física e clima. A fórmula base é '
                            '35ml por kg de peso corporal.',
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
                              'Seus dados',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Weight input
                            StandardInputField(
                              label: 'Peso',
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
                                if (num == null || num <= 0 || num > 500) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Activity Level
                            Text(
                              'Nível de atividade física',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: WaterActivityLevel.values.map((level) {
                                final isSelected = _activityLevel == level;
                                return ChoiceChip(
                                  label: Text(
                                    WaterIntakeCalculator.getActivityDescription(
                                        level),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      setState(() => _activityLevel = level),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Climate
                            Text(
                              'Clima',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ClimateType.values.map((climate) {
                                final isSelected = _climate == climate;
                                return ChoiceChip(
                                  label: Text(
                                    WaterIntakeCalculator.getClimateDescription(
                                        climate),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      setState(() => _climate = climate),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular',
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
                  if (_result != null) _WaterResultCard(result: _result!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = WaterIntakeCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      activityLevel: _activityLevel,
      climate: _climate,
    );

    setState(() => _result = result);
  }
}

class _WaterResultCard extends StatelessWidget {
  final WaterIntakeResult result;

  const _WaterResultCard({required this.result});

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
                  text: ShareFormatter.formatWaterIntakeCalculation(
                    baseLiters: result.baseLiters,
                    adjustedLiters: result.adjustedLiters,
                    glasses: result.glassesOf250ml,
                    bottles: result.bottlesOf500ml,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.adjustedLiters.toStringAsFixed(1)}L',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'por dia',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details
            Row(
              children: [
                Expanded(
                  child: _WaterDetailCard(
                    icon: Icons.local_drink,
                    value: '${result.glassesOf250ml}',
                    label: 'copos de 250ml',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WaterDetailCard(
                    icon: Icons.sports_bar,
                    value: '${result.bottlesOf500ml}',
                    label: 'garrafas de 500ml',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Base vs Adjusted
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Base',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${result.baseLiters}L',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: colorScheme.primary,
                  ),
                  Column(
                    children: [
                      Text(
                        'Ajustado',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${result.adjustedLiters}L',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            Text(
              'Dicas de hidratação',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...WaterIntakeCalculator.getHydrationTips().map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 13),
                      ),
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

class _WaterDetailCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WaterDetailCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.withValues(alpha: 0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
