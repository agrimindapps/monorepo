import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/irrigation_calculator.dart';

/// Página da calculadora de Irrigação
class IrrigationCalculatorPage extends StatefulWidget {
  const IrrigationCalculatorPage({super.key});

  @override
  State<IrrigationCalculatorPage> createState() =>
      _IrrigationCalculatorPageState();
}

class _IrrigationCalculatorPageState extends State<IrrigationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _etoController = TextEditingController(text: '5');
  final _areaController = TextEditingController(text: '10');
  final _flowController = TextEditingController(text: '10000');

  IrrigationCropType _crop = IrrigationCropType.corn;
  CropStage _stage = CropStage.mid;
  IrrigationSystem _system = IrrigationSystem.sprinkler;
  IrrigationResult? _result;

  @override
  void dispose() {
    _etoController.dispose();
    _areaController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigação'),
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
                                Icons.water,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Necessidade Hídrica',
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
                            'Calcule o volume de água necessário para irrigação '
                            'baseado na cultura, estágio e condições climáticas.',
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
                              children: IrrigationCropType.values.map((crop) {
                                return ChoiceChip(
                                  label: Text(
                                      IrrigationCalculator.getCropName(crop)),
                                  selected: _crop == crop,
                                  onSelected: (_) =>
                                      setState(() => _crop = crop),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Crop stage
                            Text(
                              'Estágio da cultura',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: CropStage.values.map((stage) {
                                return ChoiceChip(
                                  label: Text(
                                      IrrigationCalculator.getStageName(stage)),
                                  selected: _stage == stage,
                                  onSelected: (_) =>
                                      setState(() => _stage = stage),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Irrigation system
                            Text(
                              'Sistema de irrigação',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: IrrigationSystem.values.map((sys) {
                                return ChoiceChip(
                                  label: Text(
                                      IrrigationCalculator.getSystemName(sys)),
                                  selected: _system == sys,
                                  onSelected: (_) =>
                                      setState(() => _system = sys),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Numeric inputs
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 160,
                                  child: StandardInputField(
                                    label: 'ETo (referência)',
                                    controller: _etoController,
                                    suffix: 'mm/dia',
                                    hint: '3-8 típico',
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
                                    validator: (v) =>
                                        v?.isEmpty ?? true ? 'Obrigatório' : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: StandardInputField(
                                    label: 'Vazão sistema',
                                    controller: _flowController,
                                    suffix: 'L/h',
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
                    _IrrigationResultCard(
                      result: _result!,
                      crop: _crop,
                      stage: _stage,
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

    final result = IrrigationCalculator.calculate(
      crop: _crop,
      stage: _stage,
      etoMmDay: double.parse(_etoController.text),
      areaHa: double.parse(_areaController.text),
      system: _system,
      flowRateLitersHour: double.parse(_flowController.text),
    );

    setState(() => _result = result);
  }
}

class _IrrigationResultCard extends StatelessWidget {
  final IrrigationResult result;
  final IrrigationCropType crop;
  final CropStage stage;

  const _IrrigationResultCard({
    required this.result,
    required this.crop,
    required this.stage,
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
                Icon(Icons.assessment, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Necessidade de Irrigação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ShareButton(
                  text: ShareFormatter.formatIrrigationCalculation(
                    crop: IrrigationCalculator.getCropName(crop),
                    stage: IrrigationCalculator.getStageName(stage),
                    etcMmDay: result.etcMmDay,
                    dailyVolumeM3: result.dailyVolumeM3,
                    irrigationTimeHours: result.irrigationTimeHours,
                    frequencyDays: result.frequencyDays,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main result - Water drop visual
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade300,
                    Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${result.dailyVolumeM3} m³',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'por dia',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details grid
            Row(
              children: [
                Expanded(
                  child: _DetailCard(
                    icon: Icons.speed,
                    label: 'ETc',
                    value: '${result.etcMmDay} mm/dia',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailCard(
                    icon: Icons.timer,
                    label: 'Tempo',
                    value: '${result.irrigationTimeHours}h',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailCard(
                    icon: Icons.calendar_today,
                    label: 'Frequência',
                    value: 'A cada ${result.frequencyDays}d',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Additional info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Volume semanal',
                    value: '${(result.weeklyVolumeLiters / 1000).toStringAsFixed(0)} m³',
                  ),
                  const Divider(),
                  _InfoRow(
                    label: 'Lâmina de água',
                    value: '${result.waterDepthMm} mm',
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
                      color: rec.startsWith('⚠️') ? Colors.orange : Colors.blue,
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
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
