import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/calculators/calorias_exercicio_calculator.dart';

/// Página da calculadora de calorias por exercício
class CaloriasExercicioCalculatorPage extends StatefulWidget {
  const CaloriasExercicioCalculatorPage({super.key});

  @override
  State<CaloriasExercicioCalculatorPage> createState() =>
      _CaloriasExercicioCalculatorPageState();
}

class _CaloriasExercicioCalculatorPageState
    extends State<CaloriasExercicioCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();

  ExerciseType _exerciseType = ExerciseType.running;
  ExerciseCaloriesResult? _result;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Calorias por Exercício',
      subtitle: 'Gasto Calórico em Atividades Físicas',
      icon: Icons.directions_run,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 600,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exercise type selection
              Text(
                'Selecione o tipo de exercício',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExerciseType.values.map((type) {
                  return _ExerciseTypeChip(
                    type: type,
                    isSelected: _exerciseType == type,
                    onTap: () => setState(() => _exerciseType = type),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Duration input
              _DarkInputField(
                label: 'Duração',
                controller: _durationController,
                suffix: 'minutos',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0 || num > 600) {
                    return 'Valor inválido (1-600 minutos)';
                  }
                  return null;
                },
              ),

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
                _ExerciseCaloriesResultCard(result: _result!),
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

    final result = CaloriasExercicioCalculator.calculate(
      exerciseType: _exerciseType,
      durationMinutes: int.parse(_durationController.text),
    );

    setState(() => _result = result);
  }

  void _clear() {
    _durationController.clear();
    setState(() {
      _exerciseType = ExerciseType.running;
      _result = null;
    });
  }
}

/// Dark themed input field for the calculator
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
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

class _ExerciseTypeChip extends StatelessWidget {
  final ExerciseType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  String _getTypeName(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => '🚶 Caminhada',
      ExerciseType.running => '🏃 Corrida',
      ExerciseType.cycling => '🚴 Ciclismo',
      ExerciseType.swimming => '🏊 Natação',
      ExerciseType.weightTraining => '💪 Musculação',
      ExerciseType.yoga => '🧘 Yoga',
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getTypeName(type),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCaloriesResultCard extends StatelessWidget {
  final ExerciseCaloriesResult result;

  const _ExerciseCaloriesResultCard({required this.result});

  IconData _getExerciseIcon(ExerciseType type) {
    return switch (type) {
      ExerciseType.walking => Icons.directions_walk,
      ExerciseType.running => Icons.directions_run,
      ExerciseType.cycling => Icons.directions_bike,
      ExerciseType.swimming => Icons.pool,
      ExerciseType.weightTraining => Icons.fitness_center,
      ExerciseType.yoga => Icons.self_improvement,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calories burned - main result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  _getExerciseIcon(result.exerciseType),
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                Text(
                  result.calories.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  'kcal queimadas',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Exercise info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoColumn(
                  icon: Icons.fitness_center,
                  label: 'Exercício',
                  value: result.exerciseTypeName,
                ),
                _InfoColumn(
                  icon: Icons.access_time,
                  label: 'Duração',
                  value: '${result.durationMinutes} min',
                ),
                _InfoColumn(
                  icon: Icons.speed,
                  label: 'MET',
                  value: result.metValue.toStringAsFixed(1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.recommendation,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Info note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Valores são estimativas médias. O gasto real varia com peso, intensidade e condicionamento.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
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

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
