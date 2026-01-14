import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../core/widgets/dark_choice_chip.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/tire_pressure_calculator_provider.dart';
import '../widgets/tire_pressure_result_card.dart';

/// Tire pressure calculator page for agricultural machinery
class TirePressureCalculatorPage extends ConsumerStatefulWidget {
  const TirePressureCalculatorPage({super.key});

  @override
  ConsumerState<TirePressureCalculatorPage> createState() =>
      _TirePressureCalculatorPageState();
}

class _TirePressureCalculatorPageState
    extends ConsumerState<TirePressureCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _axleLoadController = TextEditingController();
  final _tireSizeController = TextEditingController();

  String _tireType = 'Agrícola Diagonal';
  String _operationType = 'Campo';

  final _tireTypes = [
    'Agrícola Diagonal',
    'Agrícola Radial',
    'Implemento',
  ];

  final _operationTypes = [
    'Campo',
    'Estrada',
    'Misto',
  ];

  // Common tire sizes for quick selection
  final _commonTireSizes = [
    '18.4-34',
    '18.4-30',
    '14.9-28',
    '14.9-24',
    '12.4-28',
    '12.4-24',
    '11.2-24',
    '480/80R46',
    '420/85R34',
    '380/85R28',
  ];

  @override
  void dispose() {
    _axleLoadController.dispose();
    _tireSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(tirePressureCalculatorProvider);
    const accentColor = Color(0xFF4CAF50); // Green for agriculture

    return CalculatorPageLayout(
      title: 'Pressão de Pneus',
      subtitle: 'Máquinas Agrícolas',
      icon: Icons.tire_repair,
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
                  // Tire Type Selection
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Tipo de Pneu',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTireTypeSelector(),
                  const SizedBox(height: 24),

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

                  // Tire Parameters
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Text(
                        'Parâmetros do Pneu',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Axle Load and Tire Size
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Carga no Eixo',
                          controller: _axleLoadController,
                          hintText: 'Ex: 2500',
                          suffix: 'kg',
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
                            if (num > 20000) {
                              return 'Máximo 20.000 kg';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: AdaptiveInputField(
                          label: 'Tamanho do Pneu',
                          controller: _tireSizeController,
                          hintText: 'Ex: 18.4-34',
                          suffix: '',
                          keyboardType: TextInputType.text,
                          inputFormatters: const [],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            }
                            if (!_isValidTireSize(value)) {
                              return 'Formato inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Common tire sizes quick selector
                  _buildCommonTireSizesSection(),
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
              TirePressureResultCard(calculation: calculation),
          ],
        ),
      ),
    );
  }

  Widget _buildTireTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _tireTypes.map((type) {
        final isSelected = _tireType == type;
        return DarkChoiceChip(
          label: type,
          isSelected: isSelected,
          onSelected: () {
            setState(() {
              _tireType = type;
            });
          },
          accentColor: const Color(0xFF4CAF50),
        );
      }).toList(),
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
            });
          },
          accentColor: const Color(0xFF4CAF50),
        );
      }).toList(),
    );
  }

  Widget _buildCommonTireSizesSection() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tamanhos Comuns',
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonTireSizes.map((size) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _tireSizeController.text = size;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  bool _isValidTireSize(String tireSize) {
    // Accept formats like: 18.4-34, 14.9-28, 12.4/11-28, 480/80R46
    final patterns = [
      RegExp(r'^\d+\.?\d*-\d+$'), // 18.4-34
      RegExp(r'^\d+\.?\d*/\d+-\d+$'), // 12.4/11-28
      RegExp(r'^\d+/\d+R?\d+$'), // 480/80R46
    ];

    return patterns.any((pattern) => pattern.hasMatch(tireSize.trim()));
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final axleLoad = double.parse(_axleLoadController.text);
    final tireSize = _tireSizeController.text.trim();

    try {
      await ref.read(tirePressureCalculatorProvider.notifier).calculate(
            tireType: _tireType,
            axleLoad: axleLoad,
            tireSize: tireSize,
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
    _axleLoadController.clear();
    _tireSizeController.clear();
    setState(() {
      _tireType = 'Agrícola Diagonal';
      _operationType = 'Campo';
    });
    ref.read(tirePressureCalculatorProvider.notifier).reset();
  }
}
