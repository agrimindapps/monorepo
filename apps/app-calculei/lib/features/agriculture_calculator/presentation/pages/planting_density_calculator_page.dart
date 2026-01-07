import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/planting_density_calculator.dart';

/// Página da calculadora de densidade de plantio
class PlantingDensityCalculatorPage extends StatefulWidget {
  const PlantingDensityCalculatorPage({super.key});

  @override
  State<PlantingDensityCalculatorPage> createState() =>
      _PlantingDensityCalculatorPageState();
}

class _PlantingDensityCalculatorPageState
    extends State<PlantingDensityCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _rowSpacingController = TextEditingController(text: '0.9');
  final _plantSpacingController = TextEditingController(text: '0.2');
  final _areaController = TextEditingController(text: '10');
  final _costPerPlantController = TextEditingController(text: '0');

  PlantingDensityResult? _result;

  @override
  void dispose() {
    _rowSpacingController.dispose();
    _plantSpacingController.dispose();
    _areaController.dispose();
    _costPerPlantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Densidade de Plantio'),
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
                              Icon(
                                Icons.grid_4x4,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Densidade de Plantio',
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
                            'Calcule o número de plantas por hectare e total para sua área '
                            'baseado no espaçamento entre linhas e plantas.',
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
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Espaçamento entre linhas',
                                    controller: _rowSpacingController,
                                    suffix: 'm',
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
                                    label: 'Espaçamento entre plantas',
                                    controller: _plantSpacingController,
                                    suffix: 'm',
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
                                    label: 'Área total',
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
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Custo por muda (opcional)',
                                    controller: _costPerPlantController,
                                    suffix: 'R\$',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            CalculatorButton(
                              label: 'Calcular Densidade',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_result != null) _PlantingDensityResultCard(result: _result!),
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

    final result = PlantingDensityCalculator.calculate(
      rowSpacingM: double.parse(_rowSpacingController.text),
      plantSpacingM: double.parse(_plantSpacingController.text),
      areaHa: double.parse(_areaController.text),
      costPerPlant: double.tryParse(_costPerPlantController.text) ?? 0.0,
    );

    setState(() => _result = result);
  }
}

class _PlantingDensityResultCard extends StatelessWidget {
  final PlantingDensityResult result;

  const _PlantingDensityResultCard({required this.result});

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
                Text(
                  'Resultado da Densidade',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ResultRow(
                    label: 'Plantas por hectare',
                    value: '${result.plantsPerHa}',
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: 'Total de plantas',
                    value: '${result.totalPlants}',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Área por planta',
                    value: '${result.areaPerPlant} m²',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Metros lineares/ha',
                    value: '${result.linearMetersHa.toStringAsFixed(0)} m',
                  ),
                ],
              ),
            ),
            if (result.estimatedCost > 0) ...[
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
                    const Text('Custo estimado com mudas:'),
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
            ],
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Recomendações'),
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
    return '''
📋 Densidade de Plantio - Calculei App

📊 Resultado:
• Plantas por hectare: ${result.plantsPerHa}
• Total de plantas: ${result.totalPlants}
• Área por planta: ${result.areaPerPlant} m²
${result.estimatedCost > 0 ? '\n💰 Custo com mudas: R\$ ${result.estimatedCost.toStringAsFixed(2)}' : ''}

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
