// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
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
  State<NetSalaryInputForm> createState() => _NetSalaryInputFormState();
}

class _NetSalaryInputFormState extends State<NetSalaryInputForm> {
  // Controllers
  final _grossSalaryController = TextEditingController();
  final _dependentsController = TextEditingController(text: '0');
  final _transportationVoucherController = TextEditingController(text: '0');
  final _healthInsuranceController = TextEditingController(text: '0');
  final _otherDiscountsController = TextEditingController(text: '0');

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _grossSalaryController.dispose();
    _dependentsController.dispose();
    _transportationVoucherController.dispose();
    _healthInsuranceController.dispose();
    _otherDiscountsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gross Salary Input
          TextFormField(
            controller: _grossSalaryController,
            decoration: const InputDecoration(
              labelText: 'Salário Bruto Mensal',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Ex: 3.000,00',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o salário bruto';
              }
              final numericValue = _parseNumericValue(value);
              if (numericValue <= 0) {
                return 'Salário deve ser maior que zero';
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Dependents
          TextFormField(
            controller: _dependentsController,
            decoration: const InputDecoration(
              labelText: 'Número de Dependentes',
              border: OutlineInputBorder(),
              helperText: 'Para cálculo do IRRF',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final dependents = int.tryParse(value) ?? 0;
                if (dependents < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Transportation Voucher
          TextFormField(
            controller: _transportationVoucherController,
            decoration: const InputDecoration(
              labelText: 'Vale Transporte (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Máximo 6% do salário bruto',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final voucherValue = _parseNumericValue(value);
                if (voucherValue < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Health Insurance
          TextFormField(
            controller: _healthInsuranceController,
            decoration: const InputDecoration(
              labelText: 'Plano de Saúde (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Valor descontado do salário',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final healthValue = _parseNumericValue(value);
                if (healthValue < 0) {
                  return 'Valor não pode ser negativo';
                }
              }
              return null;
            },
            onSaved: (_) => _submitForm(),
          ),
          const SizedBox(height: 16),

          // Other Discounts
          TextFormField(
            controller: _otherDiscountsController,
            decoration: const InputDecoration(
              labelText: 'Outros Descontos (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
              helperText: 'Empréstimos, adiantamentos, etc.',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_currencyFormatter],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final otherValue = _parseNumericValue(value);
                if (otherValue < 0) {
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

    final params = CalculateNetSalaryParams(
      grossSalary: _parseNumericValue(_grossSalaryController.text),
      dependents: int.tryParse(_dependentsController.text) ?? 0,
      transportationVoucher:
          _parseNumericValue(_transportationVoucherController.text),
      healthInsurance: _parseNumericValue(_healthInsuranceController.text),
      otherDiscounts: _parseNumericValue(_otherDiscountsController.text),
    );

    widget.onCalculate(params);
  }
}
