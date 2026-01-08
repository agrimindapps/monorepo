import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
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
    return CalculatorPageLayout(
      title: 'Calorias Diárias do Pet',
      subtitle: 'Necessidade Calórica',
      icon: Icons.local_fire_department,
      accentColor: CalculatorAccentColors.pet,
      categoryName: 'Pet',
      instructions: 'Calcule a quantidade ideal de calorias que seu pet precisa diariamente '
          'baseado em peso, idade, atividade e se é castrado.',
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
                      onTap: () => setState(() => _species = PetSpecies.dog),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SpeciesButton(
                      label: 'Gato',
                      emoji: '🐈',
                      isSelected: _species == PetSpecies.cat,
                      onTap: () => setState(() => _species = PetSpecies.cat),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weight
              _DarkInputField(
                label: 'Peso do pet',
                controller: _weightController,
                suffix: 'kg',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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

              // Life Stage
              Text(
                'Estágio de Vida',
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
                children: LifeStage.values.map((stage) {
                  return ChoiceChip(
                    label: Text(_getLifeStageLabel(stage)),
                    selected: _lifeStage == stage,
                    onSelected: (_) => setState(() => _lifeStage = stage),
                    selectedColor: CalculatorAccentColors.pet.withValues(alpha: 0.3),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    labelStyle: TextStyle(
                      color: _lifeStage == stage
                          ? CalculatorAccentColors.pet
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    side: BorderSide(
                      color: _lifeStage == stage
                          ? CalculatorAccentColors.pet
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Activity Level
              Text(
                'Nível de Atividade',
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
                children: ActivityLevel.values.map((level) {
                  return ChoiceChip(
                    label: Text(_getActivityLabel(level)),
                    selected: _activityLevel == level,
                    onSelected: (_) => setState(() => _activityLevel = level),
                    selectedColor: CalculatorAccentColors.pet.withValues(alpha: 0.3),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    labelStyle: TextStyle(
                      color: _activityLevel == level
                          ? CalculatorAccentColors.pet
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                    side: BorderSide(
                      color: _activityLevel == level
                          ? CalculatorAccentColors.pet
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Neutered
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    'Pet castrado/esterilizado',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  subtitle: Text(
                    'Pets castrados têm menor gasto energético',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  value: _isNeutered,
                  onChanged: (value) =>
                      setState(() => _isNeutered = value ?? false),
                  activeColor: CalculatorAccentColors.pet,
                  checkColor: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Calculate button
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CalculatorAccentColors.pet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      'Calcular Calorias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 32),
                _CaloricNeedsResultCard(
                  result: _result!,
                  species: _species,
                  weight: double.parse(_weightController.text),
                ),
              ],
            ],
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
    const accentColor = CalculatorAccentColors.pet;
    final petEmoji = species == PetSpecies.dog ? '🐕' : '🐈';

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
                  color: Colors.white.withValues(alpha: 0.9),
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
              color: accentColor.withValues(alpha: 0.15),
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
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' kcal/dia',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      '${result.foodAmountGrams.toStringAsFixed(0)}g de ração/dia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'RER (Repouso)',
                  value: '${result.rer.toStringAsFixed(0)} kcal',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Estágio',
                  value: result.lifeStageText,
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
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
                    color: accentColor,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
