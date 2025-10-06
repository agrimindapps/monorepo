import 'package:flutter/material.dart';

class SearchTextFieldWidget extends StatelessWidget {
  const SearchTextFieldWidget({
    super.key,
    this.labelText,
    required this.txEditController,
  });

  final String? labelText;
  final TextEditingController txEditController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: txEditController,
        autofocus: false,
        obscureText: false,
        decoration: InputDecoration(
            fillColor: Colors.white60,
            hintText: 'Pesquisar...',
            filled: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.fromLTRB(5, 3, 0, 0),
              child: Icon(
                Icons.search,
                size: 18,
              ),
            ),
            suffixIcon: InkWell(
              onTap: () async => txEditController.clear(),
              child: const Icon(
                Icons.clear,
                color: Color(0xFF757575),
                size: 18,
              ),
            )),
        style: const TextStyle(color: Colors.black, height: 1),
      ),
    );
  }
}
