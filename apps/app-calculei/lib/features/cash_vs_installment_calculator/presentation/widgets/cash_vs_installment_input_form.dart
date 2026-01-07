// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// Project imports:
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
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveInputRow(
            left: TextFormField(
              controller: _cashPriceController,
              decoration: const InputDecoration(
                labelText: 'Valor à Vista',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
                helperText: 'Preço para pagamento à vista',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_currencyFormatter],
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
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _installmentPriceController,
              decoration: const InputDecoration(
                labelText: 'Valor da Parcela',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
                helperText: 'Valor de cada parcela',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_currencyFormatter],
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
              onSaved: (_) => _submitForm(),
            ),
          ),
          const SizedBox(height: 16),

          ResponsiveInputRow(
            left: TextFormField(
              controller: _numberOfInstallmentsController,
              decoration: const InputDecoration(
                labelText: 'Número de Parcelas',
                border: OutlineInputBorder(),
                helperText: 'Quantidade de parcelas',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onSaved: (_) => _submitForm(),
            ),
            right: TextFormField(
              controller: _monthlyInterestRateController,
              decoration: const InputDecoration(
                labelText: 'Taxa de Juros Mensal',
                suffixText: '%',
                border: OutlineInputBorder(),
                helperText: 'Taxa que você consegue aplicando (ex: 0,8%)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [_percentageFormatter],
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
              onSaved: (_) => _submitForm(),
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
