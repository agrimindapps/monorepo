import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../providers/glass_calculator_provider.dart';
import '../widgets/glass_result_card.dart';

/// Glass calculator page
class GlassCalculatorPage extends ConsumerStatefulWidget {
  const GlassCalculatorPage({super.key});

  @override
  ConsumerState<GlassCalculatorPage> createState() =>
      _GlassCalculatorPageState();
}

class _GlassCalculatorPageState extends ConsumerState<GlassCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String _glassType = 'Comum';
  int _glassThickness = 6;

  final _glassTypes = [
    'Comum',
    'Temperado',
    'Laminado',
    'Fumê',
  ];

  final _thicknessOptions = [4, 6, 8, 10];

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(glassCalculatorProvider);
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black87;
    final labelColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black54;

    return CalculatorPageLayout(
      title: 'Calculadora de Vidros',
      subtitle: 'Esquadrias e Janelas',
      icon: Icons.window,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
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
                    'Dimensões do Painel',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dimensions Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 200,
                        child: _DarkInputField(
                          label: 'Largura',
                          controller: _widthController,
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
                          controller: _heightController,
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
                          label: 'Quantidade',
                          controller: _quantityController,
                          suffix: 'painéis',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Vidro',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Glass Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _glassTypes.map((type) {
                      final isSelected = _glassType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _glassType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Espessura',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thickness Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _thicknessOptions.map((thickness) {
                      final isSelected = _glassThickness == thickness;
                      return _SelectionChip(
                        label: '${thickness}mm',
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _glassThickness = thickness;
                          });
                        },
                      );
                    }).toList(),
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
              GlassResultCard(calculation: calculation),
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
      await ref.read(glassCalculatorProvider.notifier).calculate(
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        glassType: _glassType,
        glassThickness: _glassThickness,
        numberOfPanels: int.parse(_quantityController.text),
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
    _widthController.clear();
    _heightController.clear();
    _quantityController.text = '1';
    setState(() {
      _glassType = 'Comum';
      _glassThickness = 6;
    });
    ref.read(glassCalculatorProvider.notifier).reset();
  }
}

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;
    final suffixColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black45;
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
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
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: suffixColor,
              fontSize: 16,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
    final unselectedBorder = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.15);
    final unselectedText = isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87;

    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : unselectedBg,
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
                  : unselectedBorder,
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
                  : unselectedText,
            ),
          ),
        ),
      ),
    );
  }
}
