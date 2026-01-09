import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
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
    return CalculatorPageLayout(
      title: 'Necessidade Hídrica',
      subtitle: 'Cálculo de Irrigação',
      icon: Icons.water,
      accentColor: CalculatorAccentColors.agriculture,
      categoryName: 'Agricultura',
      instructions: 'Calcule o volume de água necessário para irrigação baseado na cultura, estágio e condições climáticas.',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {},
            tooltip: 'Compartilhar',
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop selection
              Text(
                'Cultura',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IrrigationCropType.values.map((crop) {
                  return DarkChoiceChip(
                    label: IrrigationCalculator.getCropName(crop),
                    isSelected: _crop == crop,
                    onSelected: () {
                      setState(() => _crop = crop);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Crop stage
              Text(
                'Estágio da cultura',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CropStage.values.map((stage) {
                  return DarkChoiceChip(
                    label: IrrigationCalculator.getStageName(stage),
                    isSelected: _stage == stage,
                    onSelected: () {
                      setState(() => _stage = stage);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Irrigation system
              Text(
                'Sistema de irrigação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IrrigationSystem.values.map((sys) {
                  return DarkChoiceChip(
                    label: IrrigationCalculator.getSystemName(sys),
                    isSelected: _system == sys,
                    onSelected: () {
                      setState(() => _system = sys);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Numeric inputs
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 160,
                    child: _DarkInputField(
                      label: 'ETo (referência)',
                      controller: _etoController,
                      suffix: 'mm/dia',
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
                    child: _DarkInputField(
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
                    child: _DarkInputField(
                      label: 'Vazão sistema',
                      controller: _flowController,
                      suffix: 'L/h',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.agriculture,
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
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

  void _clear() {
    _etoController.text = '5';
    _areaController.text = '10';
    _flowController.text = '10000';
    setState(() {
      _crop = IrrigationCropType.corn;
      _stage = CropStage.mid;
      _system = IrrigationSystem.sprinkler;
      _result = null;
    });
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Necessidade de Irrigação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
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
                  style: const TextStyle(
                    fontSize: 32,
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Volume semanal',
                  value: '${(result.weeklyVolumeLiters / 1000).toStringAsFixed(0)} m³',
                ),
                const Divider(color: Colors.white24),
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
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
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Dark theme input field widget
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CalculatorAccentColors.agriculture,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
