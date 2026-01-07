import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/macronutrients_calculator.dart';

/// Página da calculadora de Macronutrientes
class MacronutrientsCalculatorPage extends StatefulWidget {
  const MacronutrientsCalculatorPage({super.key});

  @override
  State<MacronutrientsCalculatorPage> createState() =>
      _MacronutrientsCalculatorPageState();
}

class _MacronutrientsCalculatorPageState
    extends State<MacronutrientsCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();

  DietGoal _selectedGoal = DietGoal.maintenance;
  MacronutrientsResult? _result;

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Macronutrientes'),
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
                                Icons.pie_chart_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Distribuição de Macros',
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
                            'Calcula a distribuição ideal de carboidratos, proteínas '
                            'e gorduras baseado nas suas calorias diárias e objetivo.',
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
                              'Calorias diárias',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use a calculadora de TMB para descobrir suas calorias',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),

                            StandardInputField(
                              label: 'Calorias',
                              controller: _caloriesController,
                              suffix: 'kcal',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                }
                                final num = int.tryParse(value);
                                if (num == null || num < 500 || num > 10000) {
                                  return 'Entre 500 e 10000 kcal';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Seu objetivo',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            
                            ...DietGoal.values.map((goal) {
                              final isSelected = _selectedGoal == goal;
                              final distribution =
                                  MacronutrientsCalculator.defaultDistributions[goal]!;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _GoalOption(
                                  goal: goal,
                                  isSelected: isSelected,
                                  distribution: distribution,
                                  onTap: () =>
                                      setState(() => _selectedGoal = goal),
                                ),
                              );
                            }),

                            const SizedBox(height: 16),

                            CalculatorButton(
                              label: 'Calcular Macros',
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
                  if (_result != null) _MacroResultCard(result: _result!),
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

    final result = MacronutrientsCalculator.calculate(
      dailyCalories: double.parse(_caloriesController.text),
      goal: _selectedGoal,
    );

    setState(() => _result = result);
  }
}

class _GoalOption extends StatelessWidget {
  final DietGoal goal;
  final bool isSelected;
  final MacroDistribution distribution;
  final VoidCallback onTap;

  const _GoalOption({
    required this.goal,
    required this.isSelected,
    required this.distribution,
    required this.onTap,
  });

  IconData _getGoalIcon() {
    return switch (goal) {
      DietGoal.maintenance => Icons.balance,
      DietGoal.weightLoss => Icons.trending_down,
      DietGoal.weightGain => Icons.trending_up,
      DietGoal.muscleGain => Icons.fitness_center,
      DietGoal.lowCarb => Icons.no_food,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getGoalIcon(),
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MacronutrientsCalculator.getGoalDescription(goal),
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'C: ${distribution.carbsPercent}% | P: ${distribution.proteinPercent}% | G: ${distribution.fatPercent}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroResultCard extends StatelessWidget {
  final MacronutrientsResult result;

  const _MacroResultCard({required this.result});

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
                  'Sua distribuição',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatMacronutrientsCalculation(
                    totalCalories: result.totalCalories,
                    carbsGrams: result.carbsGrams,
                    carbsPercent: result.carbsPercent,
                    proteinGrams: result.proteinGrams,
                    proteinPercent: result.proteinPercent,
                    fatGrams: result.fatGrams,
                    fatPercent: result.fatPercent,
                    goal: MacronutrientsCalculator.getGoalDescription(result.goal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Total calories
            Center(
              child: Column(
                children: [
                  Text(
                    '${result.totalCalories.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  Text(
                    'kcal/dia',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Macro bars
            _MacroBar(
              label: 'Carboidratos',
              grams: result.carbsGrams,
              calories: result.carbsCalories,
              percent: result.carbsPercent,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _MacroBar(
              label: 'Proteínas',
              grams: result.proteinGrams,
              calories: result.proteinCalories,
              percent: result.proteinPercent,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _MacroBar(
              label: 'Gorduras',
              grams: result.fatGrams,
              calories: result.fatCalories,
              percent: result.fatPercent,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            // Pie chart visualization
            _MacroPieChart(result: result),

            const SizedBox(height: 16),

            // Tips
            Text(
              'Dicas para ${MacronutrientsCalculator.getGoalDescription(result.goal)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...MacronutrientsCalculator.getTipsForGoal(result.goal).map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: colorScheme.primary,
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

class _MacroBar extends StatelessWidget {
  final String label;
  final double grams;
  final double calories;
  final int percent;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.grams,
    required this.calories,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${grams.toStringAsFixed(0)}g (${calories.toStringAsFixed(0)} kcal)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroPieChart extends StatelessWidget {
  final MacronutrientsResult result;

  const _MacroPieChart({required this.result});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _PieChartPainter(
              carbsPercent: result.carbsPercent,
              proteinPercent: result.proteinPercent,
              fatPercent: result.fatPercent,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegendItem(color: Colors.amber, label: 'Carbs'),
            const SizedBox(height: 8),
            _LegendItem(color: Colors.red, label: 'Proteínas'),
            const SizedBox(height: 8),
            _LegendItem(color: Colors.blue, label: 'Gorduras'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final int carbsPercent;
  final int proteinPercent;
  final int fatPercent;

  _PieChartPainter({
    required this.carbsPercent,
    required this.proteinPercent,
    required this.fatPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()..style = PaintingStyle.fill;
    
    double startAngle = -1.5708; // -90 degrees in radians
    
    // Carbs
    paint.color = Colors.amber;
    final carbsSweep = (carbsPercent / 100) * 6.2832; // 2*pi
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      carbsSweep,
      true,
      paint,
    );
    startAngle += carbsSweep;
    
    // Protein
    paint.color = Colors.red;
    final proteinSweep = (proteinPercent / 100) * 6.2832;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinSweep,
      true,
      paint,
    );
    startAngle += proteinSweep;
    
    // Fat
    paint.color = Colors.blue;
    final fatSweep = (fatPercent / 100) * 6.2832;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fatSweep,
      true,
      paint,
    );
    
    // Inner circle (donut effect)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
