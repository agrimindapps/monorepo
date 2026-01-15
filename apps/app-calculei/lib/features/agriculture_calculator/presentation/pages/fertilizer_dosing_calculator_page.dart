import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/fertilizer_dosing_calculator.dart';

/// Página da calculadora de dosagem de fertilizantes
class FertilizerDosingCalculatorPage extends StatefulWidget {
  const FertilizerDosingCalculatorPage({super.key});

  @override
  State<FertilizerDosingCalculatorPage> createState() =>
      _FertilizerDosingCalculatorPageState();
}

class _FertilizerDosingCalculatorPageState
    extends State<FertilizerDosingCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _desiredRateController = TextEditingController();

  FertilizerType _fertilizerType = FertilizerType.urea;
  FertilizerDosingResult? _result;

  @override
  void dispose() {
    _areaController.dispose();
    _desiredRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Dosagem de Fertilizantes',
      subtitle: 'Aplicação de Nutrientes',
      icon: Icons.agriculture,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
      maxContentWidth: 600,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fertilizer type selection
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    'Tipo de Fertilizante',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FertilizerType.values.map((type) {
                  final name = FertilizerDosingCalculator
                      .getFertilizerName(type);
                  final nutrient = FertilizerDosingCalculator
                      .getNutrientName(type);
                  final content = FertilizerDosingCalculator
                      .getNutrientContent(type);
                  return DarkChoiceChip(
                    label: '$name ($nutrient ${content.toStringAsFixed(0)}%)',
                    isSelected: _fertilizerType == type,
                    onSelected: () =>
                        setState(() => _fertilizerType = type),
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Area and desired rate
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: AdaptiveInputField(
                      label: 'Área',
                      controller: _areaController,
                      hintText: 'Ex: 10',
                      suffix: 'ha',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: AdaptiveInputField(
                      label: 'Taxa desejada de nutriente',
                      controller: _desiredRateController,
                      hintText: 'Ex: 100',
                      suffix: 'kg/ha',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.agriculture,
              ),

              const SizedBox(height: 24),

              if (_result != null)
                _FertilizerDosingResultCard(
                  result: _result!,
                  fertilizerType: _fertilizerType,
                  area: double.tryParse(_areaController.text) ?? 0,
                  desiredRate: double.tryParse(_desiredRateController.text) ?? 0,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = FertilizerDosingCalculator.calculate(
      areaHa: double.parse(_areaController.text),
      fertilizerType: _fertilizerType,
      desiredRateKgHa: double.parse(_desiredRateController.text),
    );

    setState(() => _result = result);
  }

  void _clear() {
    _areaController.clear();
    _desiredRateController.clear();
    setState(() {
      _fertilizerType = FertilizerType.urea;
      _result = null;
    });
  }
}

class _FertilizerDosingResultCard extends StatelessWidget {
  final FertilizerDosingResult result;
  final FertilizerType fertilizerType;
  final double area;
  final double desiredRate;

  const _FertilizerDosingResultCard({
    required this.result,
    required this.fertilizerType,
    required this.area,
    required this.desiredRate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fertilizerName =
        FertilizerDosingCalculator.getFertilizerName(fertilizerType);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Resultado - $fertilizerName',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ShareButton(
                text: _formatShareText(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main results
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Produto necessário',
                  value: '${result.productKg.toStringAsFixed(1)} kg',
                  highlight: true,
                ),
                Divider(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  height: 24,
                ),
                _ResultRow(
                  label: 'Quantidade por hectare',
                  value: '${result.productKgHa.toStringAsFixed(1)} kg/ha',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: 'Sacas (50kg)',
                  value: '${result.bagsNeeded} sacas',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: 'Nutriente puro total',
                  value: '${result.totalNutrientKg.toStringAsFixed(1)} kg',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tips
          Text(
            'Dicas de aplicação',
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...result.applicationTips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: CalculatorAccentColors.agriculture,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                        fontSize: 14,
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

  String _formatShareText() {
    final fertilizerName =
        FertilizerDosingCalculator.getFertilizerName(fertilizerType);
    return '''
📋 Dosagem de Fertilizante - Calculei App

🧪 Fertilizante: $fertilizerName

📥 Dados informados:
• Área: ${area.toStringAsFixed(1)} ha
• Dose desejada: ${desiredRate.toStringAsFixed(1)} kg/ha

📊 Resultado:
• Produto necessário: ${result.productKg.toStringAsFixed(1)} kg
• Por hectare: ${result.productKgHa.toStringAsFixed(1)} kg/ha
• Sacas (50kg): ${result.bagsNeeded}

_________________
Calculado por Calculei
by Agrimind''';
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white.withValues(alpha: highlight ? 0.9 : 0.7) : Colors.black.withValues(alpha: highlight ? 0.9 : 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight 
                ? CalculatorAccentColors.agriculture 
                : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9)),
          ),
        ),
      ],
    );
  }
}


