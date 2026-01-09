import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/entities/brick_calculation.dart';
import '../providers/brick_calculator_provider.dart';
import '../widgets/brick_result_card.dart';

/// Brick calculator page
class BrickCalculatorPage extends ConsumerStatefulWidget {
  const BrickCalculatorPage({super.key});

  @override
  ConsumerState<BrickCalculatorPage> createState() =>
      _BrickCalculatorPageState();
}

class _BrickCalculatorPageState extends ConsumerState<BrickCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _wallLengthController = TextEditingController();
  final _wallHeightController = TextEditingController();
  final _openingsAreaController = TextEditingController(text: '0');

  BrickType _brickType = BrickType.ceramic6Holes;
  double _wastePercentage = 5;

  @override
  void dispose() {
    _wallLengthController.dispose();
    _wallHeightController.dispose();
    _openingsAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(brickCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Tijolos',
      subtitle: 'Alvenaria e Blocos',
      icon: Icons.crop_square,
      accentColor: CalculatorAccentColors.construction,
      categoryName: 'Construção',
      instructions: 'Informe as dimensões da parede em metros. '
          'Desconte portas e janelas (opcional). '
          'Escolha o tipo de tijolo/bloco para receber a quantidade necessária de tijolos e argamassa.',
      maxContentWidth: 800,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dimensões da Parede',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input fields row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: _DarkInputField(
                          label: 'Comprimento',
                          controller: _wallLengthController,
                          suffix: 'm',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: _DarkInputField(
                          label: 'Altura',
                          controller: _wallHeightController,
                          suffix: 'm',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: _DarkInputField(
                          label: 'Aberturas',
                          controller: _openingsAreaController,
                          suffix: 'm²',
                          helperText: 'Portas/janelas',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Tijolo/Bloco',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Brick Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: BrickType.values.map((type) {
                      final isSelected = _brickType == type;
                      return _BrickTypeChip(
                        type: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _brickType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Waste slider
                  Text(
                    'Perda: ${_wastePercentage.toInt()}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: CalculatorAccentColors.construction,
                      thumbColor: CalculatorAccentColors.construction,
                      overlayColor: CalculatorAccentColors.construction.withValues(alpha: 0.2),
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _wastePercentage,
                      min: 3,
                      max: 15,
                      divisions: 12,
                      label: '${_wastePercentage.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _wastePercentage = value;
                        });
                      },
                    ),
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

            // Result Card
            if (calculation.id.isNotEmpty) ...[
              const SizedBox(height: 32),
              BrickResultCard(calculation: calculation),
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
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(brickCalculatorProvider.notifier).calculate(
        wallLength: double.parse(_wallLengthController.text),
        wallHeight: double.parse(_wallHeightController.text),
        openingsArea: double.tryParse(_openingsAreaController.text) ?? 0,
        brickType: _brickType,
        wastePercentage: _wastePercentage,
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
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clear() {
    _wallLengthController.clear();
    _wallHeightController.clear();
    _openingsAreaController.text = '0';
    setState(() {
      _brickType = BrickType.ceramic6Holes;
      _wastePercentage = 5;
    });
    ref.read(brickCalculatorProvider.notifier).reset();
  }
}

/// Dark themed input field for construction calculator
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    this.suffix,
    this.helperText,
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
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
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
                color: CalculatorAccentColors.construction,
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

/// Brick type selection chip
class _BrickTypeChip extends StatelessWidget {
  final BrickType type;
  final bool isSelected;
  final VoidCallback onSelected;

  const _BrickTypeChip({
    required this.type,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? CalculatorAccentColors.construction
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? CalculatorAccentColors.construction
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${type.dimensions} • ${type.unitsPerSquareMeter} un/m²',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? CalculatorAccentColors.construction.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
