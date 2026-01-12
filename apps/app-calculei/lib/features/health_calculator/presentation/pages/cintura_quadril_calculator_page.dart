import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/calculators/bmi_calculator.dart';
import '../../domain/calculators/cintura_quadril_calculator.dart';

/// Página da calculadora de relação cintura-quadril
class CinturaQuadrilCalculatorPage extends StatefulWidget {
  const CinturaQuadrilCalculatorPage({super.key});

  @override
  State<CinturaQuadrilCalculatorPage> createState() =>
      _CinturaQuadrilCalculatorPageState();
}

class _CinturaQuadrilCalculatorPageState
    extends State<CinturaQuadrilCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  Gender _gender = Gender.male;
  WaistHipRatioResult? _result;

  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Relação Cintura-Quadril',
      subtitle: 'RCQ',
      icon: Icons.straighten,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share result
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
                      isSelected: _gender == Gender.male,
                      onTap: () => setState(() => _gender = Gender.male),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderButton(
                      label: 'Feminino',
                      icon: Icons.female,
                      isSelected: _gender == Gender.female,
                      onTap: () => setState(() => _gender = Gender.female),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Measurement instructions
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Como medir:',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Cintura: Na altura do umbigo, relaxado\n'
                      '• Quadril: Na parte mais larga dos glúteos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Input fields
              Row(
                children: [
                  Expanded(
                    child: _DarkInputField(
                      label: 'Cintura',
                      controller: _waistController,
                      suffix: 'cm',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 40 || num > 200) {
                          return 'Valor inválido (40-200)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DarkInputField(
                      label: 'Quadril',
                      controller: _hipController,
                      suffix: 'cm',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 50 || num > 250) {
                          return 'Valor inválido (50-250)';
                        }
                        return null;
                      },
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
                _WhrResultCard(result: _result!),
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

    final result = CinturaQuadrilCalculator.calculate(
      waistCm: double.parse(_waistController.text),
      hipCm: double.parse(_hipController.text),
      gender: _gender,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _waistController.clear();
    _hipController.clear();
    setState(() {
      _gender = Gender.male;
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

class _WhrResultCard extends StatelessWidget {
  final WaistHipRatioResult result;

  const _WhrResultCard({required this.result});

  Color _getClassificationColor(WhrClassification classification) {
    return switch (classification) {
      WhrClassification.low => Colors.green,
      WhrClassification.moderate => Colors.amber,
      WhrClassification.high => Colors.orange,
      WhrClassification.veryHigh => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final classificationColor = _getClassificationColor(result.classification);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: classificationColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // RCQ Value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: classificationColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: classificationColor, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  result.whr.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: classificationColor,
                  ),
                ),
                Text(
                  'RCQ',
                  style: TextStyle(
                    color: classificationColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Classification chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: classificationColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.classificationText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Health risk
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 20,
                  color: classificationColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.healthRisk,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(14),
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
        ],
      ),
    );
  }
}
