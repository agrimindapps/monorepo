import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/brick_calculation.dart';
import '../providers/brick_calculator_provider.dart';

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
                                  width: 180,
                                  child: TextFormField(
                                    controller: _wallLengthController,
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
                                    controller: _wallHeightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Altura',
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
                                    controller: _openingsAreaController,
                                    decoration: const InputDecoration(
                                      labelText: 'Aberturas',
                                      suffixText: 'm²',
                                      border: OutlineInputBorder(),
                                      helperText: 'Portas/janelas',
                                    ),
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
                    _BrickResultCard(calculation: calculation),
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

class _BrickResultCard extends StatelessWidget {
  final BrickCalculation calculation;

  const _BrickResultCard({required this.calculation});

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

            // Main result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total de ${calculation.brickType.displayName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculation.bricksWithWaste}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    'unidades (com ${calculation.wastePercentage.toInt()}% de perda)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Materials
            Text(
              'Materiais para Argamassa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MaterialItem(
                  icon: Icons.inventory_2,
                  label: 'Argamassa',
                  value: '${calculation.mortarBags}',
                  unit: 'sacos (20kg)',
                  color: Colors.brown,
                ),
                _MaterialItem(
                  icon: Icons.grain,
                  label: 'Areia',
                  value: calculation.sandCubicMeters.toStringAsFixed(2),
                  unit: 'm³',
                  color: Colors.amber,
                ),
                _MaterialItem(
                  icon: Icons.inventory,
                  label: 'Cimento',
                  value: '${calculation.cementBags}',
                  unit: 'sacos (50kg)',
                  color: Colors.grey,
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
              label: 'Área da parede',
              value: '${calculation.wallArea.toStringAsFixed(1)} m²',
            ),
            _DetailRow(
              label: 'Área de aberturas',
              value: '${calculation.openingsArea.toStringAsFixed(1)} m²',
            ),
            _DetailRow(
              label: 'Área líquida',
              value: '${calculation.netArea.toStringAsFixed(1)} m²',
            ),
            _DetailRow(
              label: 'Tijolos (sem perda)',
              value: '${calculation.bricksNeeded}',
            ),
            _DetailRow(
              label: 'Tipo de tijolo',
              value: calculation.brickType.displayName,
            ),
            _DetailRow(
              label: 'Dimensões',
              value: calculation.brickType.dimensions,
            ),
            _DetailRow(
              label: 'Consumo',
              value: '${calculation.brickType.unitsPerSquareMeter} un/m²',
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MaterialItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
