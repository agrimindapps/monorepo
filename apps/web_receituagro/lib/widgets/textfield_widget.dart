import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class VTextField extends StatelessWidget {
  const VTextField({this.labelText = '', required this.focusNode, required this.txEditController, super.key});

  final String? labelText;
  final FocusNode focusNode;
  final TextEditingController txEditController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
      child: TextFormField(
          controller: txEditController,
          focusNode: focusNode,
          autofocus: false,
          obscureText: false,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: '0',
            hintStyle: TextStyle(color: Colors.blueGrey.shade800),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0x00000000),
                width: 1,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(4.0),
              ),
            ),
            filled: true,
            fillColor: Colors.blueGrey.shade50,
          ),
          style: const TextStyle(color: Colors.black),
          textAlign: TextAlign.end,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
          ]),
    );
  }
}

class CurrencyPtBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);
    final formatter = NumberFormat("#,##0.00", "pt_BR");
    String newText = "R\$ ${formatter.format(value / 100)}";

    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}
