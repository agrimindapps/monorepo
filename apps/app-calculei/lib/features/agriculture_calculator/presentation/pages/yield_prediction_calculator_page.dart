import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
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
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    'Cultura',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CropType.values.map((crop) {
                  final isSelected = _cropType == crop;
                  return DarkChoiceChip(
                    label: YieldPredictionCalculator.getCropName(crop),
                    isSelected: isSelected,
                    onSelected: () => setState(() => _cropType = crop),
                    accentColor: CalculatorAccentColors.agriculture,
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
                    child: AdaptiveInputField(
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
                    child: AdaptiveInputField(
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
                    child: AdaptiveInputField(
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

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.agriculture,
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

  void _clear() {
    _areaController.text = '10';
    _yieldController.text = '5000';
    _lossController.text = '5';
    setState(() {
      _cropType = CropType.corn;
      _result = null;
    });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productivityColor = _getProductivityColor(result.netYieldKgHa);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
        ),
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
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Valor estimado:',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'R\$ ${result.estimatedValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
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
              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
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
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
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


