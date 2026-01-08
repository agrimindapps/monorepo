import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
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
      categoryName: 'Pet',
      instructions: 'Descubra a idade equivalente do seu pet em anos humanos. '
          'A conversão varia conforme a espécie e o porte do animal.',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share functionality handled by ShareButton in result card
            },
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
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
                  color: Colors.white.withValues(alpha: 0.8),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
                    return ChoiceChip(
                      label: Text(
                        AnimalAgeCalculator.getDogSizeDescription(size),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _dogSize = size),
                      selectedColor: CalculatorAccentColors.pet.withValues(alpha: 0.3),
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.white.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? CalculatorAccentColors.pet
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Age input
              _DarkInputField(
                label: 'Idade do pet',
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
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text(
                    'Calcular Idade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalculatorAccentColors.pet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
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

class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CalculatorAccentColors.pet,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
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

    return Material(
      color: isSelected 
          ? accentColor.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
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
                  : Colors.white.withValues(alpha: 0.1),
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
                      : Colors.white.withValues(alpha: 0.7),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
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
                  color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.ageComparison,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.9),
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
                        color: Colors.white.withValues(alpha: 0.8),
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
