import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/ideal_weight_calculator.dart';

/// Página da calculadora de Peso Ideal
class IdealWeightCalculatorPage extends StatefulWidget {
  const IdealWeightCalculatorPage({super.key});

  @override
  State<IdealWeightCalculatorPage> createState() =>
      _IdealWeightCalculatorPageState();
}

class _IdealWeightCalculatorPageState extends State<IdealWeightCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();

  bool _isMale = true;
  IdealWeightResult? _result;

  @override
  void dispose() {
    _heightController.dispose();
    _currentWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Peso Ideal',
      subtitle: 'Calculadora de Peso Ideal',
      icon: Icons.accessibility_new,
      accentColor: CalculatorAccentColors.health,
      categoryName: 'Saúde',
      instructions: 'Selecione seu gênero e digite sua altura. Opcionalmente, '
          'informe seu peso atual para comparação. A calculadora utiliza 4 fórmulas '
          'científicas (Devine, Robinson, Miller, Hamwi) para maior precisão.',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              ShareButton(
                text: ShareFormatter.formatIdealWeightCalculation(
                  averageWeight: _result!.averageWeight,
                  minRange: _result!.minRange,
                  maxRange: _result!.maxRange,
                  devineWeight: _result!.devineWeight,
                  robinsonWeight: _result!.robinsonWeight,
                  millerWeight: _result!.millerWeight,
                  hamwiWeight: _result!.hamwiWeight,
                ),
              );
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
              // Gender selection
              Text(
                'Selecione o gênero',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      label: 'Masculino',
                      icon: Icons.male,
                      isSelected: _isMale,
                      onTap: () => setState(() => _isMale = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderButton(
                      label: 'Feminino',
                      icon: Icons.female,
                      isSelected: !_isMale,
                      onTap: () => setState(() => _isMale = false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Input fields
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
                      label: 'Altura',
                      controller: _heightController,
                      suffix: 'cm',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 100 || num > 250) {
                          return 'Entre 100 e 250 cm';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'Peso atual (opcional)',
                      controller: _currentWeightController,
                      suffix: 'kg',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                  ),
                ],
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
                _IdealWeightResultCard(result: _result!),
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

    double? currentWeight;
    if (_currentWeightController.text.isNotEmpty) {
      currentWeight = double.tryParse(_currentWeightController.text);
    }

    final result = IdealWeightCalculator.calculate(
      heightCm: double.parse(_heightController.text),
      isMale: _isMale,
      currentWeightKg: currentWeight,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _heightController.clear();
    _currentWeightController.clear();
    setState(() {
      _isMale = true;
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

class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdealWeightResultCard extends StatelessWidget {
  final IdealWeightResult result;

  const _IdealWeightResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main result
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Colors.green,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.averageWeight} kg',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Text(
                  'Peso Ideal (média)',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Faixa: ${result.minRange} - ${result.maxRange} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Difference from current
          if (result.differenceText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getDifferenceColor(result.differenceFromCurrent)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDifferenceColor(result.differenceFromCurrent)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDifferenceIcon(result.differenceFromCurrent),
                    color: _getDifferenceColor(result.differenceFromCurrent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    result.differenceText!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getDifferenceColor(result.differenceFromCurrent),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Formula comparison
          Text(
            'Comparação de fórmulas',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _FormulaRow(
            name: 'Devine',
            value: result.devineWeight,
            description: 'Mais usada clinicamente',
          ),
          _FormulaRow(
            name: 'Robinson',
            value: result.robinsonWeight,
            description: 'Baseada em mortalidade',
          ),
          _FormulaRow(
            name: 'Miller',
            value: result.millerWeight,
            description: 'Atualização de Devine',
          ),
          _FormulaRow(
            name: 'Hamwi',
            value: result.hamwiWeight,
            description: 'Fórmula original',
          ),

          const SizedBox(height: 16),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O peso ideal é uma estimativa. Fatores como composição '
                    'corporal, idade e condições de saúde também são importantes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
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

  Color _getDifferenceColor(double? difference) {
    if (difference == null || difference.abs() < 1) {
      return Colors.green;
    }
    return Colors.orange;
  }

  IconData _getDifferenceIcon(double? difference) {
    if (difference == null || difference.abs() < 1) {
      return Icons.check_circle;
    }
    if (difference > 0) {
      return Icons.arrow_upward;
    }
    return Icons.arrow_downward;
  }
}

class _FormulaRow extends StatelessWidget {
  final String name;
  final double value;
  final String description;

  const _FormulaRow({
    required this.name,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: CalculatorAccentColors.health.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value kg',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: CalculatorAccentColors.health,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
