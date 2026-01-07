import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
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
                                Icons.accessibility_new,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cálculo de Peso Ideal',
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
                            'Utiliza 4 fórmulas científicas (Devine, Robinson, Miller, Hamwi) '
                            'para calcular uma estimativa precisa do peso ideal baseado '
                            'na sua altura e gênero.',
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

                            // Gender selection
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
                                    onTap: () =>
                                        setState(() => _isMale = false),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Inputs Row
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
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
                                      if (num == null ||
                                          num < 100 ||
                                          num > 250) {
                                        return 'Entre 100 e 250 cm';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Peso atual (opcional)',
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
                                  ),
                                ),
                              ],
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
                  if (_result != null) _IdealWeightResultCard(result: _result!),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
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

class _IdealWeightResultCard extends StatelessWidget {
  final IdealWeightResult result;

  const _IdealWeightResultCard({required this.result});

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
                  text: ShareFormatter.formatIdealWeightCalculation(
                    averageWeight: result.averageWeight,
                    minRange: result.minRange,
                    maxRange: result.maxRange,
                    devineWeight: result.devineWeight,
                    robinsonWeight: result.robinsonWeight,
                    millerWeight: result.millerWeight,
                    hamwiWeight: result.hamwiWeight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
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
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                  ),
                  const Text(
                    'Peso Ideal (média)',
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Faixa: ${result.minRange} - ${result.maxRange} kg',
                      style: const TextStyle(fontWeight: FontWeight.w500),
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
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O peso ideal é uma estimativa. Fatores como composição '
                      'corporal, idade e condições de saúde também são importantes.',
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifferenceColor(double? difference) {
    if (difference == null || difference.abs() < 1) return Colors.green;
    return Colors.orange;
  }

  IconData _getDifferenceIcon(double? difference) {
    if (difference == null || difference.abs() < 1) {
      return Icons.check_circle;
    }
    if (difference > 0) return Icons.arrow_upward;
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$value kg',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
