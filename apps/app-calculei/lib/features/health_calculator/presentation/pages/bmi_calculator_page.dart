import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/bmi_calculator.dart';

/// Página da calculadora de IMC (Índice de Massa Corporal)
class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Gender _gender = Gender.male;
  BmiResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
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
                                Icons.monitor_weight_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Índice de Massa Corporal',
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
                            'O IMC é uma medida internacional usada para calcular '
                            'se uma pessoa está no peso ideal. A fórmula considera '
                            'peso e altura, com classificações diferentes por gênero.',
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
                                    isSelected: _gender == Gender.male,
                                    onTap: () =>
                                        setState(() => _gender = Gender.male),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _GenderButton(
                                    label: 'Feminino',
                                    icon: Icons.female,
                                    isSelected: _gender == Gender.female,
                                    onTap: () =>
                                        setState(() => _gender = Gender.female),
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
                                    label: 'Peso',
                                    controller: _weightController,
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
                                        return 'Valor inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular IMC',
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
                  if (_result != null) _BmiResultCard(result: _result!),
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

    final result = BmiCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      gender: _gender,
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

class _BmiResultCard extends StatelessWidget {
  final BmiResult result;

  const _BmiResultCard({required this.result});

  Color _getClassificationColor(BmiClassification classification) {
    return switch (classification) {
      BmiClassification.underweight => Colors.orange,
      BmiClassification.normal => Colors.green,
      BmiClassification.overweightI => Colors.amber,
      BmiClassification.overweightII => Colors.orange,
      BmiClassification.overweightIII => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final classificationColor = _getClassificationColor(result.classification);

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
                  text: ShareFormatter.formatBmiCalculation(
                    bmi: result.bmi,
                    classification: result.classificationText,
                    minIdealWeight: result.minIdealWeight,
                    maxIdealWeight: result.maxIdealWeight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // IMC Value
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: classificationColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: classificationColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      result.bmi.toStringAsFixed(1),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: classificationColor,
                              ),
                    ),
                    Text(
                      'IMC',
                      style: TextStyle(
                        color: classificationColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Classification
            Center(
              child: Chip(
                label: Text(
                  result.classificationText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: classificationColor,
              ),
            ),

            const SizedBox(height: 16),

            // Ideal weight range
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.straighten, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Peso ideal: ${result.minIdealWeight} - ${result.maxIdealWeight} kg',
                    style: const TextStyle(fontWeight: FontWeight.w500),
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

            // IMC Scale
            _BmiScaleIndicator(currentBmi: result.bmi),
          ],
        ),
      ),
    );
  }
}

class _BmiScaleIndicator extends StatelessWidget {
  final double currentBmi;

  const _BmiScaleIndicator({required this.currentBmi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Escala de IMC',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              _ScaleSegment(
                label: '<18.5',
                color: Colors.orange,
                flex: 185,
              ),
              _ScaleSegment(
                label: '18.5-24.9',
                color: Colors.green,
                flex: 64,
              ),
              _ScaleSegment(
                label: '25-29.9',
                color: Colors.amber,
                flex: 50,
              ),
              _ScaleSegment(
                label: '30+',
                color: Colors.red,
                flex: 100,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScaleSegment extends StatelessWidget {
  final String label;
  final Color color;
  final int flex;

  const _ScaleSegment({
    required this.label,
    required this.color,
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 24,
        color: color,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
