// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../config/despesa_config.dart';
import '../../controllers/despesa_form_controller.dart';
import '../../utils/despesa_form_utils.dart';
import '../styles/despesa_form_styles.dart';

class ValorInput extends StatelessWidget {
  final DespesaFormController controller;

  const ValorInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valor *',
          style: DespesaFormStyles.labelStyle,
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasError = controller.formState.value.getFieldError('valor') != null;
          final currentValue = controller.formModel.value.valor;

          return TextFormField(
            initialValue: currentValue > 0 
                ? DespesaFormUtils.formatValor(currentValue)
                : '',
            decoration: DespesaFormStyles.getInputDecoration(
              labelText: DespesaConfig.placeholderValor,
              hintText: 'Digite o valor da despesa',
              prefixIcon: const Icon(Icons.attach_money),
              hasError: hasError,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              _CurrencyInputFormatter(),
            ],
            onChanged: (String value) {
              final parsedValue = DespesaFormUtils.parseValor(value);
              controller.updateValor(parsedValue);
            },
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Valor é obrigatório';
              }
              
              final parsedValue = DespesaFormUtils.parseValor(value);
              if (parsedValue <= 0) {
                return 'Valor deve ser maior que zero';
              }
              
              if (!DespesaFormUtils.isValidValue(value)) {
                return 'Valor inválido';
              }
              
              return null;
            },
            style: DespesaFormStyles.inputStyle,
            textAlign: TextAlign.end,
          );
        }),
        
        Obx(() {
          final error = controller.formState.value.getFieldError('valor');
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: DespesaFormStyles.errorStyle,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        
        const SizedBox(height: 8),
        
        Obx(() {
          final currentValue = controller.formModel.value.valor;
          if (currentValue > 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DespesaFormStyles.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: DespesaFormStyles.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'Valor: ${DespesaFormUtils.formatValorComMoeda(currentValue)}',
                style: const TextStyle(
                  color: DespesaFormStyles.successColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    
    // Remove tudo exceto dígitos
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    
    // Converte para double (centavos)
    double value = double.parse(newText) / 100;
    
    // Limita o valor máximo
    if (value > 999999.99) {
      value = 999999.99;
    }
    
    // Formata como moeda brasileira
    String formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
