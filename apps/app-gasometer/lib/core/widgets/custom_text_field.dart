import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto customizado com validação e formatação
class CustomTextField extends StatefulWidget {

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = true,
  });

  /// Factory constructor para campo de e-mail
  factory CustomTextField.email({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label ?? 'E-mail',
      hint: hint ?? 'Digite seu e-mail',
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }

  /// Factory constructor para campo de senha
  factory CustomTextField.password({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label ?? 'Senha',
      hint: hint ?? 'Digite sua senha',
      errorText: errorText,
      enabled: enabled,
      obscureText: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.lock_outlined),
    );
  }

  /// Factory constructor para campo numérico
  factory CustomTextField.number({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? errorText,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    String? prefixText,
    String? suffixText,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: inputFormatters ?? [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      validator: validator,
      onChanged: onChanged,
      prefixIcon: prefixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
    );
  }

  /// Factory constructor para campo de busca
  factory CustomTextField.search({
    Key? key,
    TextEditingController? controller,
    String? hint,
    bool enabled = true,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    VoidCallback? onClear,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      hint: hint ?? 'Buscar...',
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: onClear != null
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onClear,
            )
          : null,
    );
  }
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      textCapitalization: widget.textCapitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: _buildSuffixIcon(),
        prefix: widget.prefix,
        suffix: widget.suffix,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        contentPadding: widget.contentPadding ?? 
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: widget.border ?? _defaultBorder(context),
        enabledBorder: widget.enabledBorder ?? _defaultEnabledBorder(context),
        focusedBorder: widget.focusedBorder ?? _defaultFocusedBorder(context),
        errorBorder: widget.errorBorder ?? _defaultErrorBorder(context),
        fillColor: Colors.white,
        filled: widget.filled,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  InputBorder _defaultBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1,
      ),
    );
  }

  InputBorder _defaultEnabledBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }

  InputBorder _defaultFocusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      ),
    );
  }

  InputBorder _defaultErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    );
  }
}
