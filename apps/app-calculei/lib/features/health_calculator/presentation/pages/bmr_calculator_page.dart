import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/calculators/bmr_calculator.dart';

/// Página da calculadora de TMB (Taxa Metabólica Basal)
class BmrCalculatorPage extends StatefulWidget {
  const BmrCalculatorPage({super.key});

  @override
  State<BmrCalculatorPage> createState() => _BmrCalculatorPageState();
}

class _BmrCalculatorPageState extends State<BmrCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isMale = true;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  BmrResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Calculadora de TMB',
      subtitle: 'Taxa Metabólica Basal',
      icon: Icons.local_fire_department,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 700,
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
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
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
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Peso',
                      controller: _weightController,
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
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Altura',
                      controller: _heightController,
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
                        if (num == null || num < 50 || num > 300) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Idade',
                      controller: _ageController,
                      suffix: 'anos',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Obrigatório';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 1 || num > 120) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Activity Level
              Text(
                'Nível de atividade física',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...ActivityLevel.values.map(
                (level) => _ActivityRadioTile(
                  description: BmrCalculator.getActivityDescription(level),
                  value: level,
                  groupValue: _activityLevel,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _activityLevel = value);
                    }
                  },
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
                _BmrResultCard(result: _result!),
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

    final result = BmrCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      ageYears: int.parse(_ageController.text),
      isMale: _isMale,
      activityLevel: _activityLevel,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    _heightController.clear();
    _ageController.clear();
    setState(() {
      _isMale = true;
      _activityLevel = ActivityLevel.sedentary;
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
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
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: colorScheme.onSurface.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : colorScheme.onSurface.withValues(alpha: 0.05),
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
                  : colorScheme.onSurface.withValues(alpha: 0.1),
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
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? accentColor
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity level radio tile with dark theme
class _ActivityRadioTile extends StatelessWidget {
  final String description;
  final ActivityLevel value;
  final ActivityLevel groupValue;
  final ValueChanged<ActivityLevel?> onChanged;

  const _ActivityRadioTile({
    required this.description,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    const accentColor = CalculatorAccentColors.health;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? accentColor.withValues(alpha: 0.1)
            : colorScheme.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? accentColor
                    : colorScheme.onSurface.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BmrResultCard extends StatelessWidget {
  final BmrResult result;

  const _BmrResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
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
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Resultados',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main results
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  label: 'TMB',
                  value: result.bmr.toStringAsFixed(0),
                  unit: 'kcal/dia',
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                  description: 'Calorias em repouso',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'GET',
                  value: result.tdee.toStringAsFixed(0),
                  unit: 'kcal/dia',
                  color: Colors.blue,
                  icon: Icons.directions_run,
                  description: 'Gasto energético total',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Calorie targets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metas calóricas',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _CalorieTarget(
                  label: 'Para emagrecer',
                  value: result.caloriesForWeightLoss,
                  color: Colors.green,
                  icon: Icons.trending_down,
                ),
                const SizedBox(height: 10),
                _CalorieTarget(
                  label: 'Para manter',
                  value: result.tdee,
                  color: Colors.blue,
                  icon: Icons.trending_flat,
                ),
                const SizedBox(height: 10),
                _CalorieTarget(
                  label: 'Para ganhar peso',
                  value: result.caloriesForWeightGain,
                  color: Colors.orange,
                  icon: Icons.trending_up,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tips
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
                    'Déficit de 500 kcal/dia resulta em perda de ~0.5kg/semana. '
                    'Nunca consuma menos que sua TMB.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
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
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final String description;

  const _ResultBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CalorieTarget extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _CalorieTarget({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} kcal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}
