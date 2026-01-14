import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../../domain/entities/brick_calculation.dart';
import '../providers/brick_calculator_provider.dart';
import '../widgets/brick_result_card.dart';

/// Brick calculator page
class BrickCalculatorPage extends ConsumerStatefulWidget {
  const BrickCalculatorPage({super.key});

  @override
  ConsumerState<BrickCalculatorPage> createState() =>
      _BrickCalculatorPageState();
}

class _BrickCalculatorPageState extends ConsumerState<BrickCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _wallLengthController = TextEditingController();
  final _wallHeightController = TextEditingController();
  final _openingsAreaController = TextEditingController();

  BrickType _brickType = BrickType.ceramic6Holes;
  double _wastePercentage = 5;

  @override
  void dispose() {
    _wallLengthController.dispose();
    _wallHeightController.dispose();
    _openingsAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(brickCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Tijolos',
      subtitle: 'Alvenaria e Blocos',
      icon: Icons.crop_square,
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
              child: Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dimensões da Parede',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input fields row
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 200,
                            child: AdaptiveInputField(
                              label: 'Comprimento',
                              controller: _wallLengthController,
                              suffix: 'm',
                              hintText: 'Ex: 4.5',
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
                              controller: _wallHeightController,
                              suffix: 'm',
                              hintText: 'Ex: 3.0',
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
                              label: 'Aberturas',
                              controller: _openingsAreaController,
                              suffix: 'm²',
                              hintText: 'Portas/janelas',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Tipo de Tijolo/Bloco',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brick Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: BrickType.values.map((type) {
                          final isSelected = _brickType == type;
                          return _BrickTypeChip(
                            type: type,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _brickType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Waste slider
                      Text(
                        'Perda: ${_wastePercentage.toInt()}%',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: CalculatorAccentColors.construction,
                          thumbColor: CalculatorAccentColors.construction,
                          overlayColor: CalculatorAccentColors.construction.withValues(alpha: 0.2),
                          inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _wastePercentage,
                          min: 3,
                          max: 15,
                          divisions: 12,
                          label: '${_wastePercentage.toInt()}%',
                          onChanged: (value) {
                            setState(() {
                              _wastePercentage = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      CalculatorActionButtons(
                        onCalculate: _calculate,
                        onClear: _clear,
                        accentColor: CalculatorAccentColors.construction,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Result Card
            if (calculation.id.isNotEmpty) ...[
              const SizedBox(height: 32),
              BrickResultCard(calculation: calculation),
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
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(brickCalculatorProvider.notifier).calculate(
        wallLength: double.parse(_wallLengthController.text),
        wallHeight: double.parse(_wallHeightController.text),
        openingsArea: double.tryParse(_openingsAreaController.text) ?? 0,
        brickType: _brickType,
        wastePercentage: _wastePercentage,
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
            content: Text(e is Failure ? e.message : e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clear() {
    _wallLengthController.clear();
    _wallHeightController.clear();
    _openingsAreaController.clear();
    setState(() {
      _brickType = BrickType.ceramic6Holes;
      _wastePercentage = 5;
    });
    ref.read(brickCalculatorProvider.notifier).reset();
  }
}

/// Brick type selection chip
class _BrickTypeChip extends StatelessWidget {
  final BrickType type;
  final bool isSelected;
  final VoidCallback onSelected;

  const _BrickTypeChip({
    required this.type,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? CalculatorAccentColors.construction
                      : isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${type.dimensions} • ${type.unitsPerSquareMeter} un/m²',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? CalculatorAccentColors.construction.withValues(alpha: 0.8)
                      : isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
