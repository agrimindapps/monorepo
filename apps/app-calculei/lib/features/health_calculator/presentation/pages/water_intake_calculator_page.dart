import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
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
    return CalculatorPageLayout(
      title: 'Ingestão de Água',
      subtitle: 'Calcule sua hidratação diária',
      icon: Icons.water_drop,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
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
              // Weight input
              _DarkInputField(
                label: 'Peso',
                controller: _weightController,
                suffix: 'kg',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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

              const SizedBox(height: 24),

              // Activity Level
              Text(
                'Nível de atividade física',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WaterActivityLevel.values.map((level) {
                  final isSelected = _activityLevel == level;
                  return _ActivityChip(
                    label: WaterIntakeCalculator.getActivityDescription(level),
                    isSelected: isSelected,
                    onTap: () => setState(() => _activityLevel = level),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Climate
              Text(
                'Clima',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ClimateType.values.map((climate) {
                  final isSelected = _climate == climate;
                  return _ActivityChip(
                    label: WaterIntakeCalculator.getClimateDescription(climate),
                    isSelected: isSelected,
                    onTap: () => setState(() => _climate = climate),
                  );
                }).toList(),
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
                _WaterResultCard(result: _result!),
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

    final result = WaterIntakeCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      activityLevel: _activityLevel,
      climate: _climate,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    setState(() {
      _activityLevel = WaterActivityLevel.sedentary;
      _climate = ClimateType.temperate;
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
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
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
              borderSide: const BorderSide(
                color: CalculatorAccentColors.health,
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

/// Dark themed activity/climate chip selector
class _ActivityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityChip({
    required this.label,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : colorScheme.onSurface.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected
                  ? accentColor
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterResultCard extends StatelessWidget {
  final WaterIntakeResult result;

  const _WaterResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    const resultColor = CalculatorAccentColors.health;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Main result - daily liters
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  resultColor.withValues(alpha: 0.3),
                  resultColor.withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: resultColor,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.adjustedLiters.toStringAsFixed(1)}L',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                Text(
                  'por dia',
                  style: TextStyle(
                    color: resultColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details - glasses and bottles
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

          // Base vs Adjusted comparison
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Base',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${result.baseLiters}L',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: resultColor,
                ),
                Column(
                  children: [
                    Text(
                      'Ajustado',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${result.adjustedLiters}L',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tips section
          Container(
            padding: const EdgeInsets.all(14),
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
                      Icons.tips_and_updates_outlined,
                      size: 18,
                      color: Colors.amber.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dicas de hidratação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...WaterIntakeCalculator.getHydrationTips().map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: resultColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
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
    const accentColor = CalculatorAccentColors.health;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: accentColor.withValues(alpha: 0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
