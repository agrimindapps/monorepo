import 'package:core/core.dart' hide FormState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/calculator_action_buttons.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/adaptive_input_field.dart';
import '../providers/rebar_calculator_provider.dart';
import '../widgets/rebar_result_card.dart';

/// Rebar (steel reinforcement) calculator page
class RebarCalculatorPage extends ConsumerStatefulWidget {
  const RebarCalculatorPage({super.key});

  @override
  ConsumerState<RebarCalculatorPage> createState() =>
      _RebarCalculatorPageState();
}

class _RebarCalculatorPageState extends ConsumerState<RebarCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _volumeController = TextEditingController();

  String _structureType = 'Laje';
  String _rebarDiameter = '8mm';

  final _structureTypes = [
    'Laje',
    'Viga',
    'Pilar',
    'Fundação',
  ];

  final _diameterOptions = [
    '5mm',
    '6.3mm',
    '8mm',
    '10mm',
    '12.5mm',
    '16mm',
    '20mm',
  ];

  // Steel rate info for each structure type
  final _steelRates = {
    'Laje': '80 kg/m³',
    'Viga': '120 kg/m³',
    'Pilar': '150 kg/m³',
    'Fundação': '60 kg/m³',
  };

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(rebarCalculatorProvider);

    return CalculatorPageLayout(
      title: 'Calculadora de Ferragem',
      subtitle: 'Armadura de Aço',
      icon: Icons.architecture,
      accentColor: CalculatorAccentColors.construction,
      currentCategory: 'construcao',
      maxContentWidth: 800,
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = isDark 
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.black87;

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
                        'Tipo de Estrutura',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Structure Type Selection
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _structureTypes.map((type) {
                          final isSelected = _structureType == type;
                          return _SelectionChip(
                            label: type,
                            subtitle: _steelRates[type],
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _structureType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Volume de Concreto',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Volume Input
                      SizedBox(
                        width: 300,
                        child: AdaptiveInputField(
                          label: 'Volume',
                          controller: _volumeController,
                          suffix: 'm³',
                          hintText: 'Ex: 10.0',
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
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
                        'Diâmetro da Ferragem',
                        style: TextStyle(
                          color: textColor,
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
                          final isSelected = _rebarDiameter == diameter;
                          return _SelectionChip(
                            label: diameter,
                            isSelected: isSelected,
                            onSelected: () {
                              setState(() {
                                _rebarDiameter = diameter;
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
                  RebarResultCard(calculation: calculation),
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
      await ref.read(rebarCalculatorProvider.notifier).calculate(
            structureType: _structureType,
            concreteVolume: double.parse(_volumeController.text),
            rebarDiameter: _rebarDiameter,
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
    _volumeController.clear();
    setState(() {
      _structureType = 'Laje';
      _rebarDiameter = '8mm';
    });
    ref.read(rebarCalculatorProvider.notifier).reset();
  }
}
class _SelectionChip extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SelectionChip({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBgColor = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.1);
    final borderColor = isDark 
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);
    final textColor = isDark 
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black87;
    final subtitleColor = isDark 
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black54;

    return Material(
      color: isSelected
          ? CalculatorAccentColors.construction.withValues(alpha: 0.15)
          : chipBgColor,
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
                  : borderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected
                      ? CalculatorAccentColors.construction
                      : textColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
