import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/electrical_calculator_provider.dart';
import '../widgets/electrical_result_card.dart';

/// Electrical calculator page
class ElectricalCalculatorPage extends ConsumerStatefulWidget {
  const ElectricalCalculatorPage({super.key});

  @override
  ConsumerState<ElectricalCalculatorPage> createState() =>
      _ElectricalCalculatorPageState();
}

class _ElectricalCalculatorPageState
    extends ConsumerState<ElectricalCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _powerController = TextEditingController();
  final _cableLengthController = TextEditingController(text: '10');
  final _numberOfCircuitsController = TextEditingController(text: '1');

  double _voltage = 127;
  String _circuitType = 'Monofásico';

  final _voltageOptions = [127.0, 220.0];
  final _circuitTypes = ['Monofásico', 'Bifásico', 'Trifásico'];

  @override
  void dispose() {
    _powerController.dispose();
    _cableLengthController.dispose();
    _numberOfCircuitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(electricalCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora Elétrica',
      subtitle: 'Instalação e Dimensionamento',
      icon: Icons.bolt,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark 
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.grey.shade800;
          final subtleTextColor = isDark 
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey.shade600;

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
                        'Dados da Instalação',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Power Input
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Potência Total',
                          controller: _powerController,
                          suffix: 'W',
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
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Tensão',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Voltage Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _voltageOptions.map((voltage) {
                          final isSelected = _voltage == voltage;
                          return _SelectionChip(
                            label: '${voltage.toInt()}V',
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _voltage = voltage;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Tipo de Circuito',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Circuit Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _circuitTypes.map((type) {
                          final isSelected = _circuitType == type;
                          return _SelectionChip(
                            label: type,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _circuitType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Parâmetros Adicionais',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Additional Parameters Row
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 200,
                            child: AdaptiveInputField(
                              label: 'Comprimento do Cabo',
                              controller: _cableLengthController,
                              suffix: 'm',
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
                              label: 'Número de Circuitos',
                              controller: _numberOfCircuitsController,
                              suffix: '',
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
                  ElectricalResultCard(calculation: calculation),
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
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(electricalCalculatorProvider.notifier).calculate(
        totalPower: double.parse(_powerController.text),
        voltage: _voltage,
        circuitType: _circuitType,
        cableLength: double.parse(_cableLengthController.text),
        numberOfCircuits: int.parse(_numberOfCircuitsController.text),
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
    _powerController.clear();
    _cableLengthController.text = '10';
    _numberOfCircuitsController.text = '1';
    setState(() {
      _voltage = 127;
      _circuitType = 'Monofásico';
    });
    ref.read(electricalCalculatorProvider.notifier).reset();
  }
}

/// Selection chip for voltage/circuit type
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
    final unselectedBg = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade100;
    final unselectedBorder = isDark 
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.shade300;
    final unselectedText = isDark 
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.grey.shade700;

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
