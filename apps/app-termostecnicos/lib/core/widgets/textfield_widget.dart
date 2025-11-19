import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class VTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final FocusNode focusNode;
  final TextEditingController txEditController;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final VoidCallback? onEditingComplete;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final bool showClearButton;

  VTextField({
    super.key,
    this.labelText,
    this.hintText,
    FocusNode? focusNode,
    required this.txEditController,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.textAlign = TextAlign.end,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.contentPadding,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.onEditingComplete,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.showClearButton = false,
  })  : focusNode = focusNode ?? FocusNode();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveKeyboardType = keyboardType ?? TextInputType.text;

    final defaultInputFormatters = effectiveKeyboardType ==
            const TextInputType.numberWithOptions(decimal: true)
        ? [FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))]
        : null;

    final effectiveFillColor = fillColor ??
        (isDark ? const Color(0xFF303030) : Colors.blueGrey.shade50);
    final effectiveHintStyle = hintStyle ??
        TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.blueGrey.shade800);
    final effectiveTextStyle = textStyle ??
        TextStyle(color: isDark ? Colors.grey.shade200 : Colors.black);
    final effectiveLabelStyle = labelStyle ??
        TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700);

    final defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF444444) : const Color(0x00000000),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(4.0),
    );

    final defaultFocusedBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF606060) : const Color(0xFF94A3B8),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(4.0),
    );

    Widget? effectiveSuffixIcon = suffixIcon;
    if (showClearButton && suffixIcon == null) {
      effectiveSuffixIcon = ValueListenableBuilder<TextEditingValue>(
        valueListenable: txEditController,
        builder: (context, value, child) {
          return value.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                  onPressed: () {
                    txEditController.clear();
                    if (onChanged != null) {
                      onChanged!('');
                    }
                  },
                )
              : const SizedBox.shrink();
        },
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
      child: TextFormField(
        controller: txEditController,
        textInputAction: TextInputAction.next,
        onEditingComplete:
            onEditingComplete ?? () => FocusScope.of(context).nextFocus(),
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        readOnly: readOnly,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: effectiveLabelStyle,
          hintText: hintText ?? '0',
          hintStyle: effectiveHintStyle,
          prefixIcon: prefixIcon,
          suffixIcon: effectiveSuffixIcon,
          contentPadding: contentPadding,
          enabledBorder: enabledBorder ?? defaultBorder,
          focusedBorder: focusedBorder ?? defaultFocusedBorder,
          errorBorder: errorBorder ?? defaultBorder,
          focusedErrorBorder: focusedErrorBorder ?? defaultBorder,
          filled: true,
          fillColor: effectiveFillColor,
          counterText: '', // Esconde o contador de caracteres
        ),
        style: effectiveTextStyle,
        textAlign: textAlign,
        keyboardType: effectiveKeyboardType,
        inputFormatters: inputFormatters ?? defaultInputFormatters,
        onChanged: onChanged,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}

class CurrencyPtBrInputFormatter extends TextInputFormatter {
  final bool withSymbol;
  final String symbol;

  CurrencyPtBrInputFormatter({
    this.withSymbol = true,
    this.symbol = 'R\$',
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove caracteres não numéricos
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newText.isEmpty) {
      return TextEditingValue(
        text: withSymbol ? '$symbol 0,00' : '0,00',
        selection:
            TextSelection.collapsed(offset: withSymbol ? symbol.length + 5 : 4),
      );
    }

    // Converte para double e formata
    double value = double.parse(newText) / 100;
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    newText = formatter.format(value);

    if (withSymbol) {
      newText = '$symbol $newText';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Permite apenas números e o separador decimal
    String newText = newValue.text.replaceAll(',', '.');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newText)) {
      return oldValue;
    }

    // Verifica se tem mais de um ponto decimal
    if (newText.split('.').length > 2) {
      return oldValue;
    }

    // Limita as casas decimais
    if (newText.contains('.')) {
      List<String> parts = newText.split('.');
      if (parts[1].length > decimalPlaces) {
        newText = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    }

    return newValue;
  }
}
