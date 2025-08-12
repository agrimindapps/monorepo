// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';

/// Widget reutilizável para campos de texto nos formulários,
/// com suporte a validação, limite de caracteres e formatadores.
class TextFieldWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final String initialValue;
  final bool isRequired;
  final int? maxLength;
  final int? maxLines;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSaved;
  final bool showCounter;
  final bool showClearButton;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.hint,
    this.initialValue = '',
    this.isRequired = true,
    this.maxLength,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.showCounter = false,
    this.showClearButton = true,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late TextEditingController _controller;
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      decoration: ShadcnStyle.inputDecoration(
        label: widget.label,
        hint: widget.hint,
        showCounter: widget.showCounter,
        suffixIcon: widget.showClearButton && _value.isNotEmpty
            ? IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _value = '';
                    _controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if ((value?.isEmpty ?? true) && widget.isRequired) {
          return 'Campo obrigatório';
        }

        if (widget.validator != null) {
          return widget.validator!(value);
        }

        return null;
      },
      onSaved: (value) {
        if (widget.onSaved != null) {
          widget.onSaved!(value?.trim() ?? '');
        }
      },
      onChanged: (value) {
        setState(() => _value = value);
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}
