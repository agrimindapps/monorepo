import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../providers/plumbing_calculator_provider.dart';
import '../widgets/plumbing_result_card.dart';

/// Plumbing calculator page
class PlumbingCalculatorPage extends ConsumerStatefulWidget {
  const PlumbingCalculatorPage({super.key});

  @override
  ConsumerState<PlumbingCalculatorPage> createState() =>
      _PlumbingCalculatorPageState();
}

class _PlumbingCalculatorPageState extends ConsumerState<PlumbingCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _elbowsController = TextEditingController();
  final _teesController = TextEditingController();
  final _couplingsController = TextEditingController();

  String _systemType = 'Água Fria';
  String _pipeDiameter = '25mm';

  final _systemTypes = [
    'Água Fria',
    'Água Quente',
    'Esgoto',
    'Pluvial',
  ];

  final _diameterOptions = [
    '20mm',
    '25mm',
    '32mm',
    '40mm',
    '50mm',
    '75mm',
    '100mm',
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    _elbowsController.dispose();
    _teesController.dispose();
    _couplingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(plumbingCalculatorProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = CalculatorAccentColors.construction;

    return CalculatorPageLayout(
      title: 'Calculadora de Tubulação',
      subtitle: 'PVC e Conexões',
      icon: Icons.plumbing,
      accentColor: accentColor,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sistema de Tubulação',
                    style: TextStyle(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.9)
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // System Type Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _systemTypes.map((type) {
                      final isSelected = _systemType == type;
                      return _SelectionChip(
                        label: type,
                        isSelected: isSelected,
                        accentColor: accentColor,
                        isDark: isDark,
                        theme: theme,
                        onSelected: () {
                          setState(() {
                            _systemType = type;
                            // Auto-adjust diameter based on system type
                            if (type == 'Água Fria' || type == 'Água Quente') {
                              _pipeDiameter = '25mm';
                            } else if (type == 'Esgoto') {
                              _pipeDiameter = '40mm';
                            } else if (type == 'Pluvial') {
                              _pipeDiameter = '75mm';
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Diâmetro do Tubo',
                    style: TextStyle(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.9)
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Diameter Selection
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _diameterOptions.map((diameter) {
                      final isSelected = _pipeDiameter == diameter;
                      return _SelectionChip(
                        label: diameter,
                        isSelected: isSelected,
                        accentColor: accentColor,
                        isDark: isDark,
                        theme: theme,
                        onSelected: () {
                          setState(() {
                            _pipeDiameter = diameter;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Dimensões e Conexões',
                    style: TextStyle(
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.9)
                          : theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Length Input
                  SizedBox(
                    width: 250,
                    child: _DarkInputField(
                      label: 'Comprimento Total',
                      controller: _lengthController,
                      suffix: 'm',
                      accentColor: accentColor,
                      isDark: isDark,
                      theme: theme,
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

                  const SizedBox(height: 16),

                  // Fittings Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: 180,
                        child: _DarkInputField(
                          label: 'Joelhos 90°',
                          controller: _elbowsController,
                          suffix: 'un',
                          accentColor: accentColor,
                          isDark: isDark,
                          theme: theme,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Inválido';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _DarkInputField(
                          label: 'Ts (Junções)',
                          controller: _teesController,
                          suffix: 'un',
                          accentColor: accentColor,
                          isDark: isDark,
                          theme: theme,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Inválido';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _DarkInputField(
                          label: 'Luvas',
                          controller: _couplingsController,
                          suffix: 'un',
                          accentColor: accentColor,
                          isDark: isDark,
                          theme: theme,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final num = int.tryParse(value);
                              if (num == null || num < 0) {
                                return 'Inválido';
                              }
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
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),

            // Result Card
            if (calculation.id.isNotEmpty) ...[
              const SizedBox(height: 32),
              PlumbingResultCard(calculation: calculation),
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
          content: Text('Por favor, preencha todos os campos corretamente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(plumbingCalculatorProvider.notifier).calculate(
        systemType: _systemType,
        pipeDiameter: _pipeDiameter,
        totalLength: double.parse(_lengthController.text),
        numberOfElbows: int.tryParse(_elbowsController.text) ?? 0,
        numberOfTees: int.tryParse(_teesController.text) ?? 0,
        numberOfCouplings: int.tryParse(_couplingsController.text) ?? 0,
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
    _elbowsController.clear();
    _teesController.clear();
    _couplingsController.clear();
    setState(() {
      _systemType = 'Água Fria';
      _pipeDiameter = '25mm';
    });
    ref.read(plumbingCalculatorProvider.notifier).reset();
  }
}

/// Dark themed input field for construction calculator
class _DarkInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final Color accentColor;
  final bool isDark;
  final ThemeData theme;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _DarkInputField({
    required this.label,
    required this.controller,
    required this.accentColor,
    required this.isDark,
    required this.theme,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.7)
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 16,
            ),
            filled: true,
            fillColor: isDark 
                ? Colors.white.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Selection chip for system type/diameter
class _SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onSelected;

  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.theme,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? accentColor.withValues(alpha: 0.15)
          : isDark 
              ? Colors.white.withValues(alpha: 0.05)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
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
                  ? accentColor
                  : isDark 
                      ? Colors.white.withValues(alpha: 0.8)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
