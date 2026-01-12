import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/tractor_ballast_calculator_provider.dart';
import '../widgets/tractor_ballast_result_card.dart';

/// Tractor ballast calculator page
class TractorBallastCalculatorPage extends ConsumerStatefulWidget {
  const TractorBallastCalculatorPage({super.key});

  @override
  ConsumerState<TractorBallastCalculatorPage> createState() =>
      _TractorBallastCalculatorPageState();
}

class _TractorBallastCalculatorPageState
    extends ConsumerState<TractorBallastCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _tractorWeightController = TextEditingController();
  final _implementWeightController = TextEditingController(text: '0');

  String _tractorType = '4x2';
  String _operationType = 'Preparo Pesado';

  final _tractorTypes = ['4x2', '4x4', 'Esteira'];
  final _operationTypes = [
    'Preparo Pesado',
    'Preparo Leve',
    'Plantio',
    'Transporte',
  ];

  @override
  void dispose() {
    _tractorWeightController.dispose();
    _implementWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(tractorBallastCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Lastro do Trator',
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
                  // Tractor type selection
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Tipo de Trator',
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
                    children: _tractorTypes.map((type) {
                      return DarkChoiceChip(
                        label: type,
                        isSelected: _tractorType == type,
                        onSelected: () {
                          setState(() {
                            _tractorType = type;
                          });
                        },
                        accentColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Operation type selection
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _operationTypes.map((type) {
                      return DarkChoiceChip(
                        label: type,
                        isSelected: _operationType == type,
                        onSelected: () {
                          setState(() {
                            _operationType = type;
                          });
                        },
                        accentColor: const Color(0xFF4CAF50),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Info card about weight distribution
                  _buildInfoCard(),

                  const SizedBox(height: 24),

                  // Input fields
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Pesos do Conjunto',
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
                          label: 'Peso do Trator',
                          controller: _tractorWeightController,
                          suffix: 'kg',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            final weight = int.tryParse(value);
                            if (weight == null || weight <= 0) {
                              return 'Peso inválido';
                            }
                            if (weight < 1000) {
                              return 'Mínimo 1000 kg';
                            }
                            if (weight > 30000) {
                              return 'Máximo 30000 kg';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: AdaptiveInputField(
                          label: 'Peso do Implemento',
                          controller: _implementWeightController,
                          suffix: 'kg',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            final weight = int.tryParse(value);
                            if (weight == null || weight < 0) {
                              return 'Peso inválido';
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
                    onCalculate: _handleCalculate,
                    onClear: _handleClear,
                    accentColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),

            // Result card
            if (calculation.id.isNotEmpty) ...[
              const SizedBox(height: 32),
              TractorBallastResultCard(calculation: calculation),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    const accentColor = Color(0xFF4CAF50);
    
    const distributionInfo = {
      '4x2': {'front': '30-35%', 'rear': '65-70%'},
      '4x4': {'front': '40-45%', 'rear': '55-60%'},
      'Esteira': {'front': '40-45%', 'rear': '55-60%'},
    };

    final info = distributionInfo[_tractorType]!;

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribuição Ideal para $_tractorType',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Frente: ${info['front']} • Traseira: ${info['rear']}',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCalculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tractorWeight = double.parse(_tractorWeightController.text);
    final implementWeight = double.parse(_implementWeightController.text);

    try {
      await ref.read(tractorBallastCalculatorProvider.notifier).calculate(
            tractorWeight: tractorWeight,
            tractorType: _tractorType,
            implementWeight: implementWeight,
            operationType: _operationType,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    _tractorWeightController.clear();
    _implementWeightController.text = '0';
    setState(() {
      _tractorType = '4x2';
      _operationType = 'Preparo Pesado';
    });
    ref.read(tractorBallastCalculatorProvider.notifier).reset();
  }
}


