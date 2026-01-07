import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
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
    return Scaffold(
      appBar: const CalculatorAppBar(),
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
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pets,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text('Cálculo de Ração Animal',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      )),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule a quantidade de ração necessária baseado no peso, '
                            'número de animais e período de alimentação.',
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Tipo de Animal',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: AnimalType.values.map((type) {
                                return ChoiceChip(
                                  label: Text(FeedCalculator.getAnimalName(type)),
                                  selected: _animalType == type,
                                  onSelected: (_) =>
                                      setState(() => _animalType = type),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
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
                                  child: StandardInputField(
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
                                  child: StandardInputField(
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
                            const SizedBox(height: 24),
                            CalculatorButton(
                              label: 'Calcular Ração',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_result != null)
                    _FeedResultCard(result: _result!, animalType: _animalType),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = FeedCalculator.calculate(
      animalType: _animalType,
      weightKg: double.parse(_weightController.text),
      numAnimals: int.parse(_numAnimalsController.text),
      days: int.parse(_daysController.text),
    );

    setState(() => _result = result);
  }
}

class _FeedResultCard extends StatelessWidget {
  final FeedCalculatorResult result;
  final AnimalType animalType;

  const _FeedResultCard({required this.result, required this.animalType});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.grass, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Necessidade de Ração',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                ShareButton(text: _formatShareText()),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
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
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Custo estimado:'),
                  Text(
                    'R\$ ${result.estimatedCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Dicas de manejo'),
              leading: const Icon(Icons.tips_and_updates),
              children: result.recommendations
                  .map((rec) => ListTile(
                        leading: const Icon(Icons.check, size: 20),
                        title: Text(rec, style: const TextStyle(fontSize: 14)),
                        dense: true,
                      ))
                  .toList(),
            ),
          ],
        ),
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
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
