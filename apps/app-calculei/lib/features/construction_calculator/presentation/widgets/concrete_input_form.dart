import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/usecases/calculate_concrete_usecase.dart';

/// Input form for concrete calculation
class ConcreteInputForm extends StatefulWidget {
  const ConcreteInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final void Function(CalculateConcreteParams) onCalculate;

  @override
  State<ConcreteInputForm> createState() => _ConcreteInputFormState();
}

class _ConcreteInputFormState extends State<ConcreteInputForm> {
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _cementPriceController = TextEditingController();
  final _sandPriceController = TextEditingController();
  final _gravelPriceController = TextEditingController();

  String _concreteType = 'fck 20';

  final Map<String, String> _concreteTypes = {
    'fck 10': 'FCK 10 - Estruturas simples, contrapiso',
    'fck 15': 'FCK 15 - Fundações, estruturas leves',
    'fck 20': 'FCK 20 - Lajes, vigas, pilares (recomendado)',
    'fck 25': 'FCK 25 - Estruturas especiais',
    'fck 30': 'FCK 30 - Alta resistência',
  };

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _cementPriceController.dispose();
    _sandPriceController.dispose();
    _gravelPriceController.dispose();
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
          // Dimensions Row
          Row(
            children: [
              // Length
              Expanded(
                child: TextFormField(
                  controller: _lengthController,
                  decoration: const InputDecoration(
                    labelText: 'Comprimento (m)',
                    hintText: 'Ex: 5.0',
                    prefixIcon: Icon(Icons.straighten),
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

              const SizedBox(width: 16),

              // Width
              Expanded(
                child: TextFormField(
                  controller: _widthController,
                  decoration: const InputDecoration(
                    labelText: 'Largura (m)',
                    hintText: 'Ex: 3.0',
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

              // Height
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Altura (m)',
                    hintText: 'Ex: 0.15',
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
                    final height = double.tryParse(value.replaceAll(',', '.'));
                    if (height == null || height <= 0) {
                      return 'Inválido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Concrete Type Dropdown
          DropdownButtonFormField<String>(
            value: _concreteType,
            decoration: const InputDecoration(
              labelText: 'Tipo de concreto',
              prefixIcon: Icon(Icons.build),
              border: OutlineInputBorder(),
            ),
            items: _concreteTypes.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                    '${entry.key.toUpperCase()} - ${entry.value.split(' - ')[1]}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _concreteType = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecione o tipo de concreto';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Prices Section (Optional)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preços dos materiais (Opcional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 12),

                // Cement Price
                TextFormField(
                  controller: _cementPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço do cimento (saco 50kg)',
                    hintText: 'R\$ 25,00',
                    prefixIcon: Icon(Icons.inventory),
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

                const SizedBox(height: 12),

                // Sand and Gravel Prices Row
                Row(
                  children: [
                    // Sand Price
                    Expanded(
                      child: TextFormField(
                        controller: _sandPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Preço da areia (m³)',
                          hintText: 'R\$ 120,00',
                          prefixIcon: Icon(Icons.grain),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final price =
                                double.tryParse(value.replaceAll(',', '.'));
                            if (price == null || price < 0) {
                              return 'Inválido';
                            }
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Gravel Price
                    Expanded(
                      child: TextFormField(
                        controller: _gravelPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Preço da brita (m³)',
                          hintText: 'R\$ 150,00',
                          prefixIcon: Icon(Icons.terrain),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final price =
                                double.tryParse(value.replaceAll(',', '.'));
                            if (price == null || price < 0) {
                              return 'Inválido';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                    'As dimensões devem estar em metros. O cálculo segue as normas da ABNT para traços de concreto.',
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
    final length = double.parse(_lengthController.text.replaceAll(',', '.'));
    final width = double.parse(_widthController.text.replaceAll(',', '.'));
    final height = double.parse(_heightController.text.replaceAll(',', '.'));

    final cementPricePerBag = _cementPriceController.text.isNotEmpty
        ? double.parse(_cementPriceController.text.replaceAll(',', '.'))
        : null;

    final sandPricePerCubicMeter = _sandPriceController.text.isNotEmpty
        ? double.parse(_sandPriceController.text.replaceAll(',', '.'))
        : null;

    final gravelPricePerCubicMeter = _gravelPriceController.text.isNotEmpty
        ? double.parse(_gravelPriceController.text.replaceAll(',', '.'))
        : null;

    final params = CalculateConcreteParams(
      length: length,
      width: width,
      height: height,
      concreteType: _concreteType,
      cementPricePerBag: cementPricePerBag,
      sandPricePerCubicMeter: sandPricePerCubicMeter,
      gravelPricePerCubicMeter: gravelPricePerCubicMeter,
    );

    widget.onCalculate(params);
  }
}
