import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/bmi_calculator.dart';
import '../../domain/calculators/volume_sanguineo_calculator.dart';

/// Página da calculadora de volume sanguíneo
class VolumeSanguineoCalculatorPage extends StatefulWidget {
  const VolumeSanguineoCalculatorPage({super.key});

  @override
  State<VolumeSanguineoCalculatorPage> createState() =>
      _VolumeSanguineoCalculatorPageState();
}

class _VolumeSanguineoCalculatorPageState
    extends State<VolumeSanguineoCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  Gender _gender = Gender.male;
  bool _useSimplified = false;
  BloodVolumeResult? _result;

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
                                Icons.water_drop_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Volume Total de Sangue',
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
                            'Estima o volume total de sangue no corpo usando a fórmula '
                            'de Nadler (mais precisa) ou método simplificado. O volume '
                            'sanguíneo é importante para transporte de oxigênio e nutrientes.',
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
                                    enabled: !_useSimplified,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (_useSimplified) return null;
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

                            const SizedBox(height: 16),

                            // Method selection
                            SwitchListTile(
                              title: const Text('Usar método simplificado'),
                              subtitle: const Text(
                                  'Mais rápido, mas menos preciso (não usa altura)'),
                              value: _useSimplified,
                              onChanged: (value) {
                                setState(() => _useSimplified = value);
                              },
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Volume',
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
                  if (_result != null)
                    _BloodVolumeResultCard(result: _result!),
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

    final result = VolumeSanguineoCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: _useSimplified
          ? 170.0
          : double.parse(_heightController.text), // Default if simplified
      gender: _gender,
      useSimplified: _useSimplified,
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

class _BloodVolumeResultCard extends StatelessWidget {
  final BloodVolumeResult result;

  const _BloodVolumeResultCard({required this.result});

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
                  text: ShareFormatter.formatGeneric(
                    title: 'Volume Sanguíneo',
                    data: {
                      '💉 Volume': '${result.volumeLiters}L (${result.volumeMl.toStringAsFixed(0)}ml)',
                      '📊 Método': result.method,
                      '💡 Interpretação': result.interpretation,
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Blood volume
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${result.volumeLiters}L',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                    ),
                    Text(
                      '${result.volumeMl.toStringAsFixed(0)} ml',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Method
            Center(
              child: Chip(
                label: Text(
                  result.method,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: colorScheme.secondary,
              ),
            ),

            const SizedBox(height: 16),

            // Interpretation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.interpretation,
                      style: const TextStyle(fontWeight: FontWeight.w500),
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

            // Fun facts
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Você sabia?',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• O sangue representa 7-8% do peso corporal'),
                  const Text('• Um adulto tem cerca de 5-6 litros de sangue'),
                  const Text('• O corpo repõe sangue doado em 24-48h'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
