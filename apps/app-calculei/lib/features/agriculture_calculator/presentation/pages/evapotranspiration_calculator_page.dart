import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/calculator_app_bar.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/evapotranspiration_calculator.dart';

class EvapotranspirationCalculatorPage extends StatefulWidget {
  const EvapotranspirationCalculatorPage({super.key});

  @override
  State<EvapotranspirationCalculatorPage> createState() =>
      _EvapotranspirationCalculatorPageState();
}

class _EvapotranspirationCalculatorPageState
    extends State<EvapotranspirationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController(text: '28');
  final _humidityController = TextEditingController(text: '60');
  final _windSpeedController = TextEditingController(text: '10');
  final _solarRadiationController = TextEditingController(text: '20');

  EvapotranspirationResult? _result;

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    _windSpeedController.dispose();
    _solarRadiationController.dispose();
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
                              Icon(Icons.water_drop,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                              const SizedBox(width: 8),
                              Text('Evapotranspiração de Referência',
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
                            'Estime a evapotranspiração de referência (ETo) e as '
                            'necessidades hídricas das culturas.',
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
                            Text('Dados Meteorológicos',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Temperatura média',
                                    controller: _temperatureController,
                                    suffix: '°C',
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
                                    label: 'Umidade relativa',
                                    controller: _humidityController,
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
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Velocidade do vento',
                                    controller: _windSpeedController,
                                    suffix: 'km/h',
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
                                    label: 'Radiação solar',
                                    controller: _solarRadiationController,
                                    suffix: 'MJ/m²',
                                    helperText: 'Valores típicos: 15-25',
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
                              label: 'Calcular ETo',
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
                    _EvapotranspirationResultCard(result: _result!),
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

    final result = EvapotranspirationCalculator.calculate(
      temperatureC: double.parse(_temperatureController.text),
      humidityPercent: double.parse(_humidityController.text),
      windSpeedKmH: double.parse(_windSpeedController.text),
      solarRadiationMJm2: double.parse(_solarRadiationController.text),
    );

    setState(() => _result = result);
  }
}

class _EvapotranspirationResultCard extends StatelessWidget {
  final EvapotranspirationResult result;

  const _EvapotranspirationResultCard({required this.result});

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
                Icon(Icons.opacity, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Evapotranspiração de Referência',
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
                    label: 'ETo',
                    value: '${result.etoMmDay.toStringAsFixed(2)} mm/dia',
                    highlight: true,
                  ),
                  const Divider(height: 24),
                  _ResultRow(
                    label: 'ETo semanal',
                    value: '${result.etoWeekly.toStringAsFixed(1)} mm',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'ETo mensal',
                    value: '${result.etoMonthly.toStringAsFixed(1)} mm',
                  ),
                  const SizedBox(height: 8),
                  _ResultRow(
                    label: 'Demanda',
                    value: result.demandClassification,
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
                      const Text('Água diária/ha:'),
                      Text(
                        '${result.dailyWaterM3Ha.toStringAsFixed(1)} m³',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Água semanal/ha:'),
                      Text(
                        '${result.weeklyWaterM3Ha.toStringAsFixed(1)} m³',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para obter a necessidade da cultura, multiplique ETo pelo coeficiente da cultura (Kc)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Recomendações de Irrigação'),
              leading: const Icon(Icons.water),
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
📋 Evapotranspiração - Calculei App

💧 ETo (Evapotranspiração de Referência):
• Diária: ${result.etoMmDay.toStringAsFixed(2)} mm/dia
• Semanal: ${result.etoWeekly.toStringAsFixed(1)} mm
• Mensal: ${result.etoMonthly.toStringAsFixed(1)} mm

🌾 Demanda Evaporativa: ${result.demandClassification}

💦 Volume de Água:
• Diário/ha: ${result.dailyWaterM3Ha.toStringAsFixed(1)} m³
• Semanal/ha: ${result.weeklyWaterM3Ha.toStringAsFixed(1)} m³

💡 Multiplique ETo pelo coeficiente da cultura (Kc) para obter a necessidade real.

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
