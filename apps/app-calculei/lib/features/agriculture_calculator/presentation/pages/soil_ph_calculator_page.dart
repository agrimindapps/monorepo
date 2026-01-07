import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/soil_ph_calculator.dart';

/// Página da calculadora de pH do solo e calagem
class SoilPhCalculatorPage extends StatefulWidget {
  const SoilPhCalculatorPage({super.key});

  @override
  State<SoilPhCalculatorPage> createState() => _SoilPhCalculatorPageState();
}

class _SoilPhCalculatorPageState extends State<SoilPhCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPhController = TextEditingController(text: '5.2');
  final _targetPhController = TextEditingController(text: '6.5');
  final _areaController = TextEditingController(text: '10');
  final _prntController = TextEditingController(text: '90');

  SoilTexture _texture = SoilTexture.loam;
  SoilPhResult? _result;

  @override
  void dispose() {
    _currentPhController.dispose();
    _targetPhController.dispose();
    _areaController.dispose();
    _prntController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de pH do Solo'),
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
                                Icons.science,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Calagem - Correção de pH',
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
                            'Calcule a quantidade de calcário necessária para corrigir '
                            'o pH do solo e melhorar a disponibilidade de nutrientes.',
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
                            // pH values
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: StandardInputField(
                                    label: 'pH atual',
                                    controller: _currentPhController,
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
                                    label: 'pH alvo',
                                    controller: _targetPhController,
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

                            const SizedBox(height: 20),

                            // Soil texture
                            Text(
                              'Textura do solo',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: SoilTexture.values.map((tex) {
                                return ChoiceChip(
                                  label: Text(SoilPhCalculator.getTextureName(tex)),
                                  selected: _texture == tex,
                                  onSelected: (_) =>
                                      setState(() => _texture = tex),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Area and PRNT
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
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'PRNT do calcário',
                                    controller: _prntController,
                                    suffix: '%',
                                    helperText: 'Poder de Neutralização',
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
                              label: 'Calcular Calagem',
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
                    _SoilPhResultCard(
                      result: _result!,
                      texture: _texture,
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

    final result = SoilPhCalculator.calculate(
      currentPh: double.parse(_currentPhController.text),
      targetPh: double.parse(_targetPhController.text),
      soilTexture: _texture,
      areaHa: double.parse(_areaController.text),
      prnt: double.tryParse(_prntController.text) ?? 90.0,
    );

    setState(() => _result = result);
  }
}

class _SoilPhResultCard extends StatelessWidget {
  final SoilPhResult result;
  final SoilTexture texture;

  const _SoilPhResultCard({
    required this.result,
    required this.texture,
  });

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
                  'Recomendação de Calagem',
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

            if (result.limeNeededKg == 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Solo já está no pH adequado!\nNão necessita calagem.',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
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
                      label: 'Calcário necessário',
                      value: '${result.limeTons.toStringAsFixed(2)} ton',
                      highlight: true,
                    ),
                    const Divider(height: 24),
                    _ResultRow(
                      label: 'Por hectare',
                      value: '${result.limeKgHa.toStringAsFixed(0)} kg/ha',
                    ),
                    const SizedBox(height: 8),
                    _ResultRow(
                      label: 'Correção de pH',
                      value: '+${result.phDifference.toStringAsFixed(1)}',
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

              // Recommendations
              ExpansionTile(
                title: const Text('Recomendações de aplicação'),
                leading: const Icon(Icons.lightbulb),
                initiallyExpanded: true,
                children: result.recommendations
                    .map(
                      (rec) => ListTile(
                        leading: const Icon(Icons.check, size: 20),
                        title: Text(rec, style: const TextStyle(fontSize: 14)),
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatShareText() {
    final textureName = SoilPhCalculator.getTextureName(texture);
    
    if (result.limeNeededKg == 0) {
      return '''
📋 Cálculo de Calagem - Calculei App

✅ Solo já está no pH adequado!
Não necessita calagem.

_________________
Calculado por Calculei
by Agrimind''';
    }

    return '''
📋 Cálculo de Calagem - Calculei App

📏 Textura: $textureName
📊 Correção: +${result.phDifference.toStringAsFixed(1)} de pH

🧪 Resultado:
• Calcário necessário: ${result.limeTons.toStringAsFixed(2)} toneladas
• Por hectare: ${result.limeKgHa.toStringAsFixed(0)} kg/ha

💰 Custo estimado: R\$ ${result.estimatedCost.toStringAsFixed(2)}

💡 Aplicar 60-90 dias antes do plantio e incorporar ao solo.

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
