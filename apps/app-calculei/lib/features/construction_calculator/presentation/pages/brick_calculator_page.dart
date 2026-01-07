import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
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
  final _openingsAreaController = TextEditingController(text: '0');

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Tijolos'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info Card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.crop_square,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Como funciona',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Informe as dimensões da parede (m)\n'
                            '• Desconte portas e janelas (opcional)\n'
                            '• Escolha o tipo de tijolo/bloco\n'
                            '• Receba quantidade de tijolos e argamassa',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Dimensões da Parede',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: StandardInputField(
                                    label: 'Comprimento',
                                    controller: _wallLengthController,
                                    suffix: 'm',
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
                                  child: StandardInputField(
                                    label: 'Altura',
                                    controller: _wallHeightController,
                                    suffix: 'm',
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
                                  child: StandardInputField(
                                    label: 'Aberturas',
                                    controller: _openingsAreaController,
                                    suffix: 'm²',
                                    helperText: 'Portas/janelas',
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                return FilterChip(
                                  selected: isSelected,
                                  label: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.displayName,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        '${type.dimensions} • ${type.unitsPerSquareMeter} un/m²',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isSelected 
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _brickType = type;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Waste slider
                            Text(
                              'Perda: ${_wastePercentage.toInt()}%',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Slider(
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

                            const SizedBox(height: 24),

                            CalculatorButton(
                              label: 'Calcular',
                              icon: Icons.calculate,
                              onPressed: _calculate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result Card
                  if (calculation.id.isNotEmpty) ...[
                    BrickResultCard(calculation: calculation),
                  ],
                ],
              ),
            ),
          ),
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
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
