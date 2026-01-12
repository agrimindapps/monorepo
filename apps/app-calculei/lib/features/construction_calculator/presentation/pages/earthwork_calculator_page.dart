import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../providers/earthwork_calculator_provider.dart';
import '../widgets/earthwork_result_card.dart';

/// Earthwork calculator page
class EarthworkCalculatorPage extends ConsumerStatefulWidget {
  const EarthworkCalculatorPage({super.key});

  @override
  ConsumerState<EarthworkCalculatorPage> createState() =>
      _EarthworkCalculatorPageState();
}

class _EarthworkCalculatorPageState
    extends ConsumerState<EarthworkCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();

  String _operationType = 'Escavação';
  String _soilType = 'Areia';

  final _operationTypes = [
    'Escavação',
    'Aterro',
    'Corte e Aterro',
  ];

  final _soilTypes = [
    'Areia',
    'Argila',
    'Saibro',
    'Pedregoso',
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(earthworkCalculatorProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return CalculatorPageLayout(
      title: 'Calculadora de Terraplenagem',
      subtitle: 'Escavação e Aterro',
      icon: Icons.terrain,
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
                    'Dimensões',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
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
                          label: 'Comprimento',
                          controller: _lengthController,
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
                          label: 'Profundidade',
                          controller: _depthController,
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
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Operação',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Operation Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _operationTypes.map((type) {
                      final isSelected = _operationType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _operationType = type;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Solo',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Soil Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _soilTypes.map((type) {
                      final isSelected = _soilType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _soilType = type;
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
              EarthworkResultCard(calculation: calculation),
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
      await ref.read(earthworkCalculatorProvider.notifier).calculate(
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        depth: double.parse(_depthController.text),
        operationType: _operationType,
        soilType: _soilType,
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
    _lengthController.clear();
    _widthController.clear();
    _depthController.clear();
    setState(() {
      _operationType = 'Escavação';
      _soilType = 'Areia';
    });
    ref.read(earthworkCalculatorProvider.notifier).reset();
  }
}

/// Dark themed input field for construction calculator
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
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7),
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
              color: textColor.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: surfaceColor.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: textColor.withValues(alpha: 0.1),
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

/// Selection chip for operation type/soil type
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
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    
    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : surfaceColor.withValues(alpha: 0.3),
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
                  : textColor.withValues(alpha: 0.1),
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
                  : textColor.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
