import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/pet_ideal_weight_calculator.dart';

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
                                Icons.fitness_center,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Meta de Peso Saudável',
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
                            'Calcule o peso ideal do seu pet baseado em ECC (Escore de Condição Corporal) e porte.',
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

                            // Breed Size (only for dogs)
                            if (_species == PetSpecies.dog) ...[
                              Text(
                                'Porte do Cachorro',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: BreedSize.values.map((size) {
                                  return ChoiceChip(
                                    label: Text(
                                      PetIdealWeightCalculator
                                          .getBreedSizeDescription(size),
                                    ),
                                    selected: _breedSize == size,
                                    onSelected: (_) =>
                                        setState(() => _breedSize = size),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Current Weight
                            StandardInputField(
                              label: 'Peso atual',
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

                            // BCS Score
                            Text(
                              'Escore de Condição Corporal (BCS)',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            Row(
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
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.grey[400]!,
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
                                            : Colors.grey[700],
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getBcsDescription(_bcsScore),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Peso Ideal',
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
                    _PetIdealWeightResultCard(
                      result: _result!,
                      species: _species,
                      currentWeight: double.parse(_weightController.text),
                    ),
                ],
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor();
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
                    statusColor.withValues(alpha: 0.2),
                    statusColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.5),
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
                      color: statusColor.withValues(alpha: 0.8),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        result.idealWeight.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          ' kg',
                          style: TextStyle(fontSize: 18, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faixa: ${result.minIdealWeight.toStringAsFixed(1)}-${result.maxIdealWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(color: statusColor),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Peso atual',
                    value: '${currentWeight.toStringAsFixed(1)} kg',
                  ),
                  const Divider(height: 16),
                  _DetailRow(
                    label: 'Condição',
                    value: result.currentClassification,
                  ),
                  if (result.shouldLoseWeight || result.shouldGainWeight) ...[
                    const Divider(height: 16),
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
