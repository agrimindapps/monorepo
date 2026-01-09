import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
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
    return CalculatorPageLayout(
      title: 'Taxa de Semeadura',
      subtitle: 'Cálculo de Sementes',
      icon: Icons.grass,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
      maxContentWidth: 600,
      actions: [
        if (_result != null)
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {
              // Share handled by ShareButton in result card
            },
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
                children: SeedCropType.values.map((crop) {
                  return DarkChoiceChip(
                    label: SeedRateCalculator.getCropName(crop),
                    isSelected: _crop == crop,
                    onSelected: () {
                      setState(() {
                        _crop = crop;
                        _updateDefaults();
                      });
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Population and Area
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: _DarkInputField(
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
                    child: _DarkInputField(
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

              const SizedBox(height: 24),

              // Seed quality
              Text(
                'Qualidade das sementes',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 140,
                    child: _DarkInputField(
                      label: 'Germinação',
                      controller: _germinationController,
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: _DarkInputField(
                      label: 'Pureza',
                      controller: _purityController,
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: _DarkInputField(
                      label: 'Perdas campo',
                      controller: _lossesController,
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Seed weight and margin
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: _DarkInputField(
                      label: 'Peso 1000 sementes',
                      controller: _seedWeightController,
                      suffix: 'g',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: _DarkInputField(
                      label: 'Margem segurança',
                      controller: _marginController,
                      suffix: '%',
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
                _SeedRateResultCard(result: _result!, crop: _crop),
            ],
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

  void _clear() {
    _crop = SeedCropType.corn;
    _updateDefaults();
    _germinationController.text = '85';
    _purityController.text = '98';
    _lossesController.text = '8';
    _areaController.text = '10';
    _marginController.text = '5';
    setState(() {
      _result = null;
    });
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
    final qualityColor = _getQualityColor(result.qualityClass);

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
              Icon(Icons.assessment, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
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
                  color: CalculatorAccentColors.agriculture,
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Eficiência de estabelecimento:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${result.establishmentEfficiency}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qualidade das sementes:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: qualityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: qualityColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        result.qualityClass,
                        style: TextStyle(
                          color: qualityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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
              borderSide: BorderSide(
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
