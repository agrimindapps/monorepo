import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/yield_prediction_calculator.dart';

/// Página da calculadora de previsão de produtividade
class YieldPredictionCalculatorPage extends StatefulWidget {
  const YieldPredictionCalculatorPage({super.key});

  @override
  State<YieldPredictionCalculatorPage> createState() =>
      _YieldPredictionCalculatorPageState();
}

class _YieldPredictionCalculatorPageState
    extends State<YieldPredictionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController(text: '10');
  final _yieldController = TextEditingController(text: '5000');
  final _lossController = TextEditingController(text: '5');

  CropType _cropType = CropType.corn;
  YieldPredictionResult? _result;

  @override
  void dispose() {
    _areaController.dispose();
    _yieldController.dispose();
    _lossController.dispose();
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
                              Text('Previsão de Produtividade',
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
                            'Estime a produção líquida da sua lavoura considerando '
                            'perdas de colheita e pós-colheita.',
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
                            Text('Cultura',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: CropType.values.map((crop) {
                                return ChoiceChip(
                                  label: Text(YieldPredictionCalculator.getCropName(crop)),
                                  selected: _cropType == crop,
                                  onSelected: (_) =>
                                      setState(() => _cropType = crop),
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
                                    label: 'Área',
                                    controller: _areaController,
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
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Produtividade esperada',
                                    controller: _yieldController,
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
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
                                    label: 'Perdas estimadas',
                                    controller: _lossController,
                                    suffix: '%',
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
                              label: 'Calcular Produção',
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
                    _YieldResultCard(result: _result!, cropType: _cropType),
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

    final result = YieldPredictionCalculator.calculate(
      cropType: _cropType,
      areaHa: double.parse(_areaController.text),
      expectedYieldKgHa: double.parse(_yieldController.text),
      lossPercentage: double.parse(_lossController.text),
    );

    setState(() => _result = result);
  }
}

class _YieldResultCard extends StatelessWidget {
  final YieldPredictionResult result;
  final CropType cropType;

  const _YieldResultCard({required this.result, required this.cropType});

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
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Previsão de Produção',
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
                    label: 'Produção líquida',
                    value: '${result.netYieldTon.toStringAsFixed(2)} ton',
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: 'Produção bruta',
                    value: '${result.grossYieldTon.toStringAsFixed(2)} ton',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Perdas',
                    value: '${result.lossKg.toStringAsFixed(0)} kg',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Produtividade líquida',
                    value: '${result.netYieldKgHa.toStringAsFixed(0)} kg/ha',
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
                  const Text('Valor estimado:'),
                  Text(
                    'R\$ ${result.estimatedValue.toStringAsFixed(2)}',
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

  String _formatShareText() {
    final cropName = YieldPredictionCalculator.getCropName(cropType);
    return '''
📋 Previsão de Produtividade - Calculei App

🌾 Cultura: $cropName

📊 Resultado:
• Produção líquida: ${result.netYieldTon.toStringAsFixed(2)} toneladas
• Produção bruta: ${result.grossYieldTon.toStringAsFixed(2)} toneladas
• Perdas: ${result.lossKg.toStringAsFixed(0)} kg

💰 Valor estimado: R\$ ${result.estimatedValue.toStringAsFixed(2)}

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
