import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
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
    return CalculatorPageLayout(
      title: 'Déficit/Superávit Calórico',
      subtitle: 'Planejamento de Calorias',
      icon: Icons.trending_down,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 700,
      actions: [
        if (_result != null)
          ShareButton(
            text: ShareFormatter.formatGeneric(
              title: 'Déficit/Superávit Calórico',
              data: {
                '🎯 Objetivo': _result!.goalText,
                '🍽️ Calorias diárias':
                    '${_result!.dailyCalories.toStringAsFixed(0)} kcal',
                '📊 ${_result!.goal == WeightGoal.loss ? "Déficit" : "Superávit"}':
                    '${_result!.dailyChange.toStringAsFixed(0)} kcal/dia',
                '⚖️ Mudança semanal':
                    '${_result!.weeklyWeightChange}kg/semana',
                '✅ Status': _result!.isHealthy ? 'Saudável' : 'Ajustar',
              },
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Inputs Row 1
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
                      label: 'Peso atual',
                      controller: _currentWeightController,
                      suffix: 'kg',
                      keyboardType: const TextInputType.numberWithOptions(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'Peso meta',
                      controller: _targetWeightController,
                      suffix: 'kg',
                      keyboardType: const TextInputType.numberWithOptions(
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
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'TDEE',
                      controller: _tdeeController,
                      suffix: 'kcal/dia',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 1000 || num > 5000) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // TDEE info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Não sabe seu TDEE? Use a calculadora de TMB primeiro!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
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
                _CaloricBalanceResultCard(result: _result!),
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

    final result = DeficitSuperavitCalculator.calculate(
      currentWeightKg: double.parse(_currentWeightController.text),
      targetWeightKg: double.parse(_targetWeightController.text),
      weeks: int.parse(_weeksController.text),
      tdee: double.parse(_tdeeController.text),
    );

    setState(() => _result = result);
  }

  void _clear() {
    _currentWeightController.clear();
    _targetWeightController.clear();
    _weeksController.clear();
    _tdeeController.clear();
    setState(() {
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
    final goalColor = _getGoalColor(result.goal);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goalColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Daily calories
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                  result.dailyCalories.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: goalColor,
                  ),
                ),
                Text(
                  'kcal por dia',
                  style: TextStyle(
                    color: goalColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Goal chip
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: goalColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result.goalText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary stats
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
          ),

          const SizedBox(height: 16),

          // Warning/status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.isHealthy
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
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
                      color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
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

          const SizedBox(height: 16),

          // Macros tip
          if (result.goal != WeightGoal.maintenance)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dicas importantes:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (result.goal == WeightGoal.loss) ...[
                    Text(
                      '• Alta proteína preserva massa muscular',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '• Treine força 3-4x por semana',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '• Reavalie a cada 2-4 semanas',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '• Combine com treino de força intenso',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '• Proteína: 1.6-2.2g por kg de peso',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '• Ganho lento = mais músculo, menos gordura',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
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
        Icon(
          icon,
          size: 20,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
