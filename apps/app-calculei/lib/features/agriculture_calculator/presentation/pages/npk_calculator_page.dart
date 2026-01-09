import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
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
    return CalculatorPageLayout(
      title: 'Adubação NPK',
      subtitle: 'Cálculo de Fertilizantes',
      icon: Icons.science,
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
                children: CropType.values.map((crop) {
                  return DarkChoiceChip(
                    label: NpkCalculator.getCropName(crop),
                    isSelected: _crop == crop,
                    onSelected: () {
                      setState(() => _crop = crop);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Yield and Area
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: _DarkInputField(
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
                    child: _DarkInputField(
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

              const SizedBox(height: 24),

              // Soil texture
              Text(
                'Textura do solo',
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
                children: SoilTexture.values.map((tex) {
                  return DarkChoiceChip(
                    label: NpkCalculator.getSoilName(tex),
                    isSelected: _texture == tex,
                    onSelected: () {
                      setState(() => _texture = tex);
                    },
                    accentColor: CalculatorAccentColors.agriculture,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Soil analysis
              Text(
                'Análise de solo',
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
                    width: 130,
                    child: _DarkInputField(
                      label: 'N disponível',
                      controller: _soilNController,
                      suffix: 'mg/dm³',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: _DarkInputField(
                      label: 'P (Mehlich)',
                      controller: _soilPController,
                      suffix: 'mg/dm³',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: _DarkInputField(
                      label: 'K trocável',
                      controller: _soilKController,
                      suffix: 'mg/dm³',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: _DarkInputField(
                      label: 'Mat. Orgânica',
                      controller: _omController,
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
                _NpkResultCard(result: _result!, crop: _crop),
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

  void _clear() {
    _yieldController.text = '8';
    _areaController.text = '10';
    _soilNController.text = '20';
    _soilPController.text = '10';
    _soilKController.text = '80';
    _omController.text = '3';
    setState(() {
      _crop = CropType.corn;
      _texture = SoilTexture.loam;
      _result = null;
    });
  }
}

class _NpkResultCard extends StatelessWidget {
  final NpkResult result;
  final CropType crop;

  const _NpkResultCard({required this.result, required this.crop});

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
                'Resultado',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 18,
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
                child: _ResultBox(
                  label: 'N',
                  value: result.nitrogenKgHa.toStringAsFixed(1),
                  unit: 'kg/ha',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'P₂O₅',
                  value: result.phosphorusKgHa.toStringAsFixed(1),
                  unit: 'kg/ha',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'K₂O',
                  value: result.potassiumKgHa.toStringAsFixed(1),
                  unit: 'kg/ha',
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cost
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custo estimado:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  'R\$ ${result.estimatedCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fertilizer recommendations
          Text(
            'Fertilizantes recomendados',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...result.recommendations.map(
            (rec) => _FertilizerItem(recommendation: rec),
          ),

          const SizedBox(height: 16),

          // Tips
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: ExpansionTile(
              title: Text(
                'Dicas de aplicação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: Colors.white.withValues(alpha: 0.7),
              collapsedIconColor: Colors.white.withValues(alpha: 0.7),
              textColor: Colors.white.withValues(alpha: 0.9),
              children: result.applicationTips
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _ResultBox({
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
              fontWeight: FontWeight.w500,
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
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2,
            size: 20,
            color: CalculatorAccentColors.agriculture,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recommendation.timing,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${recommendation.quantityKgHa} kg/ha',
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
