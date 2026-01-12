import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/adaptive_colors.dart';
import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/drywall_calculator_provider.dart';
import '../widgets/drywall_result_card.dart';

/// Drywall calculator page
class DrywallCalculatorPage extends ConsumerStatefulWidget {
  const DrywallCalculatorPage({super.key});

  @override
  ConsumerState<DrywallCalculatorPage> createState() =>
      _DrywallCalculatorPageState();
}

class _DrywallCalculatorPageState extends ConsumerState<DrywallCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _heightController = TextEditingController();

  String _wallType = 'Simples';

  final _wallTypes = [
    'Simples',
    'Dupla',
    'Acústica',
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(drywallCalculatorProvider);
    final colors = context.colors;

    return CalculatorPageLayout(
      title: 'Calculadora de Drywall',
      subtitle: 'Gesso Acartonado',
      icon: Icons.view_column,
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
                    'Dimensões da Parede',
                    style: TextStyle(
                      color: colors.textPrimary,
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
                        child: AdaptiveInputField(
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
                        child: AdaptiveInputField(
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
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Tipo de Parede',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wall Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wallTypes.map((type) {
                      final isSelected = _wallType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _wallType = type;
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
              DrywallResultCard(calculation: calculation),
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
      await ref.read(drywallCalculatorProvider.notifier).calculate(
        length: double.parse(_lengthController.text),
        height: double.parse(_heightController.text),
        wallType: _wallType,
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
    _heightController.clear();
    setState(() {
      _wallType = 'Simples';
    });
    ref.read(drywallCalculatorProvider.notifier).reset();
  }
}

/// Selection chip for wall type
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
    final colors = context.colors;
    
    return Material(
      color: isSelected
          ? AdaptiveColors.categoryConstruction.withValues(alpha: 0.15)
          : colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? AdaptiveColors.categoryConstruction
                  : colors.border,
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
                  ? AdaptiveColors.categoryConstruction
                  : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
