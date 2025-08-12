// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';

/// Widget reutilizável para campos dropdown nos formulários.
class DropdownFieldWidget<T> extends StatefulWidget {
  final String label;
  final String? hint;
  final T? initialValue;
  final List<T> items;
  final String Function(T)? itemLabelBuilder;
  final Widget Function(T)? itemBuilder;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final bool isRequired;
  final double? menuMaxHeight;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    required this.items,
    this.itemLabelBuilder,
    this.itemBuilder,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.isRequired = true,
    this.menuMaxHeight,
  });

  @override
  State<DropdownFieldWidget<T>> createState() => _DropdownFieldWidgetState<T>();
}

class _DropdownFieldWidgetState<T> extends State<DropdownFieldWidget<T>> {
  late T? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: ShadcnStyle.inputDecoration(
        label: widget.label,
        hint: widget.hint,
      ),
      value: _value,
      menuMaxHeight: widget.menuMaxHeight,
      dropdownColor: ShadcnStyle.backgroundColor,
      style: ShadcnStyle.inputStyle,
      items: widget.items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: widget.itemBuilder != null
              ? widget.itemBuilder!(item)
              : Text(widget.itemLabelBuilder != null
                  ? widget.itemLabelBuilder!(item)
                  : item.toString()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _value = value);
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      validator: (value) {
        if (value == null && widget.isRequired) {
          return 'Campo obrigatório';
        }

        if (widget.validator != null) {
          return widget.validator!(value);
        }

        return null;
      },
      onSaved: widget.onSaved,
      // Adiciona a cor dos ícones para respeitar o tema
      icon: Icon(Icons.arrow_drop_down, color: ShadcnStyle.textColor),
    );
  }
}
