import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/calculators/proteinas_diarias_calculator.dart';

/// Página da calculadora de proteínas diárias
class ProteinasDiariasCalculatorPage extends StatefulWidget {
  const ProteinasDiariasCalculatorPage({super.key});

  @override
  State<ProteinasDiariasCalculatorPage> createState() =>
      _ProteinasDiariasCalculatorPageState();
}

class _ProteinasDiariasCalculatorPageState
    extends State<ProteinasDiariasCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  ActivityLevel _activityLevel = ActivityLevel.moderate;
  DailyProteinResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CalculatorPageLayout(
      title: 'Proteínas Diárias',
      subtitle: 'Necessidade diária de proteína',
      icon: Icons.fitness_center,
      accentColor: CalculatorAccentColors.health,
      currentCategory: 'saude',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () => Share.share(
              ShareFormatter.formatProteinasDiariasCalculation(
                weight: double.parse(_weightController.text),
                activityLevel: _getActivityLevelText(_activityLevel),
                minProtein: _result!.minProtein,
                maxProtein: _result!.maxProtein,
              ),
            ),
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
              // Weight input
              AdaptiveInputField(
                label: 'Peso',
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
                  if (num == null || num <= 0 || num > 500) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Activity level selection
              Text(
                'Nível de atividade física',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              ...ActivityLevel.values.map((level) {
                final isSelected = _activityLevel == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ActivityLevelOption(
                    title: _getActivityLevelText(level),
                    description: _getActivityLevelDescription(level),
                    isSelected: isSelected,
                    onTap: () => setState(() => _activityLevel = level),
                    isDark: isDark,
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.health,
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 32),
                _ProteinResultCard(result: _result!, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getActivityLevelText(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Sedentário',
      ActivityLevel.light => 'Atividade Leve',
      ActivityLevel.moderate => 'Atividade Moderada',
      ActivityLevel.veryActive => 'Muito Ativo',
      ActivityLevel.extreme => 'Atividade Extrema',
    };
  }

  String _getActivityLevelDescription(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.sedentary => 'Pouco ou nenhum exercício',
      ActivityLevel.light => '1-3 dias/semana',
      ActivityLevel.moderate => '3-5 dias/semana',
      ActivityLevel.veryActive => '6-7 dias/semana intenso',
      ActivityLevel.extreme => 'Atleta ou trabalho físico pesado',
    };
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = ProteinarDiariasCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      activityLevel: _activityLevel,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.clear();
    setState(() {
      _activityLevel = ActivityLevel.moderate;
      _result = null;
    });
  }
}

/// Activity level option button
class _ActivityLevelOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ActivityLevelOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;

    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.3)),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(
                                alpha: isSelected ? 1.0 : 0.8,
                              )
                            : Colors.black.withValues(
                                alpha: isSelected ? 1.0 : 0.8,
                              ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProteinResultCard extends StatelessWidget {
  final DailyProteinResult result;
  final bool isDark;

  const _ProteinResultCard({required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.health;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Protein range
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  '${result.minProtein}-${result.maxProtein}g',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const Text(
                  'Proteína por dia',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Activity level chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.activityLevelText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.recommendation,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Protein sources examples
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 18,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fontes de proteína',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.black.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProteinSource(
                  label: 'Peito de frango',
                  amount: '31g/100g',
                  isDark: isDark,
                ),
                _ProteinSource(
                  label: 'Ovo',
                  amount: '6g por unidade',
                  isDark: isDark,
                ),
                _ProteinSource(
                  label: 'Feijão',
                  amount: '9g por xícara',
                  isDark: isDark,
                ),
                _ProteinSource(
                  label: 'Whey protein',
                  amount: '20-30g por dose',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProteinSource extends StatelessWidget {
  final String label;
  final String amount;
  final bool isDark;

  const _ProteinSource({
    required this.label,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
