import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/share_button.dart';
import '../../domain/calculators/soil_ph_calculator.dart';

/// Página da calculadora de pH do solo e calagem
class SoilPhCalculatorPage extends StatefulWidget {
  const SoilPhCalculatorPage({super.key});

  @override
  State<SoilPhCalculatorPage> createState() => _SoilPhCalculatorPageState();
}

class _SoilPhCalculatorPageState extends State<SoilPhCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPhController = TextEditingController(text: '5.2');
  final _targetPhController = TextEditingController(text: '6.5');
  final _areaController = TextEditingController(text: '10');
  final _prntController = TextEditingController(text: '90');

  SoilTexture _texture = SoilTexture.loam;
  SoilPhResult? _result;

  @override
  void dispose() {
    _currentPhController.dispose();
    _targetPhController.dispose();
    _areaController.dispose();
    _prntController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPageLayout(
      title: 'Correção de pH',
      subtitle: 'Calagem do Solo',
      icon: Icons.science,
      accentColor: CalculatorAccentColors.agriculture,
      categoryName: 'Agricultura',
      instructions: 'Calcule a quantidade de calcário necessária para correção do pH do solo.',
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
              // pH values
              Text(
                'Valores de pH',
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
                    width: 150,
                    child: _DarkInputField(
                      label: 'pH atual',
                      controller: _currentPhController,
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
                      label: 'pH alvo',
                      controller: _targetPhController,
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
                  return ChoiceChip(
                    label: Text(SoilPhCalculator.getTextureName(tex)),
                    selected: _texture == tex,
                    onSelected: (_) {
                      setState(() => _texture = tex);
                    },
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    selectedColor:
                        CalculatorAccentColors.agriculture.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: _texture == tex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Area and PRNT
              Text(
                'Propriedades',
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
                    width: 180,
                    child: _DarkInputField(
                      label: 'PRNT do calcário',
                      controller: _prntController,
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

              const SizedBox(height: 28),

              // Calculate button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate),
                  label: const Text(
                    'Calcular Calagem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CalculatorAccentColors.agriculture,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              if (_result != null) ...[
                const SizedBox(height: 24),
                _SoilPhResultCard(
                  result: _result!,
                  texture: _texture,
                ),
              ],
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

    final result = SoilPhCalculator.calculate(
      currentPh: double.parse(_currentPhController.text),
      targetPh: double.parse(_targetPhController.text),
      soilTexture: _texture,
      areaHa: double.parse(_areaController.text),
      prnt: double.tryParse(_prntController.text) ?? 90.0,
    );

    setState(() => _result = result);
  }
}

class _SoilPhResultCard extends StatelessWidget {
  final SoilPhResult result;
  final SoilTexture texture;

  const _SoilPhResultCard({
    required this.result,
    required this.texture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.grass,
              color: CalculatorAccentColors.agriculture,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Recomendação de Calagem',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ShareButton(
              text: _formatShareText(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (result.limeNeededKg == 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Solo já está no pH adequado!\nNão necessita calagem.',
                    style: TextStyle(
                      color: Colors.green[200],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Main results
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
                _ResultBox(
                  label: 'Calcário necessário',
                  value: result.limeTons.toStringAsFixed(2),
                  unit: 'toneladas',
                  highlight: true,
                ),
                const Divider(
                  height: 24,
                  color: Colors.white24,
                ),
                _ResultBox(
                  label: 'Por hectare',
                  value: result.limeKgHa.toStringAsFixed(0),
                  unit: 'kg/ha',
                ),
                const SizedBox(height: 12),
                _ResultBox(
                  label: 'Correção de pH',
                  value: '+${result.phDifference.toStringAsFixed(1)}',
                  unit: 'unidades',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cost
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custo estimado:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
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
                'Recomendações de aplicação',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconColor: Colors.white.withValues(alpha: 0.7),
              collapsedIconColor: Colors.white.withValues(alpha: 0.7),
              textColor: Colors.white.withValues(alpha: 0.9),
              initiallyExpanded: true,
              children: result.recommendations
                  .map(
                    (rec) => Padding(
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
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  String _formatShareText() {
    final textureName = SoilPhCalculator.getTextureName(texture);

    if (result.limeNeededKg == 0) {
      return '''
📋 Cálculo de Calagem - Calculei App

✅ Solo já está no pH adequado!
Não necessita calagem.

_________________
Calculado por Calculei
by Agrimind''';
    }

    return '''
📋 Cálculo de Calagem - Calculei App

📏 Textura: $textureName
📊 Correção: +${result.phDifference.toStringAsFixed(1)} de pH

🧪 Resultado:
• Calcário necessário: ${result.limeTons.toStringAsFixed(2)} toneladas
• Por hectare: ${result.limeKgHa.toStringAsFixed(0)} kg/ha

💰 Custo estimado: R\$ ${result.estimatedCost.toStringAsFixed(2)}

💡 Aplicar 60-90 dias antes do plantio e incorporar ao solo.

_________________
Calculado por Calculei
by Agrimind''';
  }
}

class _ResultBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool highlight;

  const _ResultBox({
    required this.label,
    required this.value,
    required this.unit,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: highlight ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: highlight
                    ? CalculatorAccentColors.agriculture
                    : Colors.white,
              ),
            ),
          ],
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
