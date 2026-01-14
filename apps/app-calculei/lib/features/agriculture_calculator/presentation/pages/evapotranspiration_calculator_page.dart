import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/evapotranspiration_calculator.dart';

/// Página da calculadora de Evapotranspiração
class EvapotranspirationCalculatorPage extends StatefulWidget {
  const EvapotranspirationCalculatorPage({super.key});

  @override
  State<EvapotranspirationCalculatorPage> createState() =>
      _EvapotranspirationCalculatorPageState();
}

class _EvapotranspirationCalculatorPageState
    extends State<EvapotranspirationCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _temperatureController = TextEditingController();
  final _humidityController = TextEditingController();
  final _windSpeedController = TextEditingController();
  final _solarRadiationController = TextEditingController();

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
    return CalculatorPageLayout(
      title: 'Evapotranspiração',
      subtitle: 'Perda de Água',
      icon: Icons.water_drop,
      accentColor: CalculatorAccentColors.agriculture,
      currentCategory: 'agricultura',
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
              // Title section
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Text(
                    'Dados Meteorológicos',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Meteorological data inputs
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 160,
                    child: AdaptiveInputField(
                      label: 'Temperatura média',
                      controller: _temperatureController,
                      hintText: 'Ex: 28',
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
                    width: 160,
                    child: AdaptiveInputField(
                      label: 'Umidade relativa',
                      controller: _humidityController,
                      hintText: 'Ex: 60',
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
                    width: 160,
                    child: AdaptiveInputField(
                      label: 'Velocidade do vento',
                      controller: _windSpeedController,
                      hintText: 'Ex: 10',
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
                    width: 160,
                    child: AdaptiveInputField(
                      label: 'Radiação solar',
                      controller: _solarRadiationController,
                      hintText: 'Ex: 20',
                      suffix: 'MJ/m²',
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
                _EvapotranspirationResultCard(result: _result!),
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

    final result = EvapotranspirationCalculator.calculate(
      temperatureC: double.parse(_temperatureController.text),
      humidityPercent: double.parse(_humidityController.text),
      windSpeedKmH: double.parse(_windSpeedController.text),
      solarRadiationMJm2: double.parse(_solarRadiationController.text),
    );

    setState(() => _result = result);
  }

  void _clear() {
    _temperatureController.clear();
    _humidityController.clear();
    _windSpeedController.clear();
    _solarRadiationController.clear();
    setState(() {
      _result = null;
    });
  }
}

class _EvapotranspirationResultCard extends StatelessWidget {
  final EvapotranspirationResult result;

  const _EvapotranspirationResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              const Icon(Icons.opacity, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Evapotranspiração de Referência',
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

          // Main ETo results
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalculatorAccentColors.agriculture.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CalculatorAccentColors.agriculture.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'ETo',
                  value: '${result.etoMmDay.toStringAsFixed(2)} mm/dia',
                  highlight: true,
                ),
                Divider(height: 24, color: isDark ? Colors.white24 : Colors.black26),
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

          // Water volume
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Água diária/ha:',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${result.dailyWaterM3Ha.toStringAsFixed(1)} m³',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(height: 12, color: isDark ? Colors.white24 : Colors.black26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Água semanal/ha:',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${result.weeklyWaterM3Ha.toStringAsFixed(1)} m³',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: CalculatorAccentColors.agriculture,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                      color: Colors.blue[300],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendations
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: ExpansionTile(
              title: Text(
                'Recomendações de Irrigação',
                style: TextStyle(
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
              collapsedIconColor: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
              textColor: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
              children: result.recommendations
                  .map((rec) => Padding(
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
                                rec,
                                style: TextStyle(
                                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight 
                ? CalculatorAccentColors.agriculture 
                : isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}


