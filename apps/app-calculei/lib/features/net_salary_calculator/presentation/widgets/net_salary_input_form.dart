// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
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
    const accentColor = CalculatorAccentColors.labor;
    
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gross Salary & Dependents
          ResponsiveInputRow(
            left: _DarkCurrencyField(
              controller: _grossSalaryController,
              label: 'Salário Bruto Mensal',
              helperText: 'Informe o salário bruto',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
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
            right: _DarkNumberField(
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
            left: _DarkCurrencyField(
              controller: _transportationVoucherController,
              label: 'Vale Transporte (opcional)',
              helperText: 'Máximo 6% do salário bruto',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final voucherValue = _parseNumericValue(value);
                  if (voucherValue < 0) {
                    return 'Não pode ser negativo';
                  }
                }
                return null;
              },
            ),
            right: _DarkCurrencyField(
              controller: _healthInsuranceController,
              label: 'Plano de Saúde (opcional)',
              helperText: 'Valor descontado do salário',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
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
          _DarkCurrencyField(
            controller: _otherDiscountsController,
            label: 'Outros Descontos (opcional)',
            helperText: 'Empréstimos, adiantamentos, etc.',
            accentColor: accentColor,
            formatter: _currencyFormatter,
            validator: (value) {
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

/// Dark themed currency input field
class _DarkCurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final MaskTextInputFormatter formatter;
  final String? Function(String?)? validator;

  const _DarkCurrencyField({
    required this.controller,
    required this.label,
    required this.accentColor,
    required this.formatter,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [formatter],
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            prefixStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dark themed number input field
class _DarkNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;

  const _DarkNumberField({
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: validator,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
