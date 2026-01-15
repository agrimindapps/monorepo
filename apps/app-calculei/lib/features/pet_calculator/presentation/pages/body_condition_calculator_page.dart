import 'package:flutter/material.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CalculatorPageLayout(
      title: 'Calculadora de Condição Corporal',
      subtitle: 'Escore ECC (1-9)',
      icon: Icons.fitness_center_outlined,
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

              // Calculate button
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.pet,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _BodyConditionResultCard(
                  result: _result!,
                  species: _species,
                  ribPalpation: _ribPalpation,
                  waistVisibility: _waistVisibility,
                  abdominalProfile: _abdominalProfile,
                ),
              ],
            ],
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                fontSize: 14,
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
                          ? CalculatorAccentColors.pet
                          : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? CalculatorAccentColors.pet
                            : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white 
                            : isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
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
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                descriptions[value - 1],
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        );
      },
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

  void _clear() {
    setState(() {
      _species = PetSpecies.dog;
      _ribPalpation = 3;
      _waistVisibility = 3;
      _abdominalProfile = 3;
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

class _BodyConditionResultCard extends StatelessWidget {
  final BodyConditionResult result;
  final PetSpecies species;
  final int ribPalpation;
  final int waistVisibility;
  final int abdominalProfile;

  const _BodyConditionResultCard({
    required this.result,
    required this.species,
    required this.ribPalpation,
    required this.waistVisibility,
    required this.abdominalProfile,
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
    final color = _getClassificationColor(result.classification);
    final petEmoji = species == PetSpecies.dog ? '🐕' : '🐈';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: color),
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
📋 Escore de Condição Corporal - Calculei App

🐾 Espécie: ${species == PetSpecies.dog ? 'Cachorro' : 'Gato'}

📥 Avaliação realizada:
• Palpação das costelas: $ribPalpation/5
• Visibilidade da cintura: $waistVisibility/5
• Perfil abdominal: $abdominalProfile/5

📊 ECC: ${result.bcs.toStringAsFixed(1)}/9
🏷️ Classificação: ${result.classificationText}

${result.description}

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
                      style: TextStyle(
                        fontSize: 48,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.classificationText,
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

          // Description
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.description,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recommendations
          Text(
            'Recomendações',
            style: TextStyle(
              fontSize: 16,
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
                    Icons.check_circle,
                    size: 18,
                    color: color,
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
