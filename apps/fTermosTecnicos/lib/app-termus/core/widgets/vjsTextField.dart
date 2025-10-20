// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: camel_case_types
class vjsTextField extends StatefulWidget {
  const vjsTextField({
    super.key,
    this.labelText,
    required this.focusNode,
    required this.txEditController,
    this.inputFormatters = const [],
    this.hintText = '',
  });

  final String? labelText;
  final FocusNode focusNode;
  final TextEditingController txEditController;
  final List<TextInputFormatter> inputFormatters;
  final String hintText;

  @override
  State<vjsTextField> createState() => _vjsFieldState();
}

// ignore: camel_case_types
class _vjsFieldState extends State<vjsTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: TextFormField(
        controller: widget.txEditController,
        textInputAction: TextInputAction.next,
        onEditingComplete: () => FocusScope.of(context).nextFocus(),
        focusNode: widget.focusNode,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.blueGrey.shade200),
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
        inputFormatters: widget.inputFormatters,
      ),
    );
  }
}

// class _CurrencyPtBrInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
//     if (newValue.selection.baseOffset == 0) {
//       return newValue;
//     }

//     double value = double.parse(newValue.text);
//     final formatter = NumberFormat("#,##0.00", "pt_BR");
//     String newText = "R\$ ${formatter.format(value / 100)}";

//     return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
//   }
// }
