import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/planter_setup_calculator_provider.dart';
import '../widgets/planter_setup_result_card.dart';

/// Planter setup calculator page
class PlanterSetupCalculatorPage extends ConsumerStatefulWidget {
  const PlanterSetupCalculatorPage({super.key});

  @override
  ConsumerState<PlanterSetupCalculatorPage> createState() =>
      _PlanterSetupCalculatorPageState();
}

class _PlanterSetupCalculatorPageState
    extends ConsumerState<PlanterSetupCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _populationController = TextEditingController();
  final _rowSpacingController = TextEditingController(text: '50');
  final _germinationController = TextEditingController(text: '90');

  String _cropType = 'Soja';
  int _discHoles = 28;

  final _cropTypes = [
    'Soja',
    'Milho',
    'Feijão',
    'Algodão',
    'Girassol',
  ];

  final _discHoleOptions = [20, 24, 28, 32, 36, 40];

  // Recommended populations by crop (plants/ha)
  final Map<String, Map<String, double>> _recommendedPopulations = {
    'Soja': {'min': 200000, 'max': 400000, 'default': 300000},
    'Milho': {'min': 50000, 'max': 80000, 'default': 65000},
    'Feijão': {'min': 200000, 'max': 350000, 'default': 280000},
    'Algodão': {'min': 80000, 'max': 150000, 'default': 110000},
    'Girassol': {'min': 40000, 'max': 60000, 'default': 50000},
  };

  @override
  void initState() {
    super.initState();
    _setDefaultPopulation();
  }

  void _setDefaultPopulation() {
    final defaultPop = _recommendedPopulations[_cropType]!['default']!;
    _populationController.text = defaultPop.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _populationController.dispose();
    _rowSpacingController.dispose();
    _germinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(planterSetupCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Regulagem de Plantadeira',
      subtitle: 'Agricultura de Precisão',
      icon: Icons.agriculture,
      accentColor: const Color(0xFF4CAF50), // Green accent
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
                  // Crop type selection
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Cultura',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cropTypes.map((crop) {
                      return DarkChoiceChip(
                        label: crop,
                        isSelected: _cropType == crop,
                        onSelected: () {
                          setState(() {
                            _cropType = crop;
                            _setDefaultPopulation();
                          });
                        },
                        accentColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Population info card
                  _buildPopulationInfoCard(),

                  const SizedBox(height: 24),

                  // Input fields
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Parâmetros de Plantio',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 240,
                        child: AdaptiveInputField(
                          label: 'População Alvo',
                          controller: _populationController,
                          suffix: 'plantas/ha',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            final min = _recommendedPopulations[_cropType]!['min']!;
                            final max = _recommendedPopulations[_cropType]!['max']!;
                            if (num < min || num > max) {
                              return 'Fora da faixa';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Espaçamento',
                          controller: _rowSpacingController,
                          suffix: 'cm',
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
                            if (num < 20 || num > 100) {
                              return '20-100 cm';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: AdaptiveInputField(
                          label: 'Germinação',
                          controller: _germinationController,
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
                            if (num == null || num <= 0) {
                              return 'Inválido';
                            }
                            if (num < 70 || num > 100) {
                              return '70-100%';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Disc holes selection
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Disco de Plantio',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _discHoleOptions.map((holes) {
                      return DarkChoiceChip(
                        label: '$holes furos',
                        isSelected: _discHoles == holes,
                        onSelected: () {
                          setState(() {
                            _discHoles = holes;
                          });
                        },
                        accentColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  CalculatorActionButtons(
                    onCalculate: _calculate,
                    onClear: _clear,
                    accentColor: const Color(0xFF4CAF50),
                  ),

                  const SizedBox(height: 24),

                  if (calculation.id.isNotEmpty)
                    PlanterSetupResultCard(calculation: calculation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulationInfoCard() {
    final popData = _recommendedPopulations[_cropType]!;
    final min = popData['min']!;
    final max = popData['max']!;

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
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
              const Icon(
                Icons.info_outline,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Faixa recomendada para $_cropType: '
                  '${(min / 1000).toStringAsFixed(0)}k - ${(max / 1000).toStringAsFixed(0)}k plantas/ha',
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final population = double.parse(_populationController.text);
      final rowSpacing = double.parse(_rowSpacingController.text);
      final germination = double.parse(_germinationController.text);

      try {
        ref.read(planterSetupCalculatorProvider.notifier).calculate(
              cropType: _cropType,
              targetPopulation: population,
              rowSpacing: rowSpacing,
              germination: germination,
              discHoles: _discHoles,
            );
      } catch (e) {
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
    _formKey.currentState?.reset();
    setState(() {
      _cropType = 'Soja';
      _discHoles = 28;
      _rowSpacingController.text = '50';
      _germinationController.text = '90';
      _setDefaultPopulation();
    });
    ref.read(planterSetupCalculatorProvider.notifier).reset();
  }
}


