import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/paint_calculator_provider.dart';
import '../widgets/paint_result_card.dart';

/// Paint calculator page
class PaintCalculatorPage extends ConsumerStatefulWidget {
  const PaintCalculatorPage({super.key});

  @override
  ConsumerState<PaintCalculatorPage> createState() =>
      _PaintCalculatorPageState();
}

class _PaintCalculatorPageState extends ConsumerState<PaintCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _wallAreaController = TextEditingController();
  final _openingsAreaController = TextEditingController(text: '0');

  int _coats = 2;
  String _paintType = 'Acrílica';

  final _paintTypes = [
    'Látex PVA',
    'Acrílica',
    'Acrílica Premium',
    'Esmalte',
    'Esmalte Sintético',
    'Textura',
    'Impermeabilizante',
  ];

  @override
  void dispose() {
    _wallAreaController.dispose();
    _openingsAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(paintCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Tinta',
      subtitle: 'Litros e Latas',
      icon: Icons.format_paint,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white : Colors.black87;
          final subtleTextColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
          final trackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300;

          return Padding(
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
                        'Áreas',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 250,
                            child: AdaptiveInputField(
                              label: 'Área das Paredes',
                              controller: _wallAreaController,
                              suffix: 'm²',
                              hint: 'Soma de todas as paredes',
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
                            width: 250,
                            child: AdaptiveInputField(
                              label: 'Área de Aberturas',
                              controller: _openingsAreaController,
                              suffix: 'm²',
                              hint: 'Portas e janelas',
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
                        'Tipo de Tinta',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Paint Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _paintTypes.map((type) {
                          final isSelected = _paintType == type;
                          return _SelectionChip(
                            label: type,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _paintType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Demãos: $_coats',
                        style: TextStyle(
                          color: subtleTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: CalculatorAccentColors.construction,
                          thumbColor: CalculatorAccentColors.construction,
                          overlayColor: CalculatorAccentColors.construction.withValues(alpha: 0.2),
                          inactiveTrackColor: trackColor,
                        ),
                        child: Slider(
                          value: _coats.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: '$_coats demão${_coats > 1 ? 's' : ''}',
                          onChanged: (value) {
                            setState(() {
                              _coats = value.toInt();
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
                  PaintResultCard(calculation: calculation),
                ],
              ],
            ),
          );
        },
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
      await ref.read(paintCalculatorProvider.notifier).calculate(
        wallArea: double.parse(_wallAreaController.text),
        openingsArea: double.tryParse(_openingsAreaController.text) ?? 0,
        coats: _coats,
        paintType: _paintType,
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
    _wallAreaController.clear();
    _openingsAreaController.text = '0';
    setState(() {
      _coats = 2;
      _paintType = 'Acrílica';
    });
    ref.read(paintCalculatorProvider.notifier).reset();
  }
}

/// Selection chip for paint type
class _SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipTextColor = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87;
    final chipBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;
    final chipBorderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300;

    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : chipBgColor,
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
                  : chipBorderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isSelected
                  ? CalculatorAccentColors.construction
                  : chipTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
