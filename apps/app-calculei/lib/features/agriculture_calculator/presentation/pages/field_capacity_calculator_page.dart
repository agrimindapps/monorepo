import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/field_capacity_calculator_provider.dart';
import '../widgets/field_capacity_result_card.dart';

/// Field capacity calculator page
class FieldCapacityCalculatorPage extends ConsumerStatefulWidget {
  const FieldCapacityCalculatorPage({super.key});

  @override
  ConsumerState<FieldCapacityCalculatorPage> createState() =>
      _FieldCapacityCalculatorPageState();
}

class _FieldCapacityCalculatorPageState
    extends ConsumerState<FieldCapacityCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _widthController = TextEditingController();
  final _speedController = TextEditingController();
  final _efficiencyController = TextEditingController();

  String _operationType = 'Preparo';
  bool _useCustomEfficiency = false;

  final _operationTypes = [
    'Preparo',
    'Plantio',
    'Pulverização',
    'Colheita',
  ];

  @override
  void dispose() {
    _widthController.dispose();
    _speedController.dispose();
    _efficiencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(fieldCapacityCalculatorProvider);
    const accentColor = Color(0xFF4CAF50); // Green for agriculture

    return CalculatorPageLayout(
      title: 'Capacidade de Campo',
      subtitle: 'Máquinas Agrícolas',
      icon: Icons.agriculture,
      accentColor: accentColor,
      currentCategory: 'agricultura',
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
                  // Operation Type Selection
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Tipo de Operação',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildOperationTypeSelector(),
                  const SizedBox(height: 24),

                  // Machine Parameters
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Parâmetros da Máquina',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Working Width and Speed
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Largura de Trabalho',
                          controller: _widthController,
                          hintText: 'Ex: 6.5',
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
                              return 'Deve ser > 0';
                            }
                            if (num > 50) {
                              return 'Máximo 50m';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Velocidade de Trabalho',
                          controller: _speedController,
                          hintText: 'Ex: 8.0',
                          suffix: 'km/h',
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
                              return 'Deve ser > 0';
                            }
                            if (num > 30) {
                              return 'Máximo 30 km/h';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Field Efficiency
                  _buildEfficiencySection(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            CalculatorActionButtons(
              onCalculate: _calculate,
              onClear: _clear,
              accentColor: accentColor,
            ),

            const SizedBox(height: 24),

            if (calculation.id.isNotEmpty)
              FieldCapacityResultCard(calculation: calculation),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _operationTypes.map((type) {
        final isSelected = _operationType == type;
        return DarkChoiceChip(
          label: type,
          isSelected: isSelected,
          onSelected: () {
            setState(() {
              _operationType = type;
              // Clear custom efficiency when changing operation type
              if (!_useCustomEfficiency) {
                _efficiencyController.clear();
              }
            });
          },
          accentColor: const Color(0xFF4CAF50),
        );
      }).toList(),
    );
  }

  Widget _buildEfficiencySection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Eficiência de Campo',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Usar padrão',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: !_useCustomEfficiency,
                      onChanged: (value) {
                        setState(() {
                          _useCustomEfficiency = !value;
                          if (!_useCustomEfficiency) {
                            _efficiencyController.clear();
                          }
                        });
                      },
                      activeTrackColor: const Color(0xFF4CAF50),
                      thumbColor: WidgetStateProperty.all(Colors.white),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (!_useCustomEfficiency)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getDefaultEfficiencyText(),
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: 250,
                child: AdaptiveInputField(
                  label: 'Eficiência Customizada',
                  controller: _efficiencyController,
                  hintText: 'Ex: 75',
                  suffix: '%',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0 || num > 100) {
                      return 'Entre 0 e 100%';
                    }
                    return null;
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _getDefaultEfficiencyText() {
    switch (_operationType) {
      case 'Preparo':
        return 'Eficiência padrão de 75% para operações de preparo de solo';
      case 'Plantio':
        return 'Eficiência padrão de 70% para operações de plantio';
      case 'Pulverização':
        return 'Eficiência padrão de 65% para operações de pulverização';
      case 'Colheita':
        return 'Eficiência padrão de 70% para operações de colheita';
      default:
        return 'Eficiência padrão de 70%';
    }
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final width = double.parse(_widthController.text);
    final speed = double.parse(_speedController.text);
    final efficiency = _useCustomEfficiency && _efficiencyController.text.isNotEmpty
        ? double.parse(_efficiencyController.text)
        : null;

    try {
      await ref.read(fieldCapacityCalculatorProvider.notifier).calculate(
            workingWidth: width,
            workingSpeed: speed,
            fieldEfficiency: efficiency,
            operationType: _operationType,
          );
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
    _widthController.clear();
    _speedController.clear();
    _efficiencyController.clear();
    setState(() {
      _operationType = 'Preparo';
      _useCustomEfficiency = false;
    });
    ref.read(fieldCapacityCalculatorProvider.notifier).reset();
  }
}


