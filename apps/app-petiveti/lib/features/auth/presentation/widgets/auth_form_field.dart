import 'package:flutter/material.dart';

class AuthFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextCapitalization textCapitalization;

  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.helperText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }
}
