import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/usecases/calculate_flooring_usecase.dart';

/// Input form for flooring calculation
class FlooringInputForm extends StatefulWidget {
  const FlooringInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final void Function(CalculateFlooringParams) onCalculate;

  @override
  State<FlooringInputForm> createState() => _FlooringInputFormState();
}

class _FlooringInputFormState extends State<FlooringInputForm> {
  final _areaController = TextEditingController();
  final _tileWidthController = TextEditingController();
  final _tileLengthController = TextEditingController();
  final _pricePerTileController = TextEditingController();
  double _wastePercentage = 10.0;

  final Map<double, String> _wasteOptions = {
    5.0: '5% - Área regular, profissional experiente',
    10.0: '10% - Área normal (recomendado)',
    15.0: '15% - Área irregular ou iniciante',
    20.0: '20% - Área muito irregular',
  };

  @override
  void dispose() {
    _areaController.dispose();
    _tileWidthController.dispose();
    _tileLengthController.dispose();
    _pricePerTileController.dispose();
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
              labelText: 'Área total (m²)',
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

          // Tile Dimensions Row
          Row(
            children: [
              // Tile Width
              Expanded(
                child: TextFormField(
                  controller: _tileWidthController,
                  decoration: const InputDecoration(
                    labelText: 'Largura (cm)',
                    hintText: 'Ex: 60',
                    prefixIcon: Icon(Icons.width_normal),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    final width = double.tryParse(value.replaceAll(',', '.'));
                    if (width == null || width <= 0) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Tile Length
              Expanded(
                child: TextFormField(
                  controller: _tileLengthController,
                  decoration: const InputDecoration(
                    labelText: 'Comprimento (cm)',
                    hintText: 'Ex: 60',
                    prefixIcon: Icon(Icons.height),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obrigatório';
                    }
                    final length = double.tryParse(value.replaceAll(',', '.'));
                    if (length == null || length <= 0) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price per Tile (Optional)
          TextFormField(
            controller: _pricePerTileController,
            decoration: const InputDecoration(
              labelText: 'Preço por peça (R\$) - Opcional',
              hintText: 'Digite o preço unitário',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final price = double.tryParse(value.replaceAll(',', '.'));
                if (price == null || price < 0) {
                  return 'Valor inválido';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Waste Percentage Dropdown
          DropdownButtonFormField<double>(
            value: _wastePercentage,
            decoration: const InputDecoration(
              labelText: 'Percentual de perda',
              prefixIcon: Icon(Icons.percent),
              border: OutlineInputBorder(),
            ),
            items: _wasteOptions.entries.map((entry) {
              return DropdownMenuItem<double>(
                value: entry.key,
                child: Text(
                    '${entry.key.toInt()}% - ${entry.value.split(' - ')[1]}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _wastePercentage = value;
                });
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Selecione o percentual de perda';
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
                    'O percentual de perda compensa quebras, cortes e rejunte. Para áreas irregulares, considere percentuais maiores.',
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
      _submitForm();
    }
  }

  void _submitForm() {
    final area = double.parse(_areaController.text.replaceAll(',', '.'));
    final tileWidth =
        double.parse(_tileWidthController.text.replaceAll(',', '.'));
    final tileLength =
        double.parse(_tileLengthController.text.replaceAll(',', '.'));

    final pricePerTile = _pricePerTileController.text.isNotEmpty
        ? double.parse(_pricePerTileController.text.replaceAll(',', '.'))
        : null;

    final params = CalculateFlooringParams(
      area: area,
      tileWidth: tileWidth,
      tileLength: tileLength,
      pricePerTile: pricePerTile,
      wastePercentage: _wastePercentage,
    );

    widget.onCalculate(params);
  }
}
