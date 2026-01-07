import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/animal_age_calculator.dart';

/// Página da calculadora de Idade Animal
class AnimalAgeCalculatorPage extends StatefulWidget {
  const AnimalAgeCalculatorPage({super.key});

  @override
  State<AnimalAgeCalculatorPage> createState() => _AnimalAgeCalculatorPageState();
}

class _AnimalAgeCalculatorPageState extends State<AnimalAgeCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  DogSize _dogSize = DogSize.medium;
  AnimalAgeResult? _result;

  @override
  void dispose() {
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
                                Icons.pets,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Idade em Anos Humanos',
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
                            'Descubra a idade equivalente do seu pet em anos humanos. '
                            'A conversão varia conforme a espécie e o porte do animal.',
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
                                    icon: Icons.pets,
                                    emoji: '🐕',
                                    isSelected: _species == PetSpecies.dog,
                                    onTap: () => setState(() {
                                      _species = PetSpecies.dog;
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SpeciesButton(
                                    label: 'Gato',
                                    icon: Icons.pets,
                                    emoji: '🐈',
                                    isSelected: _species == PetSpecies.cat,
                                    onTap: () => setState(() {
                                      _species = PetSpecies.cat;
                                    }),
                                  ),
                                ),
                              ],
                            ),

                            // Dog size (only for dogs)
                            if (_species == PetSpecies.dog) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Porte do cachorro',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: DogSize.values.map((size) {
                                  final isSelected = _dogSize == size;
                                  return ChoiceChip(
                                    label: Text(
                                      AnimalAgeCalculator.getDogSizeDescription(
                                          size),
                                    ),
                                    selected: isSelected,
                                    onSelected: (_) =>
                                        setState(() => _dogSize = size),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Age input
                            StandardInputField(
                              label: 'Idade do pet',
                              controller: _ageController,
                              suffix: 'anos',
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
                                if (num == null || num <= 0 || num > 30) {
                                  return 'Entre 0 e 30 anos';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Idade',
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
                    _AnimalAgeResultCard(
                      result: _result!,
                      species: _species,
                      petAge: double.parse(_ageController.text),
                    ),
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

    final result = AnimalAgeCalculator.calculate(
      species: _species,
      ageYears: double.parse(_ageController.text),
      dogSize: _species == PetSpecies.dog ? _dogSize : null,
    );

    setState(() => _result = result);
  }
}

class _SpeciesButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeciesButton({
    required this.label,
    required this.icon,
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

class _AnimalAgeResultCard extends StatelessWidget {
  final AnimalAgeResult result;
  final PetSpecies species;
  final double petAge;

  const _AnimalAgeResultCard({
    required this.result,
    required this.species,
    required this.petAge,
  });

  Color _getLifeStageColor(LifeStage stage) {
    return switch (stage) {
      LifeStage.puppy => Colors.blue,
      LifeStage.youngAdult => Colors.green,
      LifeStage.adult => Colors.teal,
      LifeStage.matureAdult => Colors.orange,
      LifeStage.senior => Colors.deepOrange,
      LifeStage.geriatric => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stageColor = _getLifeStageColor(result.lifeStage);
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
                  text: ShareFormatter.formatAnimalAgeCalculation(
                    petAge: petAge,
                    humanAge: result.humanAge,
                    species: species == PetSpecies.dog ? 'Cachorro' : 'Gato',
                    lifeStage: result.lifeStageText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result with emoji
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    stageColor.withValues(alpha: 0.2),
                    stageColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: stageColor.withValues(alpha: 0.5),
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
                        '${result.humanAge}',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: stageColor,
                                ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' anos humanos',
                          style: TextStyle(
                            fontSize: 16,
                            color: stageColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      result.lifeStageText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: stageColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Comparison text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.compare_arrows),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.ageComparison,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Care recommendations
            Text(
              'Cuidados recomendados',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.careRecommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: stageColor,
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
