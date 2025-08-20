// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Widget para campos de texto simples com configurações personalizáveis.
class TextFieldWidget extends StatelessWidget {
  /// Label do campo
  final String label;

  /// Texto de ajuda (hint)
  final String? hint;

  /// Valor inicial
  final String? initialValue;

  /// Texto do prefixo
  final String? prefix;

  /// Texto do sufixo
  final String? suffix;

  /// Ícone do prefixo
  final Widget? prefixIcon;

  /// Ícone do sufixo
  final Widget? suffixIcon;

  /// Número máximo de caracteres
  final int? maxLength;

  /// Número máximo de linhas
  final int? maxLines;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Capitalização de texto
  final TextCapitalization textCapitalization;

  /// Se o campo é obrigatório
  final bool isRequired;

  /// Formatadores de entrada
  final List<TextInputFormatter>? inputFormatters;

  /// Esconde o texto (para senha)
  final bool obscureText;

  /// Callback chamado quando o valor muda
  final ValueChanged<String>? onChanged;

  /// Callback chamado quando o campo é salvo
  final ValueChanged<String?>? onSaved;

  /// Validador personalizado
  final FormFieldValidator<String>? validator;

  /// Se deve esconder o contador de caracteres
  final bool hideCounter;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.isRequired = true,
    this.inputFormatters,
    this.obscureText = false,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.hideCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: ShadcnStyle.inputStyle,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        hint: hint,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        showCounter: maxLength != null && !hideCounter,
      ),
      inputFormatters: inputFormatters,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Campo obrigatório';
        }
        if (validator != null) {
          return validator!(value);
        }
        return null;
      },
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }
}
