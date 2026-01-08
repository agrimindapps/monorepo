import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
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
  final _temperatureController = TextEditingController(text: '28');
  final _humidityController = TextEditingController(text: '60');
  final _windSpeedController = TextEditingController(text: '10');
  final _solarRadiationController = TextEditingController(text: '20');

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
      categoryName: 'Agricultura',
      instructions: 'Calcule a evapotranspiração da cultura para manejo adequado da irrigação.',
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
              Text(
                'Dados Meteorológicos',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Meteorological data inputs
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 160,
                    child: _DarkInputField(
                      label: 'Temperatura média',
                      controller: _temperatureController,
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
                    child: _DarkInputField(
                      label: 'Umidade relativa',
                      controller: _humidityController,
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
                    child: _DarkInputField(
                      label: 'Velocidade do vento',
                      controller: _windSpeedController,
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
                    child: _DarkInputField(
                      label: 'Radiação solar',
                      controller: _solarRadiationController,
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

              // Calculate button
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular ETo'),
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
}

class _EvapotranspirationResultCard extends StatelessWidget {
  final EvapotranspirationResult result;

  const _EvapotranspirationResultCard({required this.result});

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
              const Icon(Icons.opacity, color: CalculatorAccentColors.agriculture),
              const SizedBox(width: 8),
              Text(
                'Evapotranspiração de Referência',
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
                const Divider(height: 24, color: Colors.white24),
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
              color: Colors.white.withValues(alpha: 0.08),
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
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${result.dailyWaterM3Ha.toStringAsFixed(1)} m³',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 12, color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Água semanal/ha:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: ExpansionTile(
              title: Text(
                'Recomendações de Irrigação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: Colors.white.withValues(alpha: 0.7),
              collapsedIconColor: Colors.white.withValues(alpha: 0.7),
              textColor: Colors.white.withValues(alpha: 0.9),
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
                                  color: Colors.white.withValues(alpha: 0.7),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlight ? 16 : 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: highlight 
                ? CalculatorAccentColors.agriculture 
                : Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
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
