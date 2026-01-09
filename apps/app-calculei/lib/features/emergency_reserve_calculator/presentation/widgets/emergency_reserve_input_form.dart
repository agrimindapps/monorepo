// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/utils/brazilian_currency_formatter.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';
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
      EmergencyReserveInputFormState();
}

class EmergencyReserveInputFormState extends State<EmergencyReserveInputForm> {
  // Controllers
  final _monthlyExpensesController = TextEditingController();
  final _extraExpensesController = TextEditingController(text: '0');
  final _desiredMonthsController = TextEditingController(text: '6');
  final _monthlySavingsController = TextEditingController(text: '0');

  // Formatters

  @override
  void dispose() {
    _monthlyExpensesController.dispose();
    _extraExpensesController.dispose();
    _desiredMonthsController.dispose();
    _monthlySavingsController.dispose();
    super.dispose();
  }

  /// Public method to submit the form from external button
  void submit() {
    _submitForm();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.financial;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: AccentCurrencyField(
              controller: _monthlyExpensesController,
              label: 'Despesas Mensais',
              helperText: 'Total de gastos fixos e variáveis',
              accentColor: accentColor,              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe as despesas mensais';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Despesas devem ser maior que zero';
                }
                return null;
              },
            ),
            right: AccentCurrencyField(
              controller: _extraExpensesController,
              label: 'Despesas Extras (opcional)',
              helperText: 'Custos eventuais ou sazonais',
              accentColor: accentColor,              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final numericValue = _parseNumericValue(value);
                  if (numericValue < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: AccentNumberField(
              controller: _desiredMonthsController,
              label: 'Meses de Cobertura',
              helperText: 'Recomendado: 6 a 12 meses',
              accentColor: accentColor,
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
            ),
            right: AccentCurrencyField(
              controller: _monthlySavingsController,
              label: 'Poupança Mensal (opcional)',
              helperText: 'Quanto pode poupar por mês',
              accentColor: accentColor,              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final numericValue = _parseNumericValue(value);
                  if (numericValue < 0) {
                    return 'Valor não pode ser negativo';
                  }
                }
                return null;
              },
            ),
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
    if (!widget.formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final params = CalculateEmergencyReserveParams(
      monthlyExpenses: _parseNumericValue(_monthlyExpensesController.text),
      extraExpenses: _parseNumericValue(_extraExpensesController.text),
      desiredMonths: int.tryParse(_desiredMonthsController.text) ?? 6,
      monthlySavings: _parseNumericValue(_monthlySavingsController.text),
    );

    widget.onCalculate(params);
  }
}
