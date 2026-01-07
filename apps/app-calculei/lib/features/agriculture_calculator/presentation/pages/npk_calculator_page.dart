import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/npk_calculator.dart';

/// Página da calculadora de NPK
class NpkCalculatorPage extends StatefulWidget {
  const NpkCalculatorPage({super.key});

  @override
  State<NpkCalculatorPage> createState() => _NpkCalculatorPageState();
}

class _NpkCalculatorPageState extends State<NpkCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController(text: '8');
  final _areaController = TextEditingController(text: '10');
  final _soilNController = TextEditingController(text: '20');
  final _soilPController = TextEditingController(text: '10');
  final _soilKController = TextEditingController(text: '80');
  final _omController = TextEditingController(text: '3');

  CropType _crop = CropType.corn;
  SoilTexture _texture = SoilTexture.loam;
  NpkResult? _result;

  @override
  void dispose() {
    _yieldController.dispose();
    _areaController.dispose();
    _soilNController.dispose();
    _soilPController.dispose();
    _soilKController.dispose();
    _omController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora NPK'),
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
                                'Adubação NPK',
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
                            'Calcule a necessidade de Nitrogênio, Fósforo e Potássio '
                            'baseado na cultura, produtividade esperada e análise de solo.',
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
                              children: CropType.values.map((crop) {
                                return ChoiceChip(
                                  label: Text(NpkCalculator.getCropName(crop)),
                                  selected: _crop == crop,
                                  onSelected: (_) =>
                                      setState(() => _crop = crop),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Yield and Area
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Produtividade esperada',
                                    controller: _yieldController,
                                    suffix: 't/ha',
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
                                  label: Text(NpkCalculator.getSoilName(tex)),
                                  selected: _texture == tex,
                                  onSelected: (_) =>
                                      setState(() => _texture = tex),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Soil analysis
                            Text(
                              'Análise de solo',
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
                                  width: 130,
                                  child: StandardInputField(
                                    label: 'N disponível',
                                    controller: _soilNController,
                                    suffix: 'mg/dm³',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: StandardInputField(
                                    label: 'P (Mehlich)',
                                    controller: _soilPController,
                                    suffix: 'mg/dm³',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: StandardInputField(
                                    label: 'K trocável',
                                    controller: _soilKController,
                                    suffix: 'mg/dm³',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: StandardInputField(
                                    label: 'Mat. Orgânica',
                                    controller: _omController,
                                    suffix: '%',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular NPK',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (_result != null) _NpkResultCard(result: _result!, crop: _crop),
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

    final result = NpkCalculator.calculate(
      crop: _crop,
      expectedYieldTonHa: double.parse(_yieldController.text),
      soilNMgDm3: double.tryParse(_soilNController.text) ?? 0,
      soilPMgDm3: double.tryParse(_soilPController.text) ?? 0,
      soilKMgDm3: double.tryParse(_soilKController.text) ?? 0,
      soilTexture: _texture,
      areaHa: double.parse(_areaController.text),
      organicMatterPercent: double.tryParse(_omController.text) ?? 3,
    );

    setState(() => _result = result);
  }
}

class _NpkResultCard extends StatelessWidget {
  final NpkResult result;
  final CropType crop;

  const _NpkResultCard({required this.result, required this.crop});

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
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recomendação de Adubação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatNpkCalculation(
                    crop: NpkCalculator.getCropName(crop),
                    nitrogenKgHa: result.nitrogenKgHa,
                    phosphorusKgHa: result.phosphorusKgHa,
                    potassiumKgHa: result.potassiumKgHa,
                    totalCost: result.estimatedCost,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // NPK boxes
            Row(
              children: [
                Expanded(
                  child: _NutrientBox(
                    label: 'N',
                    value: result.nitrogenKgHa,
                    unit: 'kg/ha',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientBox(
                    label: 'P₂O₅',
                    value: result.phosphorusKgHa,
                    unit: 'kg/ha',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _NutrientBox(
                    label: 'K₂O',
                    value: result.potassiumKgHa,
                    unit: 'kg/ha',
                    color: Colors.green,
                  ),
                ),
              ],
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

            // Fertilizer recommendations
            Text(
              'Fertilizantes recomendados',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...result.recommendations.map(
              (rec) => _FertilizerItem(recommendation: rec),
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
}

class _NutrientBox extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _NutrientBox({
    required this.label,
    required this.value,
    required this.unit,
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
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FertilizerItem extends StatelessWidget {
  final FertilizerRecommendation recommendation;

  const _FertilizerItem({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  recommendation.timing,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${recommendation.quantityKgHa} kg/ha',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
