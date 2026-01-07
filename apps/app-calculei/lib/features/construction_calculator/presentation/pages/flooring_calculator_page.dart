import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../providers/flooring_calculator_provider.dart';
import '../widgets/flooring_result_card.dart';

/// Flooring calculator page
class FlooringCalculatorPage extends ConsumerStatefulWidget {
  const FlooringCalculatorPage({super.key});

  @override
  ConsumerState<FlooringCalculatorPage> createState() =>
      _FlooringCalculatorPageState();
}

class _FlooringCalculatorPageState extends ConsumerState<FlooringCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomLengthController = TextEditingController();
  final _roomWidthController = TextEditingController();
  final _tileLengthController = TextEditingController(text: '60');
  final _tileWidthController = TextEditingController(text: '60');
  final _tilesPerBoxController = TextEditingController(text: '6');

  double _wastePercentage = 10;
  String _flooringType = 'Porcelanato';

  final _flooringTypes = [
    'Cerâmica',
    'Porcelanato',
    'Porcelanato Polido',
    'Piso Vinílico',
    'Laminado',
    'Pedra Natural',
  ];

  @override
  void dispose() {
    _roomLengthController.dispose();
    _roomWidthController.dispose();
    _tileLengthController.dispose();
    _tileWidthController.dispose();
    _tilesPerBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(flooringCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Piso'),
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
                                Icons.grid_on,
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
                            '• Informe as dimensões do ambiente (m)\n'
                            '• Informe o tamanho das peças (cm)\n'
                            '• Defina a perda e peças por caixa\n'
                            '• Receba quantidade de peças, caixas e rejunte',
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
                              'Dimensões do Ambiente',
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
                                    controller: _roomLengthController,
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
                                    label: 'Largura',
                                    controller: _roomWidthController,
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
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Dimensões da Peça',
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
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Comprimento',
                                    controller: _tileLengthController,
                                    suffix: 'cm',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Largura',
                                    controller: _tileWidthController,
                                    suffix: 'cm',
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: StandardInputField(
                                    label: 'Peças/caixa',
                                    controller: _tilesPerBoxController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Obrigatório';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'Configurações',
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
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _flooringType,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de Piso',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _flooringTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _flooringType = value ?? 'Porcelanato';
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Perda: ${_wastePercentage.toInt()}%',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Slider(
                                        value: _wastePercentage,
                                        min: 5,
                                        max: 20,
                                        divisions: 15,
                                        label: '${_wastePercentage.toInt()}%',
                                        onChanged: (value) {
                                          setState(() {
                                            _wastePercentage = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                    FlooringResultCard(calculation: calculation),
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
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(flooringCalculatorProvider.notifier).calculate(
        roomLength: double.parse(_roomLengthController.text),
        roomWidth: double.parse(_roomWidthController.text),
        tileLength: double.parse(_tileLengthController.text),
        tileWidth: double.parse(_tileWidthController.text),
        tilesPerBox: int.parse(_tilesPerBoxController.text),
        wastePercentage: _wastePercentage,
        flooringType: _flooringType,
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
