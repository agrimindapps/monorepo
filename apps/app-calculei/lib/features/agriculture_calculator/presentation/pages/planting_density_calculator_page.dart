import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/planting_density_calculator.dart';

/// Página da calculadora de densidade de plantio
class PlantingDensityCalculatorPage extends StatefulWidget {
  const PlantingDensityCalculatorPage({super.key});

  @override
  State<PlantingDensityCalculatorPage> createState() =>
      _PlantingDensityCalculatorPageState();
}

class _PlantingDensityCalculatorPageState
    extends State<PlantingDensityCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _rowSpacingController = TextEditingController(text: '0.9');
  final _plantSpacingController = TextEditingController(text: '0.2');
  final _areaController = TextEditingController(text: '10');
  final _costPerPlantController = TextEditingController(text: '0');

  PlantingDensityResult? _result;

  @override
  void dispose() {
    _rowSpacingController.dispose();
    _plantSpacingController.dispose();
    _areaController.dispose();
    _costPerPlantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Densidade de Plantio',
      subtitle: 'Espaçamento e População',
      icon: Icons.grid_4x4,
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
              // Row spacing and plant spacing
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 180,
                    child: AdaptiveInputField(
                      label: 'Espaçamento entre linhas',
                      controller: _rowSpacingController,
                      suffix: 'm',
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
                    child: AdaptiveInputField(
                      label: 'Espaçamento entre plantas',
                      controller: _plantSpacingController,
                      suffix: 'm',
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

              // Area and cost
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 150,
                    child: AdaptiveInputField(
                      label: 'Área total',
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
                    child: AdaptiveInputField(
                      label: 'Custo por muda (opcional)',
                      controller: _costPerPlantController,
                      suffix: 'R\$',
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

              const SizedBox(height: 32),

              // Action buttons
              CalculatorActionButtons(
                onCalculate: _calculate,
                onClear: _clear,
                accentColor: CalculatorAccentColors.agriculture,
              ),

              const SizedBox(height: 24),

              if (_result != null)
                _PlantingDensityResultCard(result: _result!),
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

    final result = PlantingDensityCalculator.calculate(
      rowSpacingM: double.parse(_rowSpacingController.text),
      plantSpacingM: double.parse(_plantSpacingController.text),
      areaHa: double.parse(_areaController.text),
      costPerPlant: double.tryParse(_costPerPlantController.text) ?? 0.0,
    );

    setState(() => _result = result);
  }

  void _clear() {
    _rowSpacingController.text = '0.9';
    _plantSpacingController.text = '0.2';
    _areaController.text = '10';
    _costPerPlantController.text = '0';
    setState(() {
      _result = null;
    });
  }
}

class _PlantingDensityResultCard extends StatelessWidget {
  final PlantingDensityResult result;

  const _PlantingDensityResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.grass, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Resultado da Densidade',
                style: TextStyle(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ShareButton(
                text: _formatShareText(),
                icon: Icons.share_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main results
          Row(
            children: [
              Expanded(
                child: _ResultBox(
                  label: 'Plantas/ha',
                  value: result.plantsPerHa.toString(),
                  color: CalculatorAccentColors.agriculture,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'Total de plantas',
                  value: result.totalPlants.toString(),
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
                  label: 'Área/planta',
                  value: '${result.areaPerPlant} m²',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultBox(
                  label: 'Metros lineares/ha',
                  value: '${result.linearMetersHa.toStringAsFixed(0)} m',
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          if (result.estimatedCost > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custo com mudas:',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    'R\$ ${result.estimatedCost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: CalculatorAccentColors.agriculture,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Recommendations
          if (result.recommendations.isNotEmpty) ...[
            Text(
              'Recomendações',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.9),
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
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: CalculatorAccentColors.agriculture,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.black.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatShareText() {
    return '''
📋 Densidade de Plantio - Calculei App

📊 Resultado:
• Plantas por hectare: ${result.plantsPerHa}
• Total de plantas: ${result.totalPlants}
• Área por planta: ${result.areaPerPlant} m²
${result.estimatedCost > 0 ? '\n💰 Custo com mudas: R\$ ${result.estimatedCost.toStringAsFixed(2)}' : ''}

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
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
