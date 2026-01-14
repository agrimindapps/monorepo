// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';
import '../../domain/usecases/calculate_net_salary_usecase.dart';

/// Input form for net salary calculation
class NetSalaryInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateNetSalaryParams) onCalculate;

  const NetSalaryInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<NetSalaryInputForm> createState() => NetSalaryInputFormState();
}

class NetSalaryInputFormState extends State<NetSalaryInputForm> {
  // Controllers
  final _grossSalaryController = TextEditingController();
  final _dependentsController = TextEditingController(text: '0');
  final _transportationVoucherController = TextEditingController(text: '0');
  final _healthInsuranceController = TextEditingController(text: '0');
  final _otherDiscountsController = TextEditingController(text: '0');

  // Formatters

  @override
  void dispose() {
    _grossSalaryController.dispose();
    _dependentsController.dispose();
    _transportationVoucherController.dispose();
    _healthInsuranceController.dispose();
    _otherDiscountsController.dispose();
    super.dispose();
  }

  /// Public method to submit the form from external button
  void submit() {
    _submitForm();
  }

  /// Public method to clear all input fields
  void clear() {
    _grossSalaryController.clear();
    _dependentsController.text = '0';
    _transportationVoucherController.text = '0';
    _healthInsuranceController.text = '0';
    _otherDiscountsController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = CalculatorAccentColors.labor;
    
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gross Salary & Dependents
          ResponsiveInputRow(
            left: AccentCurrencyField(
              controller: _grossSalaryController,
              label: 'Salário Bruto Mensal',
              helperText: 'Informe o salário bruto',
              hintText: 'Ex: 5.000,00',
              accentColor: accentColor,              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obrigatório';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Deve ser maior que zero';
                }
                return null;
              },
            ),
            right: AccentNumberField(
              controller: _dependentsController,
              label: 'Número de Dependentes',
              helperText: 'Para cálculo do IRRF',
              accentColor: accentColor,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final dependents = int.tryParse(value) ?? 0;
                  if (dependents < 0) {
                    return 'Não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Transportation & Health Insurance
          ResponsiveInputRow(
            left: AccentCurrencyField(
              controller: _transportationVoucherController,
              label: 'Vale Transporte (opcional)',
              helperText: 'Máximo 6% do salário bruto',
              hintText: 'Ex: 200,00',
              accentColor: accentColor,              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final voucherValue = _parseNumericValue(value);
                  if (voucherValue < 0) {
                    return 'Não pode ser negativo';
                  }
                }
                return null;
              },
            ),
            right: AccentCurrencyField(
              controller: _healthInsuranceController,
              label: 'Plano de Saúde (opcional)',
              helperText: 'Valor descontado do salário',
              hintText: 'Ex: 150,00',
              accentColor: accentColor,              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final healthValue = _parseNumericValue(value);
                  if (healthValue < 0) {
                    return 'Não pode ser negativo';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          // Other Discounts
          AccentCurrencyField(
            controller: _otherDiscountsController,
            label: 'Outros Descontos (opcional)',
            helperText: 'Empréstimos, adiantamentos, etc.',
            hintText: 'Ex: 300,00',
            accentColor: accentColor,            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final otherValue = _parseNumericValue(value);
                if (otherValue < 0) {
                  return 'Não pode ser negativo';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  double _parseNumericValue(String value) {
    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanValue) ?? 0;
  }

  /// Public method to trigger calculation from parent widget
  void calculate() {
    _submitForm();
  }

  void _submitForm() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    final params = CalculateNetSalaryParams(
      grossSalary: _parseNumericValue(_grossSalaryController.text),
      dependents: int.tryParse(_dependentsController.text) ?? 0,
      transportationVoucher: _parseNumericValue(
        _transportationVoucherController.text,
      ),
      healthInsurance: _parseNumericValue(_healthInsuranceController.text),
      otherDiscounts: _parseNumericValue(_otherDiscountsController.text),
    );

    widget.onCalculate(params);
  }
}
