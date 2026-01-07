import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/alcool_sangue_calculator.dart';
import '../../domain/calculators/bmi_calculator.dart';

/// Página da calculadora de álcool no sangue
class AlcoolSangueCalculatorPage extends StatefulWidget {
  const AlcoolSangueCalculatorPage({super.key});

  @override
  State<AlcoolSangueCalculatorPage> createState() =>
      _AlcoolSangueCalculatorPageState();
}

class _AlcoolSangueCalculatorPageState
    extends State<AlcoolSangueCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _drinksController = TextEditingController();
  final _hoursController = TextEditingController();

  Gender _gender = Gender.male;
  DrinkType _drinkType = DrinkType.beer;
  BloodAlcoholResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _drinksController.dispose();
    _hoursController.dispose();
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
                                Icons.local_bar,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Concentração de Álcool no Sangue',
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
                            'Estima o BAC (Blood Alcohol Concentration) usando a fórmula '
                            'de Widmark. ATENÇÃO: Esta é apenas uma estimativa. Não dirija '
                            'após consumir qualquer quantidade de álcool.',
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

                  // Warning Card
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'NUNCA dirija após consumir álcool. Lei Seca: 0 tolerância no Brasil.',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
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
                              'Informações',
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

                            // Weight input
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

                            const SizedBox(height: 16),

                            // Drink type selection
                            Text(
                              'Tipo de bebida',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DrinkTypeChip(
                                  type: DrinkType.beer,
                                  label: '🍺 Cerveja (350ml)',
                                  isSelected: _drinkType == DrinkType.beer,
                                  onTap: () =>
                                      setState(() => _drinkType = DrinkType.beer),
                                ),
                                _DrinkTypeChip(
                                  type: DrinkType.wine,
                                  label: '🍷 Vinho (150ml)',
                                  isSelected: _drinkType == DrinkType.wine,
                                  onTap: () =>
                                      setState(() => _drinkType = DrinkType.wine),
                                ),
                                _DrinkTypeChip(
                                  type: DrinkType.spirits,
                                  label: '🥃 Destilado (45ml)',
                                  isSelected: _drinkType == DrinkType.spirits,
                                  onTap: () => setState(
                                      () => _drinkType = DrinkType.spirits),
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
                                    label: 'Número de doses',
                                    controller: _drinksController,
                                    suffix: 'doses',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      final num = int.tryParse(value);
                                      if (num == null || num <= 0 || num > 50) {
                                        return 'Valor inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Horas desde 1ª dose',
                                    controller: _hoursController,
                                    suffix: 'horas',
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
                                      if (num == null || num < 0 || num > 48) {
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
                              label: 'Calcular BAC',
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
                  if (_result != null) _BacResultCard(result: _result!),
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

    final result = AlcoolSangueCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      drinksCount: int.parse(_drinksController.text),
      drinkType: _drinkType,
      hoursSinceDrinking: double.parse(_hoursController.text),
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

class _DrinkTypeChip extends StatelessWidget {
  final DrinkType type;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrinkTypeChip({
    required this.type,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }
}

class _BacResultCard extends StatelessWidget {
  final BloodAlcoholResult result;

  const _BacResultCard({required this.result});

  Color _getLevelColor(BacLevel level) {
    return switch (level) {
      BacLevel.sober => Colors.green,
      BacLevel.mild => Colors.amber,
      BacLevel.moderate => Colors.orange,
      BacLevel.high => Colors.red,
      BacLevel.veryHigh => Colors.red.shade900,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = _getLevelColor(result.level);

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
                    title: 'Álcool no Sangue',
                    data: {
                      '📊 BAC': '${result.bac.toStringAsFixed(3)} g/dL',
                      '🏷️ Nível': result.levelText,
                      '⚠️ Pode dirigir?': result.canDrive ? 'Sim' : 'NÃO',
                      '💡 Aviso': result.warning,
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BAC Value
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: levelColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      result.bac.toStringAsFixed(3),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                    ),
                    Text(
                      'g/dL',
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Level
            Center(
              child: Chip(
                label: Text(
                  result.levelText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: levelColor,
              ),
            ),

            const SizedBox(height: 16),

            // Can drive indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.canDrive
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.canDrive ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.canDrive ? Icons.check_circle : Icons.cancel,
                    color: result.canDrive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.canDrive
                          ? 'Abaixo do limite legal'
                          : 'PROIBIDO DIRIGIR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: result.canDrive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Effects
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
                    'Efeitos esperados:',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(result.effects),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning
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
                    Icons.warning,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.warning,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
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
