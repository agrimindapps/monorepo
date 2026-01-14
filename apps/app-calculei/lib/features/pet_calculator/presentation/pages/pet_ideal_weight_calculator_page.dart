import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/pet_ideal_weight_calculator.dart';
export '../../../../core/widgets/calculator_page_layout.dart' show CalculatorAccentColors;

/// Página da calculadora de Peso Ideal para Pets
class PetIdealWeightCalculatorPage extends StatefulWidget {
  const PetIdealWeightCalculatorPage({super.key});

  @override
  State<PetIdealWeightCalculatorPage> createState() =>
      _PetIdealWeightCalculatorPageState();
}

class _PetIdealWeightCalculatorPageState
    extends State<PetIdealWeightCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  PetSpecies _species = PetSpecies.dog;
  BreedSize _breedSize = BreedSize.medium;
  int _bcsScore = 5;
  PetIdealWeightResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Peso Ideal do Pet',
      subtitle: 'Meta de Peso Saudável',
      icon: Icons.monitor_weight,
      accentColor: CalculatorAccentColors.pet,
      currentCategory: 'saude',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {},
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

              const SizedBox(height: 24),

              // Breed Size (only for dogs)
              if (_species == PetSpecies.dog) ...[
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return Text(
                      'Porte do Cachorro',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BreedSize.values.map((size) {
                    final isSelected = _breedSize == size;
                    return DarkChoiceChip(
                      label: PetIdealWeightCalculator
                          .getBreedSizeDescription(size),
                      isSelected: isSelected,
                      onSelected: () =>
                          setState(() => _breedSize = size),
                      accentColor: CalculatorAccentColors.pet,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Current Weight
              AdaptiveInputField(
                label: 'Peso atual',
                hintText: 'Ex: 25.0',
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

              const SizedBox(height: 24),

              // BCS Score
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    'Escore de Condição Corporal (BCS)',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(9, (index) {
                      final score = index + 1;
                      final isSelected = _bcsScore == score;
                      return InkWell(
                        onTap: () =>
                            setState(() => _bcsScore = score),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CalculatorAccentColors.pet
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? CalculatorAccentColors.pet
                                  : Colors.white.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getBcsDescription(_bcsScore),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Calculate button
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.pet,
              ),

              if (_result != null) ...[
                const SizedBox(height: 32),
                _PetIdealWeightResultCard(
                  result: _result!,
                  species: _species,
                  currentWeight: double.parse(_weightController.text),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getBcsDescription(int bcs) {
    if (bcs <= 3) return 'BCS $bcs: Abaixo do Peso';
    if (bcs <= 5) return 'BCS $bcs: Peso Ideal';
    if (bcs <= 7) return 'BCS $bcs: Sobrepeso';
    return 'BCS $bcs: Obesidade';
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = PetIdealWeightCalculator.calculate(
      species: _species,
      breedSize: _breedSize,
      currentWeight: double.parse(_weightController.text),
      bcsScore: _bcsScore,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    setState(() {
      _species = PetSpecies.dog;
      _breedSize = BreedSize.medium;
      _bcsScore = 5;
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
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.2),
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

class _PetIdealWeightResultCard extends StatelessWidget {
  final PetIdealWeightResult result;
  final PetSpecies species;
  final double currentWeight;

  const _PetIdealWeightResultCard({
    required this.result,
    required this.species,
    required this.currentWeight,
  });

  Color _getStatusColor() {
    if (result.shouldLoseWeight) return Colors.orange;
    if (result.shouldGainWeight) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.pet;
    final statusColor = _getStatusColor();
    final petEmoji = species == PetSpecies.dog ? '🐕' : '🐈';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: accentColor),
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
                text: '''
📋 Peso Ideal do Pet - Calculei App

🐾 Pet: ${species == PetSpecies.dog ? 'Cachorro' : 'Gato'}
⚖️ Peso atual: ${currentWeight.toStringAsFixed(1)} kg
🎯 Peso ideal: ${result.idealWeight.toStringAsFixed(1)} kg
📏 Faixa saudável: ${result.minIdealWeight.toStringAsFixed(1)}-${result.maxIdealWeight.toStringAsFixed(1)} kg

🏷️ Condição: ${result.currentClassification}
${result.shouldLoseWeight ? '📉 Perder: ${result.weightChange.abs().toStringAsFixed(1)} kg' : ''}${result.shouldGainWeight ? '📈 Ganhar: ${result.weightChange.toStringAsFixed(1)} kg' : ''}

_________________
Calculado por Calculei
by Agrimind
https://calculei.agrimind.com.br''',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main result
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(petEmoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'Peso Ideal',
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.idealWeight.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' kg',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Faixa: ${result.minIdealWeight.toStringAsFixed(1)}-${result.maxIdealWeight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Peso atual',
                  value: '${currentWeight.toStringAsFixed(1)} kg',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Condição',
                  value: result.currentClassification,
                ),
                if (result.shouldLoseWeight || result.shouldGainWeight) ...[
                  Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                  _DetailRow(
                    label: result.shouldLoseWeight ? 'A perder' : 'A ganhar',
                    value:
                        '${result.weightChange.abs().toStringAsFixed(1)} kg (${result.changePercentage.toStringAsFixed(1)}%)',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendations
          Text(
            'Recomendações',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
                    rec.startsWith('✅')
                        ? Icons.check_circle
                        : rec.startsWith('🎯')
                            ? Icons.gps_fixed
                            : rec.startsWith('⚠️')
                                ? Icons.warning
                                : Icons.info,
                    size: 18,
                    color: statusColor,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}


