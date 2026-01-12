import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../providers/mortar_calculator_provider.dart';
import '../widgets/mortar_result_card.dart';

/// Mortar calculator page
class MortarCalculatorPage extends ConsumerStatefulWidget {
  const MortarCalculatorPage({super.key});

  @override
  ConsumerState<MortarCalculatorPage> createState() =>
      _MortarCalculatorPageState();
}

class _MortarCalculatorPageState extends ConsumerState<MortarCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _thicknessController = TextEditingController();

  String _mortarType = 'Assentamento';

  final _mortarTypes = [
    'Assentamento',
    'Reboco',
    'Contrapiso',
    'Chapisco',
  ];

  @override
  void dispose() {
    _areaController.dispose();
    _thicknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(mortarCalculatorProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CalculatorPageLayout(
      title: 'Calculadora de Argamassa',
      subtitle: 'Volume e Materiais',
      icon: Icons.construction,
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
                    'Dimensões',
                    style: TextStyle(
                      color: colorScheme.onSurface,
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
                        child: _AdaptiveInputField(
                          label: 'Área',
                          controller: _areaController,
                          suffix: 'm²',
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
                        child: _AdaptiveInputField(
                          label: 'Espessura',
                          controller: _thicknessController,
                          suffix: 'cm',
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
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Argamassa',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mortar Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _mortarTypes.map((type) {
                      final isSelected = _mortarType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _mortarType = type;
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
              MortarResultCard(calculation: calculation),
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
      await ref.read(mortarCalculatorProvider.notifier).calculate(
        area: double.parse(_areaController.text),
        thickness: double.parse(_thicknessController.text),
        mortarType: _mortarType,
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
    _areaController.clear();
    _thicknessController.clear();
    setState(() {
      _mortarType = 'Assentamento';
    });
    ref.read(mortarCalculatorProvider.notifier).reset();
  }
}

/// Theme-adaptive input field for construction calculator
class _AdaptiveInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _AdaptiveInputField({
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
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
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
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
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

/// Selection chip for mortar type
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
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
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
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
