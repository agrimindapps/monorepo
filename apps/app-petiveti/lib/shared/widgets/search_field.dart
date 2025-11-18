import 'package:flutter/material.dart';

/// Reusable search field component
///
/// **SRP**: Única responsabilidade de campo de busca
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String) onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        suffixIcon: controller.text.isNotEmpty && onClear != null
            ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
            : null,
      ),
      onChanged: onChanged,
    );
  }
}
