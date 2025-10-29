import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/usecases/calculate_paint_consumption_usecase.dart';

/// Input form for paint consumption calculation
class PaintConsumptionInputForm extends StatefulWidget {
  const PaintConsumptionInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final void Function(CalculatePaintConsumptionParams) onCalculate;

  @override
  State<PaintConsumptionInputForm> createState() =>
      _PaintConsumptionInputFormState();
}

class _PaintConsumptionInputFormState extends State<PaintConsumptionInputForm> {
  final _areaController = TextEditingController();
  double _surfacePreparation = 1.0; // Default: parede nova
  int _coats = 2; // Default: 2 demãos

  final Map<double, String> _surfacePreparationOptions = {
    1.0: 'Parede nova (superfície lisa)',
    1.2: 'Repintura (superfície já pintada)',
    1.5: 'Superfície irregular (textura, reboco)',
    2.0: 'Superfície muito irregular (cimento, concreto)',
  };

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      onChanged: _onFormChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Area Input
          TextFormField(
            controller: _areaController,
            decoration: const InputDecoration(
              labelText: 'Área da superfície (m²)',
              hintText: 'Digite a área em metros quadrados',
              prefixIcon: Icon(Icons.square_foot),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              final area = double.tryParse(value.replaceAll(',', '.'));
              if (area == null || area <= 0) {
                return 'Digite um valor válido maior que zero';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Surface Preparation Dropdown
          DropdownButtonFormField<double>(
            value: _surfacePreparation,
            decoration: const InputDecoration(
              labelText: 'Preparo da superfície',
              prefixIcon: Icon(Icons.texture),
              border: OutlineInputBorder(),
            ),
            items: _surfacePreparationOptions.entries.map((entry) {
              return DropdownMenuItem<double>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _surfacePreparation = value;
                });
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Selecione o preparo da superfície';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Coats Input
          DropdownButtonFormField<int>(
            value: _coats,
            decoration: const InputDecoration(
              labelText: 'Número de demãos',
              prefixIcon: Icon(Icons.layers),
              border: OutlineInputBorder(),
            ),
            items: [1, 2, 3, 4].map((coats) {
              return DropdownMenuItem<int>(
                value: coats,
                child: Text('$coats demão${coats > 1 ? 's' : ''}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _coats = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value < 1) {
                return 'Selecione o número de demãos';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Info Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O consumo de tinta varia conforme a superfície e tipo de tinta. Considere comprar 10-15% a mais.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onFormChanged() {
    if (widget.formKey.currentState?.validate() ?? false) {
      widget.formKey.currentState?.save();
    }
  }
}
