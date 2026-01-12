import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/concrete_calculator_provider.dart';
import '../widgets/concrete_result_card.dart';

/// Concrete calculator page
class ConcreteCalculatorPage extends ConsumerStatefulWidget {
  const ConcreteCalculatorPage({super.key});

  @override
  ConsumerState<ConcreteCalculatorPage> createState() =>
      _ConcreteCalculatorPageState();
}

class _ConcreteCalculatorPageState
    extends ConsumerState<ConcreteCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  String _concreteType = 'Estrutural';
  String _concreteStrength = '25 MPa';

  final _concreteTypes = [
    'Magro',
    'Estrutural',
    'Bombeável',
    'Alta Resistência',
  ];

  final _strengthOptions = [
    '15 MPa',
    '20 MPa',
    '25 MPa',
    '30 MPa',
    '35 MPa',
    '40 MPa',
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(concreteCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Concreto',
      subtitle: 'Volume e Materiais',
      icon: Icons.layers,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
          final labelColor = isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54;

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
                        'Dimensões',
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
                            child: AdaptiveInputField(
                              label: 'Altura/Espessura',
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
                        'Tipo de Concreto',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Concrete Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _concreteTypes.map((type) {
                          final isSelected = _concreteType == type;
                          return _SelectionChip(
                            label: type,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _concreteType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Resistência',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Strength Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _strengthOptions.map((strength) {
                          final isSelected = _concreteStrength == strength;
                          return _SelectionChip(
                            label: strength,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _concreteStrength = strength;
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
                  ConcreteResultCard(calculation: calculation),
                ],
              ],
            ),
          );
        }
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
      await ref.read(concreteCalculatorProvider.notifier).calculate(
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        concreteType: _concreteType,
        concreteStrength: _concreteStrength,
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
    _heightController.clear();
    setState(() {
      _concreteType = 'Estrutural';
      _concreteStrength = '25 MPa';
    });
    ref.read(concreteCalculatorProvider.notifier).reset();
  }
}

/// Selection chip for concrete type/strength
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
    final chipColor = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.1);
    final textColor = isDark 
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black87;

    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : chipColor,
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
                  : borderColor,
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
                  : textColor,
            ),
          ),
        ),
      ),
    );
  }
}
