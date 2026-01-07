import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/seed_rate_calculator.dart';

/// Página da calculadora de Taxa de Semeadura
class SeedRateCalculatorPage extends StatefulWidget {
  const SeedRateCalculatorPage({super.key});

  @override
  State<SeedRateCalculatorPage> createState() => _SeedRateCalculatorPageState();
}

class _SeedRateCalculatorPageState extends State<SeedRateCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _populationController = TextEditingController();
  final _germinationController = TextEditingController(text: '85');
  final _purityController = TextEditingController(text: '98');
  final _lossesController = TextEditingController(text: '8');
  final _seedWeightController = TextEditingController();
  final _areaController = TextEditingController(text: '10');
  final _marginController = TextEditingController(text: '5');

  SeedCropType _crop = SeedCropType.corn;
  SeedRateResult? _result;

  @override
  void initState() {
    super.initState();
    _updateDefaults();
  }

  void _updateDefaults() {
    _populationController.text =
        SeedRateCalculator.getRecommendedPopulation(_crop).toString();
    _seedWeightController.text =
        SeedRateCalculator.getDefaultSeedWeight(_crop).toString();
  }

  @override
  void dispose() {
    _populationController.dispose();
    _germinationController.dispose();
    _purityController.dispose();
    _lossesController.dispose();
    _seedWeightController.dispose();
    _areaController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxa de Semeadura'),
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
                                Icons.grass,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cálculo de Sementes',
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
                            'Calcule a quantidade de sementes necessárias considerando '
                            'germinação, pureza e perdas de campo.',
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
                            // Crop selection
                            Text(
                              'Cultura',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: SeedCropType.values.map((crop) {
                                return ChoiceChip(
                                  label:
                                      Text(SeedRateCalculator.getCropName(crop)),
                                  selected: _crop == crop,
                                  onSelected: (_) {
                                    setState(() {
                                      _crop = crop;
                                      _updateDefaults();
                                    });
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Population and Area
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'População desejada',
                                    controller: _populationController,
                                    suffix: 'pl/ha',
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
                                    label: 'Área',
                                    controller: _areaController,
                                    suffix: 'ha',
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Obrigatório' : null,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Seed quality
                            Text(
                              'Qualidade das sementes',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 140,
                                  child: StandardInputField(
                                    label: 'Germinação',
                                    controller: _germinationController,
                                    suffix: '%',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: StandardInputField(
                                    label: 'Pureza',
                                    controller: _purityController,
                                    suffix: '%',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: StandardInputField(
                                    label: 'Perdas campo',
                                    controller: _lossesController,
                                    suffix: '%',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Seed weight and margin
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Peso 1000 sementes',
                                    controller: _seedWeightController,
                                    suffix: 'g',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: StandardInputField(
                                    label: 'Margem segurança',
                                    controller: _marginController,
                                    suffix: '%',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular',
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
                    _SeedRateResultCard(result: _result!, crop: _crop),
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

    final result = SeedRateCalculator.calculate(
      crop: _crop,
      targetPopulation: int.parse(_populationController.text),
      germinationRate: double.parse(_germinationController.text),
      seedPurity: double.parse(_purityController.text),
      fieldLosses: double.parse(_lossesController.text),
      thousandSeedWeight: double.parse(_seedWeightController.text),
      areaHa: double.parse(_areaController.text),
      safetyMargin: double.parse(_marginController.text),
    );

    setState(() => _result = result);
  }
}

class _SeedRateResultCard extends StatelessWidget {
  final SeedRateResult result;
  final SeedCropType crop;

  const _SeedRateResultCard({required this.result, required this.crop});

  Color _getQualityColor(String qualityClass) {
    return switch (qualityClass) {
      'Excelente' => Colors.green,
      'Boa' => Colors.blue,
      'Regular' => Colors.orange,
      _ => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final qualityColor = _getQualityColor(result.qualityClass);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatSeedRateCalculation(
                    crop: SeedRateCalculator.getCropName(crop),
                    seedsPerHa: result.seedsPerHa,
                    weightKgHa: result.weightKgHa,
                    totalWeightKg: result.totalWeightKg,
                    efficiency: result.establishmentEfficiency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main results
            Row(
              children: [
                Expanded(
                  child: _ResultBox(
                    label: 'Sementes/ha',
                    value: _formatNumber(result.seedsPerHa),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultBox(
                    label: 'Peso/ha',
                    value: '${result.weightKgHa} kg',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ResultBox(
                    label: 'Total sementes',
                    value: _formatNumber(result.totalSeeds),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultBox(
                    label: 'Peso total',
                    value: '${result.totalWeightKg} kg',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Quality indicators
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Eficiência de estabelecimento:'),
                      Text(
                        '${result.establishmentEfficiency}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Qualidade das sementes:'),
                      Chip(
                        label: Text(
                          result.qualityClass,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: qualityColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recommendations
            Text(
              'Recomendações',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      rec.startsWith('⚠️')
                          ? Icons.warning
                          : Icons.check_circle,
                      size: 18,
                      color: rec.startsWith('⚠️') ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec.replaceAll('⚠️ ', ''),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toString();
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
