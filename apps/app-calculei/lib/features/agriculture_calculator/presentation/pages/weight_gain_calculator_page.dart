import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/weight_gain_calculator.dart';

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
                              Icon(Icons.trending_up,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text('Ganho de Peso Animal',
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
                            'Estime o tempo necessário para atingir o peso alvo e '
                            'o custo com alimentação baseado no ganho diário.',
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
                                  label: Text(
                                      WeightGainCalculator.getAnimalName(type)),
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
                                  width: 150,
                                  child: StandardInputField(
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
                                  width: 180,
                                  child: StandardInputField(
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
                            const SizedBox(height: 24),
                            CalculatorButton(
                              label: 'Calcular Ganho',
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
                    _WeightGainResultCard(
                        result: _result!, animalType: _animalType),
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

    final result = WeightGainCalculator.calculate(
      initialWeight: double.parse(_initialWeightController.text),
      targetWeight: double.parse(_targetWeightController.text),
      dailyGainKg: double.parse(_dailyGainController.text),
      animalType: _animalType,
    );

    setState(() => _result = result);
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
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Previsão de Ganho de Peso',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                ShareButton(text: _formatShareText(dateFormatter)),
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
                    label: 'Tempo necessário',
                    value: '${result.daysNeeded} dias (${result.weeksNeeded} semanas)',
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: 'Ganho total',
                    value: '${result.totalGain.toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Data estimada',
                    value: dateFormatter.format(result.estimatedDate),
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Conversão alimentar',
                    value: '${result.feedEfficiency.toStringAsFixed(1)}:1',
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consumo de ração:'),
                      Text(
                        '${result.totalFeedKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Custo estimado:'),
                      Text(
                        'R\$ ${result.feedCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Recomendações'),
              leading: const Icon(Icons.lightbulb),
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
