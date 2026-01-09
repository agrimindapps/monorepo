import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/feed_calculator.dart';

class FeedCalculatorPage extends StatefulWidget {
  const FeedCalculatorPage({super.key});

  @override
  State<FeedCalculatorPage> createState() => _FeedCalculatorPageState();
}

class _FeedCalculatorPageState extends State<FeedCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '450');
  final _numAnimalsController = TextEditingController(text: '10');
  final _daysController = TextEditingController(text: '90');

  AnimalType _animalType = AnimalType.cattle;
  FeedCalculatorResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _numAnimalsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Cálculo de Ração',
      subtitle: 'Nutrição Animal',
      icon: Icons.pets,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
      maxContentWidth: 600,
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
                    label: FeedCalculator.getAnimalName(type),
                    isSelected: _animalType == type,
                    onSelected: () =>
                        setState(() => _animalType = type),
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Input fields for weight, number of animals, and days
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Peso médio',
                      controller: _weightController,
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
                    width: 150,
                    child: _DarkInputField(
                      label: 'Nº de animais',
                      controller: _numAnimalsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Obrigatório' : null,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Período',
                      controller: _daysController,
                      suffix: 'dias',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
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
                _FeedResultCard(result: _result!, animalType: _animalType),
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

    final result = FeedCalculator.calculate(
      animalType: _animalType,
      weightKg: double.parse(_weightController.text),
      numAnimals: int.parse(_numAnimalsController.text),
      days: int.parse(_daysController.text),
    );

    setState(() => _result = result);
  }

  void _clear() {
    _weightController.text = '450';
    _numAnimalsController.text = '10';
    _daysController.text = '90';
    setState(() {
      _animalType = AnimalType.cattle;
      _result = null;
    });
  }
}

class _FeedResultCard extends StatelessWidget {
  final FeedCalculatorResult result;
  final AnimalType animalType;

  const _FeedResultCard({required this.result, required this.animalType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(
                Icons.grass,
                color: CalculatorAccentColors.agriculture,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Necessidade de Ração',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ShareButton(text: _formatShareText()),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalculatorAccentColors.agriculture.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CalculatorAccentColors.agriculture.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Total necessário',
                  value: '${result.totalFeedTons.toStringAsFixed(2)} ton',
                  highlight: true,
                ),
                const Divider(height: 24),
                _ResultRow(
                  label: 'Consumo diário/animal',
                  value: '${result.dailyFeedPerAnimal.toStringAsFixed(2)} kg',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: 'Consumo diário total',
                  value: '${result.dailyFeedTotal.toStringAsFixed(1)} kg',
                ),
                const SizedBox(height: 8),
                _ResultRow(
                  label: 'Sacas (60kg)',
                  value: '${result.bagsNeeded} sacas',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custo estimado:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'R\$ ${result.estimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(
              expansionTileTheme: const ExpansionTileThemeData(
                collapsedBackgroundColor: Colors.white,
                backgroundColor: Colors.white,
              ),
            ),
            child: ExpansionTile(
              title: const Text(
                'Dicas de manejo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: const Icon(Icons.tips_and_updates),
              children: result.recommendations
                  .map((rec) => ListTile(
                        leading: const Icon(Icons.check, size: 20),
                        title: Text(
                          rec,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                        dense: true,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShareText() {
    final animalName = FeedCalculator.getAnimalName(animalType);
    return '''
📋 Cálculo de Ração - Calculei App

🐄 Animal: $animalName

📊 Resultado:
• Total necessário: ${result.totalFeedTons.toStringAsFixed(2)} toneladas
• Consumo diário/animal: ${result.dailyFeedPerAnimal.toStringAsFixed(2)} kg
• Sacas (60kg): ${result.bagsNeeded}

💰 Custo estimado: R\$ ${result.estimatedCost.toStringAsFixed(2)}

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: Colors.white.withValues(alpha: highlight ? 1 : 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight 
                ? CalculatorAccentColors.agriculture 
                : Colors.white,
          ),
        ),
      ],
    );
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
