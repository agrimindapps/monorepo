// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Widget para campos de observações ou comentários.
/// Oferece um campo de texto multilinhas com limite de caracteres opcional.
class ObservationFieldWidget extends StatelessWidget {
  /// Texto inicial do campo
  final String? initialValue;

  /// Label do campo
  final String label;

  /// Texto de ajuda (hint)
  final String hint;

  /// Número máximo de caracteres permitidos
  final int maxLength;

  /// Número máximo de linhas visíveis
  final int maxLines;

  /// Capitalização do texto
  final TextCapitalization textCapitalization;

  /// Ação de teclado ao concluir
  final TextInputAction textInputAction;

  /// Callback chamado quando o valor muda
  final ValueChanged<String>? onChanged;

  /// Callback chamado quando o campo é salvo (em um formulário)
  final ValueChanged<String?>? onSaved;

  /// Validador para o campo
  final FormFieldValidator<String>? validator;

  const ObservationFieldWidget({
    super.key,
    this.initialValue,
    required this.label,
    this.hint = 'Digite observações adicionais',
    this.maxLength = 255,
    this.maxLines = 3,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSaved,
    this.validator,
    required bool isRequired,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: ShadcnStyle.inputStyle,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        hint: hint,
        showCounter: true,
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }
}
