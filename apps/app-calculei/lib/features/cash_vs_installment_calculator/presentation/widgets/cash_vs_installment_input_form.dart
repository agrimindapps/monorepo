// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../domain/usecases/calculate_cash_vs_installment_usecase.dart';
import '../../../../shared/widgets/responsive_input_row.dart';

/// Input form for cash vs installment calculation
class CashVsInstallmentInputForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(CalculateCashVsInstallmentParams) onCalculate;

  const CashVsInstallmentInputForm({
    super.key,
    required this.formKey,
    required this.onCalculate,
  });

  @override
  State<CashVsInstallmentInputForm> createState() =>
      _CashVsInstallmentInputFormState();
}

class _CashVsInstallmentInputFormState
    extends State<CashVsInstallmentInputForm> {
  // Controllers
  final _cashPriceController = TextEditingController();
  final _installmentPriceController = TextEditingController();
  final _numberOfInstallmentsController = TextEditingController(text: '12');
  final _monthlyInterestRateController = TextEditingController(text: '0,8');

  // Formatters
  final _currencyFormatter = MaskTextInputFormatter(
    mask: '###.###.###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _percentageFormatter = MaskTextInputFormatter(
    mask: '##,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _cashPriceController.dispose();
    _installmentPriceController.dispose();
    _numberOfInstallmentsController.dispose();
    _monthlyInterestRateController.dispose();
    super.dispose();
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
            left: _DarkCurrencyField(
              controller: _cashPriceController,
              label: 'Valor à Vista',
              helperText: 'Preço para pagamento à vista',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o valor à vista';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Valor deve ser maior que zero';
                }
                return null;
              },
            ),
            right: _DarkCurrencyField(
              controller: _installmentPriceController,
              label: 'Valor da Parcela',
              helperText: 'Valor de cada parcela',
              accentColor: accentColor,
              formatter: _currencyFormatter,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o valor da parcela';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue <= 0) {
                  return 'Valor deve ser maior que zero';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: _DarkNumberField(
              controller: _numberOfInstallmentsController,
              label: 'Número de Parcelas',
              helperText: 'Quantidade de parcelas',
              accentColor: accentColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe o número de parcelas';
                }
                final installments = int.tryParse(value) ?? 0;
                if (installments <= 0) {
                  return 'Parcelas devem ser maior que zero';
                }
                if (installments > 360) {
                  return 'Máximo 360 parcelas';
                }
                return null;
              },
            ),
            right: _DarkPercentageField(
              controller: _monthlyInterestRateController,
              label: 'Taxa de Juros Mensal',
              helperText: 'Taxa que você consegue aplicando (ex: 0,8%)',
              accentColor: accentColor,
              formatter: _percentageFormatter,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe a taxa de juros';
                }
                final numericValue = _parseNumericValue(value);
                if (numericValue < 0) {
                  return 'Taxa não pode ser negativa';
                }
                if (numericValue > 20) {
                  return 'Taxa muito alta (máx: 20%)';
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

  /// Public method to trigger calculation from parent widget
  void calculate() {
    _submitForm();
  }

  void _submitForm() {
    // Validation has already been done by the parent widget
    // Just extract and submit the parameters
    final params = CalculateCashVsInstallmentParams(
      cashPrice: _parseNumericValue(_cashPriceController.text),
      installmentPrice: _parseNumericValue(_installmentPriceController.text),
      numberOfInstallments:
          int.tryParse(_numberOfInstallmentsController.text) ?? 12,
      monthlyInterestRate: _parseNumericValue(
        _monthlyInterestRateController.text,
      ),
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

/// Dark themed percentage input field
class _DarkPercentageField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final MaskTextInputFormatter formatter;
  final String? Function(String?)? validator;

  const _DarkPercentageField({
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
            suffixText: '%',
            suffixStyle: TextStyle(
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
