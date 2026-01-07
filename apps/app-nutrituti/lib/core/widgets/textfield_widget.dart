// STUB: Temporary stub to fix compilation errors
// TODO: Implement proper VTextField or migrate to Flutter TextField

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VTextField extends StatelessWidget {
  // Old API (deprecated but kept for compatibility)
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;

  // New API (preferred)
  final String? labelText;
  final String? hintText;
  final TextEditingController? txEditController;

  // Common parameters
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String? initialValue;
  final TextStyle? style;
  final InputDecoration? decoration;
  final bool showClearButton;
  final VoidCallback? onEditingComplete;
  final TextAlign? textAlign;

  const VTextField({
    super.key,
    // Old API
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    // New API
    this.labelText,
    this.hintText,
    this.txEditController,
    // Common
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.onTap,
    this.initialValue,
    this.style,
    this.decoration,
    this.showClearButton = false,
    this.onEditingComplete,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // Merge old and new API
    final effectiveController = txEditController ?? controller;
    final effectiveLabel = labelText ?? label;
    final effectiveHint = hintText ?? hint;
    final effectivePrefixIcon = prefixIcon ?? prefix;
    final effectiveSuffixIcon = showClearButton && effectiveController != null && effectiveController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              effectiveController.clear();
              if (onChanged != null) {
                onChanged!('');
              }
            },
          )
        : (suffixIcon ?? suffix);

    return TextFormField(
      controller: effectiveController,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      textAlign: textAlign ?? TextAlign.start,
      style: style,
      decoration: decoration ??
          InputDecoration(
            labelText: effectiveLabel,
            hintText: effectiveHint,
            errorText: errorText,
            prefixIcon: effectivePrefixIcon,
            suffixIcon: effectiveSuffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          ),
    );
  }
}
