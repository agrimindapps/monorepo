import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/deficit_superavit_calculator.dart';

/// Página da calculadora de déficit/superávit calórico
class DeficitSuperavitCalculatorPage extends StatefulWidget {
  const DeficitSuperavitCalculatorPage({super.key});

  @override
  State<DeficitSuperavitCalculatorPage> createState() =>
      _DeficitSuperavitCalculatorPageState();
}

class _DeficitSuperavitCalculatorPageState
    extends State<DeficitSuperavitCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _weeksController = TextEditingController();
  final _tdeeController = TextEditingController();

  CaloricBalanceResult? _result;

  @override
  void dispose() {
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _weeksController.dispose();
    _tdeeController.dispose();
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
                                Icons.show_chart,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Planejamento de Calorias',
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
                            'Calcula quantas calorias você deve consumir diariamente '
                            'para atingir seu peso meta no prazo desejado. Baseado em '
                            '1kg de gordura ≈ 7700 kcal.',
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

                            // Inputs Row 1
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Peso atual',
                                    controller: _currentWeightController,
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
                                ),
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Peso meta',
                                    controller: _targetWeightController,
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
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Inputs Row 2
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Prazo',
                                    controller: _weeksController,
                                    suffix: 'semanas',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      final num = int.tryParse(value);
                                      if (num == null || num <= 0 || num > 104) {
                                        return 'Valor inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'TDEE',
                                    controller: _tdeeController,
                                    suffix: 'kcal/dia',
                                    helperText: 'Gasto energético total diário',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      final num = int.tryParse(value);
                                      if (num == null ||
                                          num < 1000 ||
                                          num > 5000) {
                                        return 'Valor inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // TDEE info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Não sabe seu TDEE? Use a calculadora de TMB primeiro!',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Calorias',
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
                    _CaloricBalanceResultCard(result: _result!),
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

    final result = DeficitSuperavitCalculator.calculate(
      currentWeightKg: double.parse(_currentWeightController.text),
      targetWeightKg: double.parse(_targetWeightController.text),
      weeks: int.parse(_weeksController.text),
      tdee: double.parse(_tdeeController.text),
    );

    setState(() => _result = result);
  }
}

class _CaloricBalanceResultCard extends StatelessWidget {
  final CaloricBalanceResult result;

  const _CaloricBalanceResultCard({required this.result});

  Color _getGoalColor(WeightGoal goal) {
    return switch (goal) {
      WeightGoal.loss => Colors.blue,
      WeightGoal.maintenance => Colors.green,
      WeightGoal.gain => Colors.orange,
    };
  }

  IconData _getGoalIcon(WeightGoal goal) {
    return switch (goal) {
      WeightGoal.loss => Icons.trending_down,
      WeightGoal.maintenance => Icons.horizontal_rule,
      WeightGoal.gain => Icons.trending_up,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalColor = _getGoalColor(result.goal);

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
                  text: ShareFormatter.formatGeneric(
                    title: 'Déficit/Superávit Calórico',
                    data: {
                      '🎯 Objetivo': result.goalText,
                      '🍽️ Calorias diárias':
                          '${result.dailyCalories.toStringAsFixed(0)} kcal',
                      '📊 ${result.goal == WeightGoal.loss ? "Déficit" : "Superávit"}':
                          '${result.dailyChange.toStringAsFixed(0)} kcal/dia',
                      '⚖️ Mudança semanal':
                          '${result.weeklyWeightChange}kg/semana',
                      '✅ Status': result.isHealthy ? 'Saudável' : 'Ajustar',
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily calories
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: goalColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goalColor, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getGoalIcon(result.goal),
                      size: 48,
                      color: goalColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.dailyCalories.toStringAsFixed(0)}',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: goalColor,
                              ),
                    ),
                    Text(
                      'kcal por dia',
                      style: TextStyle(
                        color: goalColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Goal chip
            Center(
              child: Chip(
                label: Text(
                  result.goalText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: goalColor,
              ),
            ),

            const SizedBox(height: 16),

            // Summary stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoColumn(
                        icon: result.goal == WeightGoal.loss
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        label: result.goal == WeightGoal.loss
                            ? 'Déficit'
                            : 'Superávit',
                        value: '${result.dailyChange.toStringAsFixed(0)} kcal',
                      ),
                      _InfoColumn(
                        icon: Icons.calendar_today,
                        label: 'Por semana',
                        value: '${result.weeklyWeightChange}kg',
                      ),
                      _InfoColumn(
                        icon: result.isHealthy
                            ? Icons.check_circle
                            : Icons.warning,
                        label: 'Status',
                        value: result.isHealthy ? 'Saudável' : 'Revisar',
                        valueColor: result.isHealthy ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning/status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.isHealthy
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.isHealthy ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.isHealthy ? Icons.check_circle : Icons.warning,
                    color: result.isHealthy ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.warning,
                      style: TextStyle(
                        color: result.isHealthy
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.recommendation,
                      style: TextStyle(color: colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Macros tip
            if (result.goal != WeightGoal.maintenance)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dicas importantes:',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (result.goal == WeightGoal.loss) ...[
                      const Text('• Alta proteína preserva massa muscular'),
                      const Text('• Treine força 3-4x por semana'),
                      const Text('• Reavalie a cada 2-4 semanas'),
                    ] else ...[
                      const Text('• Combine com treino de força intenso'),
                      const Text('• Proteína: 1.6-2.2g por kg de peso'),
                      const Text('• Ganho lento = mais músculo, menos gordura'),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
