import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/water_tank_calculator_provider.dart';
import '../widgets/water_tank_result_card.dart';

/// Water tank calculator page
class WaterTankCalculatorPage extends ConsumerStatefulWidget {
  const WaterTankCalculatorPage({super.key});

  @override
  ConsumerState<WaterTankCalculatorPage> createState() =>
      _WaterTankCalculatorPageState();
}

class _WaterTankCalculatorPageState
    extends ConsumerState<WaterTankCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberOfPeopleController = TextEditingController();

  double _dailyConsumption = 150.0;
  int _reserveDays = 2;
  String _tankType = 'Polietileno';

  final _tankTypes = [
    'Polietileno',
    'Fibra de Vidro',
    'Aço Inox',
    'Concreto',
  ];

  @override
  void dispose() {
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(waterTankCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Caixa d\'Água',
      subtitle: 'Dimensionamento',
      icon: Icons.water_drop,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dados do Consumo',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Number of People
                      SizedBox(
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Número de Pessoas',
                          controller: _numberOfPeopleController,
                          suffix: 'pessoas',
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

                      const SizedBox(height: 24),

                      Text(
                        'Consumo Diário por Pessoa',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily Consumption Slider
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_dailyConsumption.toInt()} litros/dia',
                                  style: const TextStyle(
                                    color: CalculatorAccentColors.construction,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CalculatorAccentColors.construction
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getConsumptionLabel(_dailyConsumption),
                                    style: const TextStyle(
                                      color: CalculatorAccentColors.construction,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: CalculatorAccentColors.construction,
                                inactiveTrackColor:
                                    isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                                thumbColor: CalculatorAccentColors.construction,
                                overlayColor: CalculatorAccentColors.construction
                                    .withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: _dailyConsumption,
                                min: 80,
                                max: 300,
                                divisions: 22,
                                onChanged: (value) {
                                  setState(() {
                                    _dailyConsumption = value;
                                  });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '80L',
                                  style: TextStyle(
                                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '300L',
                                  style: TextStyle(
                                    color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Dias de Reserva',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reserve Days Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [1, 2, 3, 4, 5].map((days) {
                          final isSelected = _reserveDays == days;
                          return _SelectionChip(
                            label: '$days ${days == 1 ? 'dia' : 'dias'}',
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _reserveDays = days;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Material da Caixa',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tank Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tankTypes.map((type) {
                          final isSelected = _tankType == type;
                          return _SelectionChip(
                            label: type,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _tankType = type;
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
                  WaterTankResultCard(calculation: calculation),
                ],
              ],
            );
          }
        ),
      ),
    );
  }

  String _getConsumptionLabel(double consumption) {
    if (consumption < 100) {
      return 'Econômico';
    } else if (consumption <= 150) {
      return 'Normal';
    } else if (consumption <= 200) {
      return 'Moderado';
    } else {
      return 'Alto';
    }
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
      await ref.read(waterTankCalculatorProvider.notifier).calculate(
        numberOfPeople: int.parse(_numberOfPeopleController.text),
        dailyConsumption: _dailyConsumption,
        reserveDays: _reserveDays,
        tankType: _tankType,
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
    _numberOfPeopleController.clear();
    setState(() {
      _dailyConsumption = 150.0;
      _reserveDays = 2;
      _tankType = 'Polietileno';
    });
    ref.read(waterTankCalculatorProvider.notifier).reset();
  }
}

/// Selection chip for tank type/reserve days
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

    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
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
                  : isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
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
                  : isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
