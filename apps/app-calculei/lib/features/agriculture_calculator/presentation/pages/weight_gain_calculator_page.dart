import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/weight_gain_calculator.dart';

/// Página da calculadora de Ganho de Peso Animal
class WeightGainCalculatorPage extends StatefulWidget {
  const WeightGainCalculatorPage({super.key});

  @override
  State<WeightGainCalculatorPage> createState() =>
      _WeightGainCalculatorPageState();
}

class _WeightGainCalculatorPageState extends State<WeightGainCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _initialWeightController = TextEditingController(text: '250');
  final _targetWeightController = TextEditingController(text: '450');
  final _dailyGainController = TextEditingController(text: '1.2');

  AnimalType _animalType = AnimalType.cattle;
  WeightGainResult? _result;

  @override
  void dispose() {
    _initialWeightController.dispose();
    _targetWeightController.dispose();
    _dailyGainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Ganho de Peso Animal',
      subtitle: 'Performance Animal',
      icon: Icons.trending_up,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'saude',
      maxContentWidth: 700,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share handled by ShareButton in result card
            },
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Animal type selection
                Text(
                  'Tipo de Animal',
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
                  children: AnimalType.values.map((type) {
                    return DarkChoiceChip(
                      label: WeightGainCalculator.getAnimalName(type),
                      isSelected: _animalType == type,
                      onSelected: () =>
                          setState(() => _animalType = type),
                      accentColor: CalculatorAccentColors.agriculture,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Input fields
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 160,
                      child: _DarkInputField(
                        label: 'Peso inicial',
                        controller: _initialWeightController,
                        suffix: 'kg',
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
                      width: 160,
                      child: _DarkInputField(
                        label: 'Peso alvo',
                        controller: _targetWeightController,
                        suffix: 'kg',
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
                      width: 200,
                      child: _DarkInputField(
                        label: 'Ganho diário esperado',
                        controller: _dailyGainController,
                        suffix: 'kg/dia',
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
                const SizedBox(height: 28),

                // Action buttons
                CalculatorActionButtons(
                  onCalculate: _calculate,
                  onClear: _clear,
                  accentColor: CalculatorAccentColors.agriculture,
                ),

                // Result card
                if (_result != null) ...[
                  const SizedBox(height: 28),
                  _WeightGainResultCard(
                    result: _result!,
                    animalType: _animalType,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = WeightGainCalculator.calculate(
      initialWeight: double.parse(_initialWeightController.text),
      targetWeight: double.parse(_targetWeightController.text),
      dailyGainKg: double.parse(_dailyGainController.text),
      animalType: _animalType,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _initialWeightController.text = '250';
    _targetWeightController.text = '450';
    _dailyGainController.text = '1.2';
    setState(() {
      _animalType = AnimalType.cattle;
      _result = null;
    });
  }
}

class _WeightGainResultCard extends StatelessWidget {
  final WeightGainResult result;
  final AnimalType animalType;

  const _WeightGainResultCard({
    required this.result,
    required this.animalType,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    const accentColor = CalculatorAccentColors.agriculture;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.insights,
              color: accentColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Previsão de Ganho de Peso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ShareButton(text: _formatShareText(dateFormatter)),
          ],
        ),
        const SizedBox(height: 20),

        // Main results
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              _ResultBox(
                label: 'Tempo necessário',
                value: '${result.daysNeeded} dias',
                subtitle: '(${result.weeksNeeded} semanas)',
                color: accentColor,
                highlight: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ResultBox(
                      label: 'Ganho total',
                      value: '${result.totalGain.toStringAsFixed(1)} kg',
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ResultBox(
                      label: 'Conversão',
                      value: '${result.feedEfficiency.toStringAsFixed(1)}:1',
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Additional details
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(
                label: 'Data estimada',
                value: dateFormatter.format(result.estimatedDate),
              ),
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Consumo de ração',
                value: '${result.totalFeedKg.toStringAsFixed(0)} kg',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                label: 'Custo estimado',
                value: 'R\$ ${result.feedCost.toStringAsFixed(2)}',
                highlight: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recommendations
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.withValues(alpha: 0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recomendações',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...result.recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatShareText(DateFormat formatter) {
    final animalName = WeightGainCalculator.getAnimalName(animalType);
    return '''
📋 Ganho de Peso - Calculei App

🐄 Animal: $animalName

📊 Resultado:
• Tempo necessário: ${result.daysNeeded} dias (${result.weeksNeeded} semanas)
• Ganho total: ${result.totalGain.toStringAsFixed(1)} kg
• Data estimada: ${formatter.format(result.estimatedDate)}
• Conversão alimentar: ${result.feedEfficiency.toStringAsFixed(1)}:1

💰 Custo com ração: R\$ ${result.feedCost.toStringAsFixed(2)}

_________________
Calculado por Calculei
by Agrimind''';
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final bool highlight;

  const _ResultBox({
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white.withValues(alpha: 0.8),
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Dark theme input field widget
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
                color: CalculatorAccentColors.agriculture,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
