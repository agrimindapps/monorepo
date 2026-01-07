import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
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
                                Icons.local_fire_department,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'O que é TMB?',
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
                            'A Taxa Metabólica Basal é a quantidade mínima de energia '
                            '(calorias) que seu corpo precisa em repouso para manter '
                            'funções vitais como respiração, circulação e digestão.',
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
                                  width: 150,
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
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
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
                                          num < 50 ||
                                          num > 300) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
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

                            const SizedBox(height: 20),

                            // Activity Level
                            Text(
                              'Nível de atividade física',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            ...ActivityLevel.values.map(
                              (level) => RadioListTile<ActivityLevel>(
                                title: Text(
                                  BmrCalculator.getActivityDescription(level),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: level,
                                groupValue: _activityLevel,
                                dense: true,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _activityLevel = value);
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            CalculatorButton(
                              label: 'Calcular TMB',
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
                  if (_result != null) _BmrResultCard(result: _result!),
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

    final result = BmrCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      ageYears: int.parse(_ageController.text),
      isMale: _isMale,
      activityLevel: _activityLevel,
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

class _BmrResultCard extends StatelessWidget {
  final BmrResult result;

  const _BmrResultCard({required this.result});

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
                  text: ShareFormatter.formatBmrCalculation(
                    bmr: result.bmr,
                    tdee: result.tdee,
                    activityLevel: BmrCalculator.getActivityDescription(
                      result.activityLevel,
                    ),
                    caloriesForWeightLoss: result.caloriesForWeightLoss,
                    caloriesForWeightGain: result.caloriesForWeightGain,
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
                    value: '${result.bmr.toStringAsFixed(0)}',
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
                    value: '${result.tdee.toStringAsFixed(0)}',
                    unit: 'kcal/dia',
                    color: Colors.blue,
                    icon: Icons.directions_run,
                    description: 'Gasto energético total',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Calorie targets
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metas calóricas',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _CalorieTarget(
                    label: 'Para emagrecer',
                    value: result.caloriesForWeightLoss,
                    color: Colors.green,
                    icon: Icons.trending_down,
                  ),
                  const SizedBox(height: 8),
                  _CalorieTarget(
                    label: 'Para manter',
                    value: result.tdee,
                    color: Colors.blue,
                    icon: Icons.trending_flat,
                  ),
                  const SizedBox(height: 8),
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
                      'Déficit de 500 kcal/dia resulta em perda de ~0.5kg/semana. '
                      'Nunca consuma menos que sua TMB.',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            unit,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
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
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(
          '${value.toStringAsFixed(0)} kcal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
