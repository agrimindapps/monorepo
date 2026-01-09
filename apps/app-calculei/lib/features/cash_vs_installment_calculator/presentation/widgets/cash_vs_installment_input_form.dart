// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
import '../../../../core/widgets/accent_input_fields.dart';
import '../../../../core/widgets/calculator_page_layout.dart';
import '../../../../shared/widgets/responsive_input_row.dart';
import '../../domain/usecases/calculate_cash_vs_installment_usecase.dart';

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
      CashVsInstallmentInputFormState();
}

class CashVsInstallmentInputFormState
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

  @override
  void dispose() {
    _cashPriceController.dispose();
    _installmentPriceController.dispose();
    _numberOfInstallmentsController.dispose();
    _monthlyInterestRateController.dispose();
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
            right: AccentCurrencyField(
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
            left: AccentNumberField(
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
            right: AccentPercentageField(
              controller: _monthlyInterestRateController,
              label: 'Taxa de Juros Mensal',
              helperText: 'Taxa que você consegue aplicando (ex: 0,8%)',
              accentColor: accentColor,
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
