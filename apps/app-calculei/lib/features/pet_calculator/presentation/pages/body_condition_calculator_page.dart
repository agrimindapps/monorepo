import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/body_condition_calculator.dart';

/// Página da calculadora de Escore de Condição Corporal
class BodyConditionCalculatorPage extends StatefulWidget {
  const BodyConditionCalculatorPage({super.key});

  @override
  State<BodyConditionCalculatorPage> createState() =>
      _BodyConditionCalculatorPageState();
}

class _BodyConditionCalculatorPageState
    extends State<BodyConditionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();

  PetSpecies _species = PetSpecies.dog;
  int _ribPalpation = 3;
  int _waistVisibility = 3;
  int _abdominalProfile = 3;
  BodyConditionResult? _result;

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
                                Icons.monitor_weight,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Avaliação de Peso Ideal',
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
                            'Avalie a condição corporal do seu pet através de parâmetros físicos. '
                            'O ECC (1-9) indica se está abaixo, ideal, sobrepeso ou obeso.',
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
                              'Avaliação Física',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Species selection
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

                            const SizedBox(height: 24),

                            // Rib Palpation
                            _buildScoreSelector(
                              title: 'Palpação das Costelas',
                              value: _ribPalpation,
                              descriptions: BodyConditionCalculator
                                  .parameterDescriptions['ribPalpation']!,
                              onChanged: (value) =>
                                  setState(() => _ribPalpation = value),
                            ),

                            const SizedBox(height: 20),

                            // Waist Visibility
                            _buildScoreSelector(
                              title: 'Visibilidade da Cintura',
                              value: _waistVisibility,
                              descriptions: BodyConditionCalculator
                                  .parameterDescriptions['waistVisibility']!,
                              onChanged: (value) =>
                                  setState(() => _waistVisibility = value),
                            ),

                            const SizedBox(height: 20),

                            // Abdominal Profile
                            _buildScoreSelector(
                              title: 'Perfil Abdominal',
                              value: _abdominalProfile,
                              descriptions: BodyConditionCalculator
                                  .parameterDescriptions['abdominalProfile']!,
                              onChanged: (value) =>
                                  setState(() => _abdominalProfile = value),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular ECC',
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
                    _BodyConditionResultCard(
                      result: _result!,
                      species: _species,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSelector({
    required String title,
    required int value,
    required List<String> descriptions,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final score = index + 1;
            final isSelected = value == score;
            return InkWell(
              onTap: () => onChanged(score),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            descriptions[value - 1],
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = BodyConditionCalculator.calculate(
      species: _species,
      ribPalpation: _ribPalpation,
      waistVisibility: _waistVisibility,
      abdominalProfile: _abdominalProfile,
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

class _BodyConditionResultCard extends StatelessWidget {
  final BodyConditionResult result;
  final PetSpecies species;

  const _BodyConditionResultCard({
    required this.result,
    required this.species,
  });

  Color _getClassificationColor(BcsClassification classification) {
    return switch (classification) {
      BcsClassification.underweight => Colors.blue,
      BcsClassification.ideal => Colors.green,
      BcsClassification.overweight => Colors.orange,
      BcsClassification.obese => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getClassificationColor(result.classification);
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
📋 Escore de Condição Corporal - Calculei App

🐾 Espécie: ${species == PetSpecies.dog ? 'Cachorro' : 'Gato'}
📊 ECC: ${result.bcs.toStringAsFixed(1)}/9
🏷️ Classificação: ${result.classificationText}

${result.description}

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
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 2,
                ),
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
                        result.bcs.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' / 9',
                          style: TextStyle(fontSize: 20, color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      result.classificationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: color,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.description,
                style: const TextStyle(fontWeight: FontWeight.w500),
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
                      color: color,
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
