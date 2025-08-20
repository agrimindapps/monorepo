// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../controllers/consulta_form_controller.dart';
import '../styles/consulta_form_styles.dart';

class ValorInput extends StatelessWidget {
  final ConsultaFormController controller;

  const ValorInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasError = controller.getFieldError('valor') != null;
      final errorMessage = controller.getFieldError('valor');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: controller.model.valor > 0
                ? controller.model.valor.toStringAsFixed(2).replaceAll('.', ',')
                : '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'Valor da Consulta',
              hintText: 'R\$ 0,00',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                borderSide: BorderSide(
                  color: hasError
                      ? ConsultaFormStyles.errorColor
                      : ConsultaFormStyles.dividerColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                borderSide: BorderSide(
                  color: hasError
                      ? ConsultaFormStyles.errorColor
                      : ConsultaFormStyles.dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                borderSide: BorderSide(
                  color: hasError
                      ? ConsultaFormStyles.errorColor
                      : ConsultaFormStyles.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                borderSide: const BorderSide(
                  color: ConsultaFormStyles.errorColor,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(ConsultaFormStyles.borderRadius),
                borderSide: const BorderSide(
                  color: ConsultaFormStyles.errorColor,
                  width: 2,
                ),
              ),
              errorText: hasError ? errorMessage : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,2}')),
              _CurrencyInputFormatter(),
            ],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Valor é obrigatório';
              }

              final parsedValue = _parseValue(value!);

              if (parsedValue < 0) {
                return 'Valor não pode ser negativo';
              }

              if (parsedValue > 999999.99) {
                return 'Valor muito alto (máx. R\$ 999.999,99)';
              }

              return null;
            },
            onChanged: (value) {
              final parsedValue = _parseValue(value);
              controller.updateValor(parsedValue);
              controller.validateField('valor', parsedValue);
            },
            onSaved: (value) {
              if (value?.isNotEmpty ?? false) {
                final parsedValue = _parseValue(value!);
                controller.updateValor(parsedValue);
              }
            },
          ),
          if (hasError && errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: const TextStyle(
                color: ConsultaFormStyles.errorColor,
                fontSize: 12,
              ),
            ),
          ],
        ],
      );
    });
  }

  double _parseValue(String value) {
    // Remove R$ and spaces, replace comma with dot
    final normalized = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(normalized) ?? 0.0;
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove any non-digit characters except comma and dot
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9,.]'), '');

    // Ensure only one decimal separator
    final parts = filtered.split(RegExp(r'[,.]'));
    if (parts.length > 2) {
      return oldValue;
    }

    if (parts.length == 2) {
      // Limit decimal places to 2
      if (parts[1].length > 2) {
        parts[1] = parts[1].substring(0, 2);
      }
      final formatted = '${parts[0]},${parts[1]}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
