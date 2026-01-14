import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/harvester_setup_calculator_provider.dart';
import '../widgets/harvester_setup_result_card.dart';

/// Harvester setup calculator page
class HarvesterSetupCalculatorPage extends ConsumerStatefulWidget {
  const HarvesterSetupCalculatorPage({super.key});

  @override
  ConsumerState<HarvesterSetupCalculatorPage> createState() =>
      _HarvesterSetupCalculatorPageState();
}

class _HarvesterSetupCalculatorPageState
    extends ConsumerState<HarvesterSetupCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _productivityController = TextEditingController();
  final _moistureController = TextEditingController();
  final _speedController = TextEditingController();
  final _platformWidthController = TextEditingController();

  String _cropType = 'Soja';

  final _cropTypes = ['Soja', 'Milho', 'Trigo', 'Arroz', 'Feijão'];

  // Typical productivity ranges (sc/ha)
  final Map<String, Map<String, double>> _productivityRanges = {
    'Soja': {'min': 20, 'max': 120, 'typical': 60},
    'Milho': {'min': 30, 'max': 250, 'typical': 100},
    'Trigo': {'min': 15, 'max': 100, 'typical': 50},
    'Arroz': {'min': 40, 'max': 200, 'typical': 120},
    'Feijão': {'min': 15, 'max': 80, 'typical': 45},
  };

  // Ideal moisture ranges (%)
  final Map<String, Map<String, double>> _moistureRanges = {
    'Soja': {'min': 12, 'max': 14},
    'Milho': {'min': 14, 'max': 16},
    'Trigo': {'min': 12, 'max': 13},
    'Arroz': {'min': 18, 'max': 22},
    'Feijão': {'min': 13, 'max': 15},
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _productivityController.dispose();
    _moistureController.dispose();
    _speedController.dispose();
    _platformWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(harvesterSetupCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Regulagem de Colhedora',
      subtitle: 'Agricultura de Precisão',
      icon: Icons.agriculture,
      accentColor: const Color(0xFF4CAF50), // Green accent
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
                  // Crop type selection
                  Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Cultura',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.black.withValues(alpha: 0.9),
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
                          });
                        },
                        accentColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Info cards
                  Row(
                    children: [
                      Expanded(child: _buildProductivityInfoCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMoistureInfoCard()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Input fields - Crop parameters
                  Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Parâmetros da Cultura',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.black.withValues(alpha: 0.9),
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
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Produtividade',
                          controller: _productivityController,
                          hintText: 'Ex: 60',
                          suffix: 'sc/ha',
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
                            final min = _productivityRanges[_cropType]!['min']!;
                            final max = _productivityRanges[_cropType]!['max']!;
                            if (num < min || num > max) {
                              return 'Fora da faixa';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: AdaptiveInputField(
                          label: 'Umidade',
                          controller: _moistureController,
                          hintText: 'Ex: 13.0',
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
                            if (num < 8 || num > 35) {
                              return '8-35%';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Input fields - Harvester parameters
                  Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Parâmetros da Colhedora',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.black.withValues(alpha: 0.9),
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
                        width: 200,
                        child: AdaptiveInputField(
                          label: 'Velocidade',
                          controller: _speedController,
                          hintText: 'Ex: 5.0',
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
                              return 'Inválido';
                            }
                            if (num < 2 || num > 10) {
                              return '2-10 km/h';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: AdaptiveInputField(
                          label: 'Largura Plataforma',
                          controller: _platformWidthController,
                          hintText: 'Ex: 6.0',
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
                            if (num < 3 || num > 15) {
                              return '3-15 m';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
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
                    HarvesterSetupResultCard(calculation: calculation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityInfoCard() {
    final prodData = _productivityRanges[_cropType]!;
    final min = prodData['min']!;
    final max = prodData['max']!;

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
                Icons.analytics_outlined,
                color: Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Produtividade $_cropType: '
                  '${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)} sc/ha',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.black.withValues(alpha: 0.85),
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

  Widget _buildMoistureInfoCard() {
    final moistureData = _moistureRanges[_cropType]!;
    final min = moistureData['min']!;
    final max = moistureData['max']!;

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Umidade ideal: '
                  '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : Colors.black.withValues(alpha: 0.85),
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
      final productivity = double.parse(_productivityController.text);
      final moisture = double.parse(_moistureController.text);
      final speed = double.parse(_speedController.text);
      final platformWidth = double.parse(_platformWidthController.text);

      try {
        ref
            .read(harvesterSetupCalculatorProvider.notifier)
            .calculate(
              cropType: _cropType,
              productivity: productivity,
              moisture: moisture,
              harvestSpeed: speed,
              platformWidth: platformWidth,
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is Failure ? e.message : e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _clear() {
    _formKey.currentState?.reset();
    _productivityController.clear();
    _moistureController.clear();
    _speedController.clear();
    _platformWidthController.clear();
    setState(() {
      _cropType = 'Soja';
      // _moistureController.text = '13.0';
      // _speedController.text = '5.0';
      // _platformWidthController.text = '6.0';
      // _setDefaultProductivity();
    });
    ref.read(harvesterSetupCalculatorProvider.notifier).reset();
  }
}
