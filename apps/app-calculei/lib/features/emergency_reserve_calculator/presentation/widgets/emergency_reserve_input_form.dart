// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../domain/usecases/calculate_emergency_reserve_usecase.dart';

/// Input form for emergency reserve calculation
class EmergencyReserveInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateEmergencyReserveParams) onCalculate;

  const EmergencyReserveInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<EmergencyReserveInputForm> createState() =>
      _EmergencyReserveInputFormState();
}

class _EmergencyReserveInputFormState extends State<EmergencyReserveInputForm> {
  // Controllers
  final _monthlyExpensesController = TextEditingController();
  final _extraExpensesController = TextEditingController(text: '0');
  final _desiredMonthsController = TextEditingController(text: '6');
  final _monthlySavingsController = TextEditingController(text: '0');

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _monthlyExpensesController.dispose();
    _extraExpensesController.dispose();
    _desiredMonthsController.dispose();
    _monthlySavingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Monthly Expenses
          TextFormField(
            controller: _monthlyExpensesController,
            decoration: const InputDecoration(
              labelText: 'Despesas Mensais',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Total de gastos fixos e variáveis',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe as despesas mensais';
              }
              final numericValue = _parseNumericValue(value);
              if (numericValue <= 0) {
                return 'Despesas devem ser maior que zero';
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Extra Expenses
          TextFormField(
            controller: _extraExpensesController,
            decoration: const InputDecoration(
              labelText: 'Despesas Extras (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Custos eventuais ou sazonais',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final numericValue = _parseNumericValue(value);
                if (numericValue < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Desired Months
          TextFormField(
            controller: _desiredMonthsController,
            decoration: const InputDecoration(
              labelText: 'Meses de Cobertura',
              border: OutlineInputBorder(),
              helperText: 'Recomendado: 6 a 12 meses',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o número de meses';
              }
              final months = int.tryParse(value) ?? 0;
              if (months <= 0) {
                return 'Meses deve ser maior que zero';
              }
              if (months > 120) {
                return 'Máximo 120 meses (10 anos)';
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Monthly Savings
          TextFormField(
            controller: _monthlySavingsController,
            decoration: const InputDecoration(
              labelText: 'Poupança Mensal (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Quanto pode poupar por mês',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final numericValue = _parseNumericValue(value);
                if (numericValue < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
        ],
      ),
    );
  }

  double _parseNumericValue(String value) {
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0;
  }

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) return;

    final params = CalculateEmergencyReserveParams(
      monthlyExpenses: _parseNumericValue(_monthlyExpensesController.text),
      extraExpenses: _parseNumericValue(_extraExpensesController.text),
      desiredMonths: int.tryParse(_desiredMonthsController.text) ?? 6,
      monthlySavings: _parseNumericValue(_monthlySavingsController.text),
    );

    widget.onCalculate(params);
  }
}
