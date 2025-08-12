// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../core/style/shadcn_style.dart';

/// Widget reutilizável para campos de formulário com valores numéricos,
/// suportando diferentes formatos (decimal, moeda, etc.)
class NumericFieldWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final double initialValue;
  final int decimalPlaces;
  final bool isCurrency;
  final bool isRequired;
  final double? minValue;
  final double? maxValue;
  final String? Function(double?)? validator;
  final void Function(double)? onChanged;
  final void Function(double)? onSaved;
  final bool allowNegative;
  final TextAlign textAlign;
  final bool enabled;
  final String? helperText;
  final Color? textColor;

  const NumericFieldWidget({
    super.key,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.initialValue = 0.0,
    this.decimalPlaces = 2,
    this.isCurrency = false,
    this.isRequired = true,
    this.minValue,
    this.maxValue,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.allowNegative = false,
    this.textAlign = TextAlign.right,
    this.enabled = true,
    this.helperText,
    this.textColor,
  });

  @override
  State<NumericFieldWidget> createState() => _NumericFieldWidgetState();
}

class _NumericFieldWidgetState extends State<NumericFieldWidget> {
  late double _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController();
    _setControllerValue();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setControllerValue() {
    if (_value <= 0) {
      _controller.text = '';
      return;
    }

    if (widget.isCurrency) {
      _controller.text =
          _value.toStringAsFixed(widget.decimalPlaces).replaceAll('.', ',');
    } else {
      _controller.text =
          _value.toStringAsFixed(widget.decimalPlaces).replaceAll('.', ',');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      textAlign: widget.textAlign,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: widget.allowNegative,
      ),
      decoration: ShadcnStyle.inputDecoration(
        label: widget.label,
        hint: widget.hint,
        prefix: widget.prefix,
        suffix: widget.suffix,
        helperText: widget.helperText,
        suffixIcon: _value > 0
            ? IconButton(
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _value = 0.0;
                    _controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!(0.0);
                    }
                  });
                },
              )
            : null,
      ),
      inputFormatters: [
        // Allow digits, comma, dot and negative sign if enabled
        FilteringTextInputFormatter.allow(
            widget.allowNegative ? RegExp(r'[0-9,.\-]') : RegExp(r'[0-9,.]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          // Replace dots with commas for consistent formatting
          var text = newValue.text.replaceAll('.', ',');

          // Handle decimal places limit
          if (text.contains(',')) {
            final parts = text.split(',');
            if (parts.length == 2 && parts[1].length > widget.decimalPlaces) {
              text =
                  '${parts[0]},${parts[1].substring(0, widget.decimalPlaces)}';
            }
          }

          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }),
      ],
      validator: (value) {
        if ((value?.isEmpty ?? true) && widget.isRequired) {
          return 'Campo obrigatório';
        }

        if (value?.isNotEmpty ?? false) {
          final cleanValue = value!.replaceAll(',', '.');
          final number = double.tryParse(cleanValue);

          if (number == null) {
            return 'Valor inválido';
          }

          if (widget.minValue != null && number < widget.minValue!) {
            return 'O valor mínimo é ${widget.minValue}';
          }

          if (widget.maxValue != null && number > widget.maxValue!) {
            return 'O valor máximo é ${widget.maxValue}';
          }

          if (widget.validator != null) {
            return widget.validator!(number);
          }
        }

        return null;
      },
      onSaved: (value) {
        if (value?.isNotEmpty ?? false) {
          final cleanValue = value!.replaceAll(',', '.');
          final number = double.parse(cleanValue);
          if (widget.onSaved != null) {
            widget.onSaved!(number);
          }
        } else if (widget.onSaved != null) {
          widget.onSaved!(0.0);
        }
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          final cleanValue = value.replaceAll(',', '.');
          final number = double.tryParse(cleanValue);
          if (number != null) {
            setState(() => _value = number);
            if (widget.onChanged != null) {
              widget.onChanged!(number);
            }
          }
        } else {
          setState(() => _value = 0.0);
          if (widget.onChanged != null) {
            widget.onChanged!(0.0);
          }
        }
      },
      enabled: widget.enabled,
      style: TextStyle(color: widget.textColor),
    );
  }
}
