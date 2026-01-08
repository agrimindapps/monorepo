import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/fluid_therapy_calculator.dart';
export '../../../../core/widgets/calculator_page_layout.dart' show CalculatorAccentColors;

/// Página da calculadora de Fluidoterapia
class FluidTherapyCalculatorPage extends StatefulWidget {
  const FluidTherapyCalculatorPage({super.key});

  @override
  State<FluidTherapyCalculatorPage> createState() =>
      _FluidTherapyCalculatorPageState();
}

class _FluidTherapyCalculatorPageState
    extends State<FluidTherapyCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _dehydrationController = TextEditingController();

  FluidTherapyResult? _result;

  @override
  void dispose() {
    _weightController.dispose();
    _dehydrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Fluidoterapia',
      subtitle: 'Cálculo de Fluidos',
      icon: Icons.water_drop,
      accentColor: CalculatorAccentColors.pet,
      categoryName: 'Pet',
      instructions: 'Calcule volumes de manutenção e reposição para fluidoterapia veterinária.',
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
              // Warning Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'APENAS ORIENTATIVO',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fluidoterapia deve ser prescrita por veterinário. Este cálculo não substitui avaliação profissional.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Weight
              _DarkInputField(
                label: 'Peso do pet',
                controller: _weightController,
                suffix: 'kg',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num <= 0 || num > 100) {
                    return 'Entre 0 e 100 kg';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Dehydration
              _DarkInputField(
                label: 'Desidratação estimada',
                controller: _dehydrationController,
                suffix: '%',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0 || num > 15) {
                    return 'Entre 0 e 15%';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Dehydration guide
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guia de Desidratação:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildDehydrationGuide(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Calculate button
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CalculatorAccentColors.pet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calculate),
                    SizedBox(width: 8),
                    Text(
                      'Calcular Fluidoterapia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 32),
                _FluidTherapyResultCard(
                  result: _result!,
                  weight: double.parse(_weightController.text),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDehydrationGuide() {
    final guides = [
      '< 5%: Leve - mucosas secas',
      '5-8%: Moderada - turgor reduzido',
      '8-12%: Severa - olhos encovados',
      '> 12%: Crítica - emergência',
    ];

    return guides
        .map((guide) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, size: 8, color: CalculatorAccentColors.pet),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guide,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final result = FluidTherapyCalculator.calculate(
      weightKg: double.parse(_weightController.text),
      dehydrationPercentage: double.parse(_dehydrationController.text),
    );

    setState(() => _result = result);
  }
}

class _FluidTherapyResultCard extends StatelessWidget {
  final FluidTherapyResult result;
  final double weight;

  const _FluidTherapyResultCard({
    required this.result,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.pet;

    return Container(
      padding: const EdgeInsets.all(24.0),
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
              Icon(Icons.assessment, color: accentColor),
              const SizedBox(width: 8),
              Text(
                'Resultado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              ShareButton(
                text: '''
📋 Fluidoterapia - Calculei App

⚖️ Peso: ${weight.toStringAsFixed(1)} kg
💧 Desidratação: ${result.dehydrationPercent.toStringAsFixed(1)}%

📊 Volumes:
• Manutenção: ${result.maintenanceVolumeMl.toStringAsFixed(0)} ml/24h
• Déficit: ${result.deficitVolumeMl.toStringAsFixed(0)} ml
• Total 24h: ${result.totalVolume24h.toStringAsFixed(0)} ml

⏱️ Taxa: ${result.hourlyRateMl.toStringAsFixed(1)} ml/h
💧 Gotas: ${result.dropsPerMinute.toStringAsFixed(0)} gts/min

⚠️ Cálculo orientativo - prescrição veterinária obrigatória

_________________
Calculado por Calculei
by Agrimind
https://calculei.com.br''',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main result
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('💧', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      result.totalVolume24h.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ' ml',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'volume total 24h',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Manutenção',
                  value: '${result.maintenanceVolumeMl.toStringAsFixed(0)} ml',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Déficit (${result.dehydrationPercent}%)',
                  value: '${result.deficitVolumeMl.toStringAsFixed(0)} ml',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Taxa horária',
                  value: '${result.hourlyRateMl.toStringAsFixed(1)} ml/h',
                ),
                Divider(height: 16, color: Colors.white.withValues(alpha: 0.1)),
                _DetailRow(
                  label: 'Gotas/minuto',
                  value: '${result.dropsPerMinute.toStringAsFixed(0)} gts/min',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendations
          Text(
            'Recomendações',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
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
                    rec.startsWith('⚠️') || rec.startsWith('🚨')
                        ? Icons.warning
                        : Icons.check_circle,
                    size: 18,
                    color: rec.startsWith('⚠️') || rec.startsWith('🚨')
                        ? Colors.orange
                        : accentColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

/// Dark theme input field widget
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
                color: CalculatorAccentColors.pet,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
