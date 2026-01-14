import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
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
    return CalculatorPageLayout(
      title: 'Calculadora de Idade Animal',
      subtitle: 'Idade em Anos Humanos',
      icon: Icons.cake_outlined,
      accentColor: CalculatorAccentColors.pet,
      currentCategory: 'pet',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return IconButton(
                icon: Icon(
                  Icons.share_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () {
                  // Share functionality handled by ShareButton in result card
                },
                tooltip: 'Compartilhar',
              );
            },
          ),
      ],
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Species selection
                  Text(
                    'Selecione a espécie',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SpeciesButton(
                          label: 'Cachorro',
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
                    const SizedBox(height: 24),
                    Text(
                      'Porte do cachorro',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DogSize.values.map((size) {
                        final isSelected = _dogSize == size;
                        return DarkChoiceChip(
                          label: AnimalAgeCalculator.getDogSizeDescription(size),
                          isSelected: isSelected,
                          onSelected: () => setState(() => _dogSize = size),
                          accentColor: CalculatorAccentColors.pet,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Age input
                  AdaptiveInputField(
                    label: 'Idade do pet',
                    hintText: 'Ex: 3',
                    controller: _ageController,
                    suffix: 'anos',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Obrigatório';
                      final num = double.tryParse(value);
                      if (num == null || num <= 0 || num > 30) return 'Entre 0 e 30 anos';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Calculate button
                  CalculatorActionButtons(
                    onCalculate: _calculate,
                    onClear: _clear,
                    accentColor: CalculatorAccentColors.pet,
                  ),

                  // Result
                  if (_result != null) ...[
                    const SizedBox(height: 32),
                    _AnimalAgeResultCard(
                      result: _result!,
                      species: _species,
                      petAge: double.parse(_ageController.text),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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

  void _clear() {
    _ageController.clear();
    setState(() {
      _species = PetSpecies.dog;
      _dogSize = DogSize.medium;
      _result = null;
    });
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
    const accentColor = CalculatorAccentColors.pet;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
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
                      ? accentColor
                      : isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
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
    final stageColor = _getLifeStageColor(result.lifeStage);
    final petEmoji = species == PetSpecies.dog ? '🐕' : '🐈';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stageColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: stageColor),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
                      style: TextStyle(
                        fontSize: 48,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: stageColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.lifeStageText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Comparison text
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.ageComparison,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Care recommendations
          Text(
            'Cuidados recomendados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
