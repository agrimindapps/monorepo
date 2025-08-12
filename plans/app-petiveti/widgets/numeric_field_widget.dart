// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Widget para entrada de valores numéricos com formatação automática.
class NumericFieldWidget extends StatelessWidget {
  /// Label do campo
  final String label;

  /// Texto de ajuda (hint)
  final String? hint;

  /// Valor inicial
  final double? initialValue;

  /// Texto do prefixo (ex: "$", "R$")
  final String? prefix;

  /// Texto do sufixo (ex: "kg", "m²")
  final String? suffix;

  /// Número de casas decimais
  final int decimalPlaces;

  /// Valor máximo permitido
  final double? maxValue;

  /// Valor mínimo permitido
  final double? minValue;

  /// Se o campo é obrigatório
  final bool isRequired;

  /// Alinhamento do texto
  final TextAlign textAlign;

  /// Callback chamado quando o valor muda
  final ValueChanged<double>? onChanged;

  /// Callback chamado quando o campo é salvo (em um formulário)
  final ValueChanged<double>? onSaved;

  /// Validador personalizado
  final FormFieldValidator<double>? validator;

  const NumericFieldWidget({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.prefix,
    this.suffix,
    this.decimalPlaces = 2,
    this.maxValue,
    this.minValue,
    this.isRequired = true,
    this.textAlign = TextAlign.right,
    this.onChanged,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final initialValueText = initialValue != null
        ? initialValue.toString().replaceAll('.', ',')
        : '';

    return TextFormField(
      initialValue: initialValueText,
      textAlign: textAlign,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: ShadcnStyle.inputStyle,
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        hint: hint,
        prefix: prefix,
        suffix: suffix,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d+[\,\.]?\d{0,' + decimalPlaces.toString() + '}'))
      ],
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo obrigatório';
        }

        if (value != null && value.isNotEmpty) {
          final numberValue = double.tryParse(value.replaceAll(',', '.'));

          if (numberValue == null) {
            return 'Valor inválido';
          }

          if (maxValue != null && numberValue > maxValue!) {
            return 'Valor máximo: ${maxValue!.toStringAsFixed(decimalPlaces).replaceAll('.', ',')}';
          }

          if (minValue != null && numberValue < minValue!) {
            return 'Valor mínimo: ${minValue!.toStringAsFixed(decimalPlaces).replaceAll('.', ',')}';
          }

          if (validator != null) {
            return validator!(numberValue);
          }
        }

        return null;
      },
      onChanged: (value) {
        if (value.isNotEmpty && onChanged != null) {
          final double? numberValue =
              double.tryParse(value.replaceAll(',', '.'));
          if (numberValue != null) {
            onChanged!(numberValue);
          }
        }
      },
      onSaved: (value) {
        if (value != null && value.isNotEmpty && onSaved != null) {
          final double numberValue =
              double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
          onSaved!(numberValue);
        }
      },
    );
  }
}
