// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../core/style/shadcn_style.dart';

/// Um widget de campo de seleção (dropdown) genérico que pode ser usado com qualquer tipo de dados.
class DropdownFieldWidget<T> extends StatelessWidget {
  /// Label do campo
  final String label;

  /// Valor inicial selecionado
  final T? initialValue;

  /// Lista de itens disponíveis para seleção
  final List<T> items;

  /// Função para construir o label de cada item
  final String Function(T) itemLabelBuilder;

  /// Função para construir o widget de cada item (opcional)
  final Widget Function(T)? itemBuilder;

  /// Dica exibida quando nenhum item está selecionado
  final String? hint;

  /// Se o campo é obrigatório
  final bool isRequired;

  /// Callback chamado quando o valor muda
  final ValueChanged<T?>? onChanged;

  /// Callback chamado quando o campo é salvo (em um formulário)
  final ValueChanged<T?>? onSaved;

  /// Validador para o campo
  final FormFieldValidator<T>? validator;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    this.initialValue,
    required this.items,
    required this.itemLabelBuilder,
    this.itemBuilder,
    this.hint,
    this.isRequired = true,
    this.onChanged,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: ShadcnStyle.inputDecoration(
        label: label,
        hint: hint,
      ),
      value: initialValue,
      isExpanded: true,
      elevation: 2,
      icon: const Icon(Icons.arrow_drop_down),
      items: items.map((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: itemBuilder != null
              ? itemBuilder!(value)
              : Text(
                  itemLabelBuilder(value),
                  style: ShadcnStyle.inputStyle,
                ),
        );
      }).toList(),
      validator: (value) {
        if (isRequired && value == null) {
          return 'Este campo é obrigatório';
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
