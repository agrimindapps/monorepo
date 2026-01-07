import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/calculator_input_field.dart';
import '../providers/paint_calculator_provider.dart';
import '../widgets/paint_result_card.dart';

/// Paint calculator page
class PaintCalculatorPage extends ConsumerStatefulWidget {
  const PaintCalculatorPage({super.key});

  @override
  ConsumerState<PaintCalculatorPage> createState() =>
      _PaintCalculatorPageState();
}

class _PaintCalculatorPageState extends ConsumerState<PaintCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _wallAreaController = TextEditingController();
  final _openingsAreaController = TextEditingController(text: '0');

  int _coats = 2;
  String _paintType = 'Acrílica';

  final _paintTypes = [
    'Látex PVA',
    'Acrílica',
    'Acrílica Premium',
    'Esmalte',
    'Esmalte Sintético',
    'Textura',
    'Impermeabilizante',
  ];

  @override
  void dispose() {
    _wallAreaController.dispose();
    _openingsAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(paintCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Tinta'),
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
                                Icons.format_paint,
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
                            '• Informe a área total das paredes (m²)\n'
                            '• Desconte portas e janelas (opcional)\n'
                            '• Escolha o tipo de tinta e demãos\n'
                            '• Receba a quantidade em litros e latas',
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
                              'Áreas',
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
                                  width: 250,
                                  child: StandardInputField(
                                    label: 'Área das Paredes',
                                    controller: _wallAreaController,
                                    suffix: 'm²',
                                    helperText: 'Soma de todas as paredes',
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
                                        return 'Valor inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: StandardInputField(
                                    label: 'Área de Aberturas',
                                    controller: _openingsAreaController,
                                    suffix: 'm²',
                                    helperText: 'Portas e janelas',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null;
                                      }
                                      final num = double.tryParse(value);
                                      if (num == null || num < 0) {
                                        return 'Valor inválido';
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
                                    initialValue: _paintType,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de Tinta',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _paintTypes.map((type) {
                                      return DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _paintType = value ?? 'Acrílica';
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _coats,
                                    decoration: const InputDecoration(
                                      labelText: 'Demãos',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [1, 2, 3, 4, 5].map((coats) {
                                      return DropdownMenuItem(
                                        value: coats,
                                        child: Text('$coats demão${coats > 1 ? 's' : ''}'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _coats = value ?? 2;
                                      });
                                    },
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
                    PaintResultCard(calculation: calculation),
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
      await ref.read(paintCalculatorProvider.notifier).calculate(
        wallArea: double.parse(_wallAreaController.text),
        openingsArea: double.tryParse(_openingsAreaController.text) ?? 0,
        coats: _coats,
        paintType: _paintType,
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
