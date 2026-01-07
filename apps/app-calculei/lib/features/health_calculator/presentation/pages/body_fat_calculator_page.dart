import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/body_fat_calculator.dart';

/// Página da calculadora de Gordura Corporal
class BodyFatCalculatorPage extends StatefulWidget {
  const BodyFatCalculatorPage({super.key});

  @override
  State<BodyFatCalculatorPage> createState() => _BodyFatCalculatorPageState();
}

class _BodyFatCalculatorPageState extends State<BodyFatCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _waistController = TextEditingController();
  final _neckController = TextEditingController();
  final _hipController = TextEditingController();

  bool _isMale = true;
  BodyFatResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipController.dispose();
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
                                Icons.pie_chart,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Método US Navy',
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
                            'Calcula o percentual de gordura corporal usando medidas de '
                            'circunferência. É o método mais preciso sem equipamentos '
                            'especializados.',
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

                            // Basic measurements
                            Text(
                              'Medidas básicas',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
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
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Circumference measurements
                            Text(
                              'Circunferências',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
                                    label: 'Cintura',
                                    controller: _waistController,
                                    suffix: 'cm',
                                    hint: 'No umbigo',
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
                                      if (num == null ||
                                          num < 40 ||
                                          num > 200) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
                                    label: 'Pescoço',
                                    controller: _neckController,
                                    suffix: 'cm',
                                    hint: 'Abaixo do pomo',
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
                                      if (num == null ||
                                          num < 20 ||
                                          num > 80) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (!_isMale)
                                  SizedBox(
                                    width: 150,
                                    child: StandardInputField(
                                      label: 'Quadril',
                                      controller: _hipController,
                                      suffix: 'cm',
                                      hint: 'Parte mais larga',
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
                                        if (!_isMale) {
                                          if (value == null || value.isEmpty) {
                                            return 'Obrigatório';
                                          }
                                          final num = double.tryParse(value);
                                          if (num == null ||
                                              num < 50 ||
                                              num > 200) {
                                            return 'Inválido';
                                          }
                                        }
                                        return null;
                                      },
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
                  if (_result != null) _BodyFatResultCard(result: _result!, isMale: _isMale),
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

    double? hipCm;
    if (!_isMale && _hipController.text.isNotEmpty) {
      hipCm = double.tryParse(_hipController.text);
    }

    final result = BodyFatCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      heightCm: double.parse(_heightController.text),
      waistCm: double.parse(_waistController.text),
      neckCm: double.parse(_neckController.text),
      hipCm: hipCm,
      isMale: _isMale,
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

class _BodyFatResultCard extends StatelessWidget {
  final BodyFatResult result;
  final bool isMale;

  const _BodyFatResultCard({required this.result, required this.isMale});

  Color _getCategoryColor(BodyFatCategory category) {
    return switch (category) {
      BodyFatCategory.essential => Colors.red,
      BodyFatCategory.athlete => Colors.blue,
      BodyFatCategory.fitness => Colors.green,
      BodyFatCategory.average => Colors.orange,
      BodyFatCategory.obese => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(result.category);

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
                  text: ShareFormatter.formatBodyFatCalculation(
                    bodyFatPercentage: result.bodyFatPercentage,
                    category: result.categoryText,
                    fatMassKg: result.fatMassKg,
                    leanMassKg: result.leanMassKg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: categoryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${result.bodyFatPercentage}%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gordura Corporal',
                    style: TextStyle(color: categoryColor),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(
                      result.categoryText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: categoryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Body composition
            Row(
              children: [
                Expanded(
                  child: _CompositionCard(
                    label: 'Massa Gorda',
                    value: '${result.fatMassKg} kg',
                    icon: Icons.water_drop,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompositionCard(
                    label: 'Massa Magra',
                    value: '${result.leanMassKg} kg',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reference ranges
            Text(
              'Faixas de referência (${isMale ? 'Homens' : 'Mulheres'})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _BodyFatRangeChart(
              ranges: BodyFatCalculator.getRanges(isMale),
              currentValue: result.bodyFatPercentage,
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
          ],
        ),
      ),
    );
  }
}

class _CompositionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _CompositionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
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
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyFatRangeChart extends StatelessWidget {
  final Map<String, (double, double)> ranges;
  final double currentValue;

  const _BodyFatRangeChart({
    required this.ranges,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red.shade300,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: List.generate(ranges.length, (index) {
              final entry = ranges.entries.elementAt(index);
              final range = entry.value;
              final width = (range.$2 - range.$1).clamp(5.0, 30.0);
              
              return Expanded(
                flex: width.toInt(),
                child: Container(
                  height: 24,
                  color: colors[index],
                  child: Center(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0%', style: TextStyle(fontSize: 10)),
            Text('Você: ${currentValue}%',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('50%', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
