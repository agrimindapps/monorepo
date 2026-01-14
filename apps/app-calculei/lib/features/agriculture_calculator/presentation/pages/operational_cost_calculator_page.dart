import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/operational_cost_calculator_provider.dart';
import '../widgets/operational_cost_result_card.dart';

/// Operational cost calculator page
class OperationalCostCalculatorPage extends ConsumerStatefulWidget {
  const OperationalCostCalculatorPage({super.key});

  @override
  ConsumerState<OperationalCostCalculatorPage> createState() =>
      _OperationalCostCalculatorPageState();
}

class _OperationalCostCalculatorPageState
    extends ConsumerState<OperationalCostCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for input fields
  final _fuelConsumptionController = TextEditingController();
  final _fuelPriceController = TextEditingController();
  final _laborHoursController = TextEditingController();
  final _laborCostController = TextEditingController();
  final _machineryValueController = TextEditingController();
  final _usefulLifeController = TextEditingController();
  final _maintenanceFactorController = TextEditingController();
  final _areaWorkedController = TextEditingController();

  String _operationType = 'Preparo';

  final _operationTypes = [
    'Preparo',
    'Plantio',
    'Pulverização',
    'Colheita',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _fuelConsumptionController.dispose();
    _fuelPriceController.dispose();
    _laborHoursController.dispose();
    _laborCostController.dispose();
    _machineryValueController.dispose();
    _usefulLifeController.dispose();
    _maintenanceFactorController.dispose();
    _areaWorkedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(operationalCostCalculatorProvider);
    const accentColor = Color(0xFF4CAF50); // Green for agriculture

    return CalculatorPageLayout(
      title: 'Custo Operacional',
      subtitle: 'Máquinas Agrícolas',
      icon: Icons.attach_money,
      accentColor: accentColor,
      currentCategory: 'agricultura',
      maxContentWidth: 900,
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

                  // Fuel Costs Section
                  _buildSectionHeader('Custos com Combustível', Icons.local_gas_station),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Consumo de Combustível',
                          controller: _fuelConsumptionController,
                          hintText: 'Ex: 15.5',
                          suffix: 'L/ha',
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
                            if (num == null || num < 0) {
                              return 'Deve ser ≥ 0';
                            }
                            if (num > 100) {
                              return 'Máximo 100 L/ha';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Preço do Combustível',
                          controller: _fuelPriceController,
                          hintText: 'Ex: 5.90',
                          suffix: 'R\$/L',
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
                              return 'Máximo R\$ 50/L';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Labor Costs Section
                  _buildSectionHeader('Custos com Mão de Obra', Icons.person),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Horas de Trabalho',
                          controller: _laborHoursController,
                          hintText: 'Ex: 8',
                          suffix: 'h/ha',
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
                            if (num == null || num < 0) {
                              return 'Deve ser ≥ 0';
                            }
                            if (num > 24) {
                              return 'Máximo 24 h/ha';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Custo da Mão de Obra',
                          controller: _laborCostController,
                          hintText: 'Ex: 25.00',
                          suffix: 'R\$/h',
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
                            if (num == null || num < 0) {
                              return 'Deve ser ≥ 0';
                            }
                            if (num > 1000) {
                              return 'Máximo R\$ 1.000/h';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Machinery Costs Section
                  _buildSectionHeader('Custos com Maquinário', Icons.precision_manufacturing),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Valor da Máquina',
                          controller: _machineryValueController,
                          hintText: 'Ex: 250000',
                          suffix: 'R\$',
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
                            if (num > 10000000) {
                              return 'Máximo R\$ 10M';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Vida Útil',
                          controller: _usefulLifeController,
                          hintText: 'Ex: 10000',
                          suffix: 'horas',
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
                            if (num > 100000) {
                              return 'Máximo 100.000h';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Fator de Manutenção',
                          controller: _maintenanceFactorController,
                          hintText: 'Ex: 50',
                          suffix: '%',
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
                            if (num == null || num < 0) {
                              return 'Deve ser ≥ 0';
                            }
                            if (num > 200) {
                              return 'Máximo 200%';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Area Section
                  _buildSectionHeader('Área de Trabalho', Icons.landscape),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 250,
                    child: AdaptiveInputField(
                      label: 'Área Trabalhada',
                      controller: _areaWorkedController,
                      hintText: 'Ex: 500',
                      suffix: 'ha',
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
                        if (num > 100000) {
                          return 'Máximo 100.000 ha';
                        }
                        return null;
                      },
                    ),
                  ),
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
              OperationalCostResultCard(calculation: calculation),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTypeSelector() {
    const accentColor = Color(0xFF4CAF50); // Green for agriculture
    
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
            });
          },
          accentColor: accentColor,
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref.read(operationalCostCalculatorProvider.notifier).calculate(
            operationType: _operationType,
            fuelConsumption: double.parse(_fuelConsumptionController.text),
            fuelPrice: double.parse(_fuelPriceController.text),
            laborHours: double.parse(_laborHoursController.text),
            laborCost: double.parse(_laborCostController.text),
            machineryValue: double.parse(_machineryValueController.text),
            usefulLife: double.parse(_usefulLifeController.text),
            maintenanceFactor: double.parse(_maintenanceFactorController.text),
            areaWorked: double.parse(_areaWorkedController.text),
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
    _formKey.currentState?.reset();
    _fuelConsumptionController.clear();
    _fuelPriceController.clear();
    _laborHoursController.clear();
    _laborCostController.clear();
    _machineryValueController.clear();
    _usefulLifeController.clear();
    _maintenanceFactorController.clear();
    _areaWorkedController.clear();
    
    setState(() {
      _operationType = 'Preparo';
    });

    ref.read(operationalCostCalculatorProvider.notifier).reset();
  }
}
