import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/usecases/calculate_cost_per_sqm_usecase.dart';

/// Input form for cost per square meter calculation
class CostPerSqmInputForm extends StatefulWidget {
  const CostPerSqmInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  final GlobalKey<FormState> formKey;
  final void Function(CalculateCostPerSqmParams) onCalculate;

  @override
  State<CostPerSqmInputForm> createState() => _CostPerSqmInputFormState();
}

class _CostPerSqmInputFormState extends State<CostPerSqmInputForm> {
  final _areaController = TextEditingController();
  final _costPerSqmController = TextEditingController();

  @override
  void dispose() {
    _areaController.dispose();
    _costPerSqmController.dispose();
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
              labelText: 'Área (m²)',
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

          // Cost per Square Meter Input
          TextFormField(
            controller: _costPerSqmController,
            decoration: const InputDecoration(
              labelText: 'Custo por m² (R\$)',
              hintText: 'Digite o custo por metro quadrado',
              prefixIcon: Icon(Icons.attach_money),
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
              final cost = double.tryParse(value.replaceAll(',', '.'));
              if (cost == null || cost <= 0) {
                return 'Digite um valor válido maior que zero';
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
                    'O custo por m² varia por região e tipo de obra. Consulte valores atualizados na sua localidade.',
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
