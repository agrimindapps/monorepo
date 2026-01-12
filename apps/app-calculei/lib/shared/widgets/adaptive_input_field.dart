import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de input adaptativo que responde ao tema claro/escuro
/// 
/// No tema escuro: Fundo escuro com texto branco
/// No tema claro: Fundo claro com texto escuro
class AdaptiveInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;

  const AdaptiveInputField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cores adaptativas
    final labelColor = isDark 
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.87);  // Aumentado de 0.7 para 0.87
    
    final textColor = isDark 
        ? Colors.white
        : Colors.black87;
    
    final suffixColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.6);  // Aumentado de 0.5 para 0.6
    
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.04);
    
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.2);  // Aumentado de 0.1 para 0.2
    
    final focusedBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: suffixColor,
              fontSize: 16,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
