import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flooring_calculator_provider.dart';

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
                                  width: 180,
                                  child: TextFormField(
                                    controller: _roomLengthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Comprimento',
                                      suffixText: 'm',
                                      border: OutlineInputBorder(),
                                    ),
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
                                  width: 180,
                                  child: TextFormField(
                                    controller: _roomWidthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Largura',
                                      suffixText: 'm',
                                      border: OutlineInputBorder(),
                                    ),
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
                                  width: 150,
                                  child: TextFormField(
                                    controller: _tileLengthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Comprimento',
                                      suffixText: 'cm',
                                      border: OutlineInputBorder(),
                                    ),
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
                                  width: 150,
                                  child: TextFormField(
                                    controller: _tileWidthController,
                                    decoration: const InputDecoration(
                                      labelText: 'Largura',
                                      suffixText: 'cm',
                                      border: OutlineInputBorder(),
                                    ),
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
                                  width: 150,
                                  child: TextFormField(
                                    controller: _tilesPerBoxController,
                                    decoration: const InputDecoration(
                                      labelText: 'Peças/caixa',
                                      border: OutlineInputBorder(),
                                    ),
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
                                    value: _flooringType,
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

                            FilledButton.icon(
                              onPressed: _calculate,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calcular'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result Card
                  if (calculation.id.isNotEmpty) ...[
                    _FlooringResultCard(calculation: calculation),
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

class _FlooringResultCard extends StatelessWidget {
  final dynamic calculation;

  const _FlooringResultCard({required this.calculation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Main results
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ResultHighlight(
                  label: 'Caixas',
                  value: '${calculation.boxesNeeded}',
                  icon: Icons.inventory_2,
                  color: Colors.brown,
                ),
                _ResultHighlight(
                  label: 'Peças',
                  value: '${calculation.tilesWithWaste}',
                  icon: Icons.grid_view,
                  color: Colors.blue,
                ),
                _ResultHighlight(
                  label: 'Área',
                  value: '${calculation.roomArea.toStringAsFixed(1)} m²',
                  icon: Icons.square_foot,
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Materials
            Text(
              'Materiais Complementares',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MaterialChip(
                  label: 'Rejunte',
                  value: '${calculation.groutKg.toStringAsFixed(1)} kg',
                  icon: Icons.format_color_fill,
                ),
                _MaterialChip(
                  label: 'Argamassa',
                  value: '${calculation.mortarKg.toStringAsFixed(1)} kg',
                  icon: Icons.construction,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Details
            Text(
              'Detalhes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _DetailRow(
              label: 'Peças (sem perda)',
              value: '${calculation.tilesNeeded}',
            ),
            _DetailRow(
              label: 'Peças (com perda)',
              value: '${calculation.tilesWithWaste}',
            ),
            _DetailRow(
              label: 'Perda considerada',
              value: '${calculation.wastePercentage.toInt()}%',
            ),
            _DetailRow(
              label: 'Área da peça',
              value: '${(calculation.tileArea * 10000).toStringAsFixed(0)} cm²',
            ),
            _DetailRow(
              label: 'Peças por caixa',
              value: '${calculation.tilesPerBox}',
            ),
            _DetailRow(
              label: 'Tipo de piso',
              value: calculation.flooringType,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultHighlight extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultHighlight({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MaterialChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MaterialChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
