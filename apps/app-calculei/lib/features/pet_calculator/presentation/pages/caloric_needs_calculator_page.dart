import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/caloric_needs_calculator.dart';

/// Página da calculadora de Necessidades Calóricas
class CaloricNeedsCalculatorPage extends StatefulWidget {
  const CaloricNeedsCalculatorPage({super.key});

  @override
  State<CaloricNeedsCalculatorPage> createState() =>
      _CaloricNeedsCalculatorPageState();
}

class _CaloricNeedsCalculatorPageState
    extends State<CaloricNeedsCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  LifeStage _lifeStage = LifeStage.adult;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  bool _isNeutered = false;
  CaloricNeedsResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
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
                                Icons.restaurant,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Calorias Diárias do Pet',
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule a quantidade ideal de calorias que seu pet precisa diariamente '
                            'baseado em peso, idade, atividade e se é castrado.',
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
                              'Dados do pet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Species
                            Row(
                              children: [
                                Expanded(
                                  child: _SpeciesButton(
                                    label: 'Cachorro',
                                    emoji: '🐕',
                                    isSelected: _species == PetSpecies.dog,
                                    onTap: () =>
                                        setState(() => _species = PetSpecies.dog),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SpeciesButton(
                                    label: 'Gato',
                                    emoji: '🐈',
                                    isSelected: _species == PetSpecies.cat,
                                    onTap: () =>
                                        setState(() => _species = PetSpecies.cat),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Weight
                            StandardInputField(
                              label: 'Peso do pet',
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
                                if (num == null || num <= 0 || num > 100) {
                                  return 'Entre 0 e 100 kg';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Life Stage
                            Text(
                              'Estágio de Vida',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: LifeStage.values.map((stage) {
                                return ChoiceChip(
                                  label: Text(_getLifeStageLabel(stage)),
                                  selected: _lifeStage == stage,
                                  onSelected: (_) =>
                                      setState(() => _lifeStage = stage),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Activity Level
                            Text(
                              'Nível de Atividade',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ActivityLevel.values.map((level) {
                                return ChoiceChip(
                                  label: Text(_getActivityLabel(level)),
                                  selected: _activityLevel == level,
                                  onSelected: (_) =>
                                      setState(() => _activityLevel = level),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Neutered
                            CheckboxListTile(
                              title: const Text('Pet castrado/esterilizado'),
                              subtitle: const Text(
                                'Pets castrados têm menor gasto energético',
                              ),
                              value: _isNeutered,
                              onChanged: (value) =>
                                  setState(() => _isNeutered = value ?? false),
                              contentPadding: EdgeInsets.zero,
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Calorias',
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
                    _CaloricNeedsResultCard(
                      result: _result!,
                      species: _species,
                      weight: double.parse(_weightController.text),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLifeStageLabel(LifeStage stage) {
    return switch (stage) {
      LifeStage.puppy => 'Filhote',
      LifeStage.young => 'Jovem',
      LifeStage.adult => 'Adulto',
      LifeStage.senior => 'Idoso',
    };
  }

  String _getActivityLabel(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentário',
      ActivityLevel.light => 'Leve',
      ActivityLevel.moderate => 'Moderado',
      ActivityLevel.active => 'Ativo',
    };
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = CaloricNeedsCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      species: _species,
      lifeStage: _lifeStage,
      activityLevel: _activityLevel,
      isNeutered: _isNeutered,
    );

    setState(() => _result = result);
  }
}

class _SpeciesButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeciesButton({
    required this.label,
    required this.emoji,
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
              Text(emoji, style: const TextStyle(fontSize: 32)),
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

class _CaloricNeedsResultCard extends StatelessWidget {
  final CaloricNeedsResult result;
  final PetSpecies species;
  final double weight;

  const _CaloricNeedsResultCard({
    required this.result,
    required this.species,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final petEmoji = species == PetSpecies.dog ? '🐕' : '🐈';

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
                  text: '''
📋 Necessidades Calóricas - Calculei App

🐾 Pet: ${species == PetSpecies.dog ? 'Cachorro' : 'Gato'} ($petEmoji)
⚖️ Peso: ${weight.toStringAsFixed(1)} kg
📅 Estágio: ${result.lifeStageText}
🏃 Atividade: ${result.activityLevelText}

🔥 Calorias Diárias: ${result.der.toStringAsFixed(0)} kcal/dia
🍽️ Quantidade de ração: ${result.foodAmountGrams.toStringAsFixed(0)}g/dia

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(petEmoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.der.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' kcal/dia',
                          style: TextStyle(
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant,
                          color: colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '${result.foodAmountGrams.toStringAsFixed(0)}g de ração/dia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'RER (Repouso)',
                    value: '${result.rer.toStringAsFixed(0)} kcal',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Estágio',
                    value: result.lifeStageText,
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Atividade',
                    value: result.activityLevelText,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommendations
            Text(
              'Recomendações',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(rec, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
