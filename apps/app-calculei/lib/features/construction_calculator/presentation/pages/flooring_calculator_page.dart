import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/flooring_calculator_provider.dart';
import '../widgets/flooring_result_card.dart';

/// Flooring calculator page
class FlooringCalculatorPage extends ConsumerStatefulWidget {
  const FlooringCalculatorPage({super.key});

  @override
  ConsumerState<FlooringCalculatorPage> createState() =>
      _FlooringCalculatorPageState();
}

class _FlooringCalculatorPageState extends ConsumerState<FlooringCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _tileLengthController = TextEditingController();
  final _tileWidthController = TextEditingController();
  final _tilesPerBoxController = TextEditingController();

  double _wastePercentage = 10;
  String _flooringType = 'Porcelanato';

  final _flooringTypes = [
    'Cerâmica',
    'Porcelanato',
    'Porcelanato Polido',
    'Piso Vinílico',
    'Laminado',
    'Pedra Natural',
  ];

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _tileLengthController.dispose();
    _tileWidthController.dispose();
    _tilesPerBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(flooringCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Pisos',
      subtitle: 'Revestimentos e Acabamentos',
      icon: Icons.grid_on,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Dimensões do Ambiente',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Comprimento',
                          controller: _roomLengthController,
                          suffix: 'm',
                          hintText: 'Ex: 4.0',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Largura',
                          controller: _roomWidthController,
                          suffix: 'm',
                          hintText: 'Ex: 3.5',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) return 'Inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Dimensões da Peça',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 180,
                        child: AdaptiveInputField(
                          label: 'Comprimento',
                          controller: _tileLengthController,
                          suffix: 'cm',
                          hintText: 'Ex: 60',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AdaptiveInputField(
                          label: 'Largura',
                          controller: _tileWidthController,
                          suffix: 'cm',
                          hintText: 'Ex: 60',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AdaptiveInputField(
                          label: 'Peças/caixa',
                          controller: _tilesPerBoxController,
                          hintText: 'Ex: 4',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Obrigatório';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Configurações',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Flooring type dropdown
                  _DarkDropdownField(
                    label: 'Tipo de Piso',
                    value: _flooringType,
                    items: _flooringTypes,
                    onChanged: (value) => setState(() => _flooringType = value!),
                  ),

                  const SizedBox(height: 16),

                  // Waste slider
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Perda: ${_wastePercentage.toInt()}%',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: CalculatorAccentColors.construction,
                          thumbColor: CalculatorAccentColors.construction,
                          overlayColor: CalculatorAccentColors.construction.withValues(alpha: 0.2),
                          inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _wastePercentage,
                          min: 5,
                          max: 20,
                          divisions: 15,
                          label: '${_wastePercentage.toInt()}%',
                          onChanged: (value) => setState(() => _wastePercentage = value),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  CalculatorActionButtons(
                    onCalculate: _calculate,
                    onClear: _clear,
                    accentColor: CalculatorAccentColors.construction,
                  ),
                ],
              ),
            ),

            if (calculation.id.isNotEmpty) ...[
              const SizedBox(height: 32),
              FlooringResultCard(calculation: calculation),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(flooringCalculatorProvider.notifier).calculate(
        roomLength: double.parse(_roomLengthController.text),
        roomWidth: double.parse(_roomWidthController.text),
        tileLength: double.parse(_tileLengthController.text),
        tileWidth: double.parse(_tileWidthController.text),
        tilesPerBox: int.parse(_tilesPerBoxController.text),
        wastePercentage: _wastePercentage,
        flooringType: _flooringType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cálculo realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is Failure ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clear() {
    _roomLengthController.clear();
    _roomWidthController.clear();
    _tileLengthController.clear();
    _tileWidthController.clear();
    _tilesPerBoxController.clear();
    setState(() {
      _wastePercentage = 10;
      _flooringType = 'Porcelanato';
    });
    ref.read(flooringCalculatorProvider.notifier).reset();
  }
}

/// Dark themed dropdown field
class _DarkDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DarkDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: CalculatorAccentColors.construction,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
