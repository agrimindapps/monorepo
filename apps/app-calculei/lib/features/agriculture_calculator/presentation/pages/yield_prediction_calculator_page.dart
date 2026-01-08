import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/yield_prediction_calculator.dart';

/// Página da calculadora de previsão de produtividade
class YieldPredictionCalculatorPage extends StatefulWidget {
  const YieldPredictionCalculatorPage({super.key});

  @override
  State<YieldPredictionCalculatorPage> createState() =>
      _YieldPredictionCalculatorPageState();
}

class _YieldPredictionCalculatorPageState
    extends State<YieldPredictionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController(text: '10');
  final _yieldController = TextEditingController(text: '5000');
  final _lossController = TextEditingController(text: '5');

  CropType _cropType = CropType.corn;
  YieldPredictionResult? _result;

  @override
  void dispose() {
    _areaController.dispose();
    _yieldController.dispose();
    _lossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Previsão de Produtividade',
      subtitle: 'Estimativa de Produção',
      icon: Icons.trending_up,
      accentColor: CalculatorAccentColors.agriculture,
      categoryName: 'Agricultura',
      instructions:
          'Estime a produtividade esperada baseado em parâmetros da cultura e manejo.',
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
                  return ChoiceChip(
                    label: Text(YieldPredictionCalculator.getCropName(crop)),
                    selected: _cropType == crop,
                    onSelected: (_) {
                      setState(() => _cropType = crop);
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    selectedColor: CalculatorAccentColors.agriculture
                        .withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: _cropType == crop
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Input fields
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
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
                  SizedBox(
                    width: 200,
                    child: _DarkInputField(
                      label: 'Produtividade esperada',
                      controller: _yieldController,
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
                  SizedBox(
                    width: 150,
                    child: _DarkInputField(
                      label: 'Perdas estimadas',
                      controller: _lossController,
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
                ],
              ),

              const SizedBox(height: 32),

              // Calculate button
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CalculatorAccentColors.agriculture,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (_result != null)
                _YieldResultCard(result: _result!, cropType: _cropType),
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

    final result = YieldPredictionCalculator.calculate(
      cropType: _cropType,
      areaHa: double.parse(_areaController.text),
      expectedYieldKgHa: double.parse(_yieldController.text),
      lossPercentage: double.parse(_lossController.text),
    );

    setState(() => _result = result);
  }
}

class _YieldResultCard extends StatelessWidget {
  final YieldPredictionResult result;
  final CropType cropType;

  const _YieldResultCard({required this.result, required this.cropType});

  Color _getProductivityColor(double netYieldKgHa) {
    if (netYieldKgHa >= 4500) {
      return Colors.green;
    } else if (netYieldKgHa >= 3500) {
      return Colors.blue;
    } else if (netYieldKgHa >= 2500) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final productivityColor = _getProductivityColor(result.netYieldKgHa);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assessment,
                color: CalculatorAccentColors.agriculture,
              ),
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
              ShareButton(text: _formatShareText()),
            ],
          ),
          const SizedBox(height: 20),

          // Main results - Net yield highlighted
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  label: 'Produção líquida',
                  value: '${result.netYieldTon.toStringAsFixed(2)} ton',
                  color: CalculatorAccentColors.agriculture,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'Produção bruta',
                  value: '${result.grossYieldTon.toStringAsFixed(2)} ton',
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
                  label: 'Perdas',
                  value: '${result.lossKg.toStringAsFixed(0)} kg',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'Produtividade líquida',
                  value: '${result.netYieldKgHa.toStringAsFixed(0)} kg/ha',
                  color: productivityColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Estimated value
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
                  'Valor estimado:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'R\$ ${result.estimatedValue.toStringAsFixed(2)}',
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
                    rec.startsWith('⚠️') ? Icons.warning : Icons.check_circle,
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

  String _formatShareText() {
    final cropName = YieldPredictionCalculator.getCropName(cropType);
    return '''
📋 Previsão de Produtividade - Calculei App

🌾 Cultura: $cropName

📊 Resultado:
• Produção líquida: ${result.netYieldTon.toStringAsFixed(2)} toneladas
• Produção bruta: ${result.grossYieldTon.toStringAsFixed(2)} toneladas
• Perdas: ${result.lossKg.toStringAsFixed(0)} kg

💰 Valor estimado: R\$ ${result.estimatedValue.toStringAsFixed(2)}

_________________
Calculado por Calculei
by Agrimind''';
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
              borderSide: const BorderSide(
                color: CalculatorAccentColors.agriculture,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
