import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
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
    return CalculatorPageLayout(
      title: 'Macronutrientes',
      subtitle: 'Distribuição de Carboidratos, Proteínas e Gorduras',
      icon: Icons.restaurant,
      accentColor: CalculatorAccentColors.health,
      categoryName: 'Saúde',
      instructions: 'Informe suas calorias diárias e objetivo para calcular a distribuição ideal de macronutrientes (carboidratos, proteínas e gorduras).',
      maxContentWidth: 700,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // TODO: Implement share
            },
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calories input
              _DarkInputField(
                label: 'Calorias diárias',
                controller: _caloriesController,
                suffix: 'kcal',
                keyboardType: TextInputType.number,
                hint: 'Ex: 2000',
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

              // Goal selection
              Text(
                'Selecione seu objetivo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                    onTap: () => setState(() => _selectedGoal = goal),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.health,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _MacroResultCard(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = MacronutrientsCalculator.calculate(
      dailyCalories: double.parse(_caloriesController.text),
      goal: _selectedGoal,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _caloriesController.clear();
    setState(() {
      _selectedGoal = DietGoal.maintenance;
      _result = null;
    });
  }
}

/// Dark themed input field
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CalculatorAccentColors.health,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Goal option card with dark theme
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
    const accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                _getGoalIcon(),
                size: 24,
                color: isSelected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.7),
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
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                        color: isSelected
                            ? accentColor
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'C: ${distribution.carbsPercent}% | P: ${distribution.proteinPercent}% | G: ${distribution.fatPercent}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: accentColor,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result card with dark theme
class _MacroResultCard extends StatelessWidget {
  final MacronutrientsResult result;

  const _MacroResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CalculatorAccentColors.health.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.assessment,
                color: CalculatorAccentColors.health,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Distribuição Calculada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total calories
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: CalculatorAccentColors.health.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CalculatorAccentColors.health,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    result.totalCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: CalculatorAccentColors.health,
                    ),
                  ),
                  const Text(
                    'kcal/dia',
                    style: TextStyle(
                      color: CalculatorAccentColors.health,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

          // Pie chart visualization
          _MacroPieChart(result: result),

          const SizedBox(height: 20),

          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: Colors.amber.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dicas para ${MacronutrientsCalculator.getGoalDescription(result.goal)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...MacronutrientsCalculator.getTipsForGoal(result.goal).map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: CalculatorAccentColors.health,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Macro bar indicator with dark theme
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            Text(
              '${grams.toStringAsFixed(0)}g (${calories.toStringAsFixed(0)} kcal)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 26,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percent / 100,
              child: Container(
                height: 26,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(13),
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

/// Pie chart visualization with dark theme
class _MacroPieChart extends StatelessWidget {
  final MacronutrientsResult result;

  const _MacroPieChart({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
          const SizedBox(width: 28),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: Colors.amber, label: 'Carboidratos'),
              SizedBox(height: 10),
              _LegendItem(color: Colors.red, label: 'Proteínas'),
              SizedBox(height: 10),
              _LegendItem(color: Colors.blue, label: 'Gorduras'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Legend item for pie chart
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for pie chart with white center for dark background
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

    var startAngle = -1.5708; // -90 degrees in radians

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

    // Inner circle (donut effect) - dark color for dark background
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
