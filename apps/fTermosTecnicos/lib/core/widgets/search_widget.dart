import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchTextFieldWidget extends StatelessWidget {
  const SearchTextFieldWidget({
    super.key,
    this.labelText,
    this.hintText = 'Pesquisar...',
    required this.controller,
  });

  final String? labelText;
  final String? hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GetPlatform.isWeb ? 60 : 40,
      child: TextFormField(
        controller: controller,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
          fillColor: Colors.white60,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade300),
          filled: true,
          prefixIcon: const Padding(
            padding: EdgeInsets.fromLTRB(5, 3, 0, 0),
            child: Icon(
              Icons.search,
              size: 20,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? InkWell(
                  onTap: () async => controller.clear(),
                  child: const Icon(
                    Icons.clear,
                    color: Color(0xFF757575),
                    size: 20,
                  ),
                )
              : null,
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
