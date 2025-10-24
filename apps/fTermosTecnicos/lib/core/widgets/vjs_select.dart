// ignore_for_file: public_member_api_docs, sort_constructors_first, camel_case_types, must_be_immutable
import 'package:flutter/material.dart';

class vjsSelect extends StatefulWidget {
  vjsSelect({
    super.key,
    required this.label,
    required this.fieldDescription,
    required this.items,
    required this.itemSelected,
    required this.onChanged,
  });

  String label;
  String fieldDescription;
  List<Map<String, dynamic>>? items;
  Map<String, dynamic>? itemSelected;
  Function? onChanged;

  @override
  State<vjsSelect> createState() => _vjsSelectState();
}

class _vjsSelectState extends State<vjsSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.items = null;
    widget.itemSelected = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
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
        child: DropdownButton<Map<String, dynamic>>(
            elevation: 0,
            isExpanded: true,
            isDense: true,
            underline: Container(
              height: 0,
              color: Colors.blueGrey.shade800,
            ),
            borderRadius: BorderRadius.circular(4),
            value: widget.itemSelected,
            items: widget.items?.map((Map<String, dynamic> item) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(item['text']),
              );
            }).toList(),
            onChanged: (Map<String, dynamic>? value) {
              setState(() {
                widget.itemSelected = value;
                widget.onChanged!(value);
              });
            }),
      ),
    );
  }
}
