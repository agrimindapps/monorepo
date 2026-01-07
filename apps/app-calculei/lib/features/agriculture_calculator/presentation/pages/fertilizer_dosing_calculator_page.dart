import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
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
  final _areaController = TextEditingController(text: '10');
  final _desiredRateController = TextEditingController(text: '100');

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Dosagem de Fertilizantes'),
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
                                Icons.agriculture,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Dosagem de Fertilizantes',
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
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Calcule a quantidade de produto comercial necessária baseado '
                            'no teor de nutrientes e taxa desejada de aplicação.',
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
                            // Fertilizer type selection
                            Text(
                              'Tipo de Fertilizante',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
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
                                return ChoiceChip(
                                  label: Text('$name ($nutrient ${content.toStringAsFixed(0)}%)'),
                                  selected: _fertilizerType == type,
                                  onSelected: (_) =>
                                      setState(() => _fertilizerType = type),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Area and desired rate
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
                                    label: 'Taxa desejada de nutriente',
                                    controller: _desiredRateController,
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

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular Dosagem',
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
                    _FertilizerDosingResultCard(
                      result: _result!,
                      fertilizerType: _fertilizerType,
                    ),
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

    final result = FertilizerDosingCalculator.calculate(
      areaHa: double.parse(_areaController.text),
      fertilizerType: _fertilizerType,
      desiredRateKgHa: double.parse(_desiredRateController.text),
    );

    setState(() => _result = result);
  }
}

class _FertilizerDosingResultCard extends StatelessWidget {
  final FertilizerDosingResult result;
  final FertilizerType fertilizerType;

  const _FertilizerDosingResultCard({
    required this.result,
    required this.fertilizerType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fertilizerName =
        FertilizerDosingCalculator.getFertilizerName(fertilizerType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado - $fertilizerName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ResultRow(
                    label: 'Produto necessário',
                    value: '${result.productKg.toStringAsFixed(1)} kg',
                    highlight: true,
                  ),
                  const Divider(height: 24),
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

            // Cost
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

            // Tips
            ExpansionTile(
              title: const Text('Dicas de aplicação'),
              leading: const Icon(Icons.tips_and_updates),
              children: result.applicationTips
                  .map(
                    (tip) => ListTile(
                      leading: const Icon(Icons.check, size: 20),
                      title: Text(tip, style: const TextStyle(fontSize: 14)),
                      dense: true,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShareText() {
    final fertilizerName =
        FertilizerDosingCalculator.getFertilizerName(fertilizerType);
    return '''
📋 Dosagem de Fertilizante - Calculei App

🧪 Fertilizante: $fertilizerName

📊 Resultado:
• Produto necessário: ${result.productKg.toStringAsFixed(1)} kg
• Por hectare: ${result.productKgHa.toStringAsFixed(1)} kg/ha
• Sacas (50kg): ${result.bagsNeeded}

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
