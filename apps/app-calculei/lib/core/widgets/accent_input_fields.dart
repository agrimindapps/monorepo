import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/brazilian_currency_formatter.dart';

/// Theme-aware currency input field with accent color
/// 
/// Adapts automatically to light/dark theme while maintaining
/// the calculator's accent color for focused state.
/// 
/// Uses intuitive number-only input - just type digits!
class AccentCurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;

  const AccentCurrencyField({
    super.key,
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _InputColors.fromBrightness(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: colors.helperColor,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [BrazilianCurrencyFormatter()],
          validator: validator,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: 'R\$ ',
            prefixStyle: TextStyle(
              color: colors.prefixColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: colors.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Theme-aware number input field with accent color
class AccentNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;

  const AccentNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _InputColors.fromBrightness(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: colors.helperColor,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: validator,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Theme-aware percentage input field with accent color
class AccentPercentageField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;

  const AccentPercentageField({
    super.key,
    required this.controller,
    required this.label,
    required this.accentColor,
    this.helperText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _InputColors.fromBrightness(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: colors.helperColor,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}')),
          ],
          validator: validator,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            suffixText: '%',
            suffixStyle: TextStyle(
              color: colors.prefixColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: colors.fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

/// Internal color configuration for input fields
class _InputColors {
  final Color textColor;
  final Color labelColor;
  final Color helperColor;
  final Color prefixColor;
  final Color fillColor;
  final Color borderColor;

  const _InputColors._({
    required this.textColor,
    required this.labelColor,
    required this.helperColor,
    required this.prefixColor,
    required this.fillColor,
    required this.borderColor,
  });

  factory _InputColors.fromBrightness(bool isDark) {
    if (isDark) {
      return _InputColors._(
        textColor: Colors.white,
        labelColor: Colors.white.withValues(alpha: 0.7),
        helperColor: Colors.white.withValues(alpha: 0.5),
        prefixColor: Colors.white.withValues(alpha: 0.5),
        fillColor: Colors.white.withValues(alpha: 0.08),
        borderColor: Colors.white.withValues(alpha: 0.1),
      );
    } else {
      return _InputColors._(
        textColor: Colors.grey[900]!,
        labelColor: Colors.grey[700]!,
        helperColor: Colors.grey[600]!,
        prefixColor: Colors.grey[600]!,
        fillColor: Colors.grey[100]!,
        borderColor: Colors.grey[300]!,
      );
    }
  }
}

/// Theme-aware date input field with accent color
/// 
/// Displays a date picker and formats the selected date.
/// Adapts to light/dark theme while maintaining accent color.
class AccentDateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final Color accentColor;
  final String? Function(String?)? validator;
  final void Function(DateTime) onDateSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AccentDateField({
    super.key,
    required this.controller,
    required this.label,
    required this.accentColor,
    required this.onDateSelected,
    this.helperText,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _InputColors.fromBrightness(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 2),
          Text(
            helperText!,
            style: TextStyle(
              color: colors.helperColor,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.borderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colors.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: colors.labelColor,
              size: 20,
            ),
          ),
          validator: validator,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: accentColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (date != null) {
              onDateSelected(date);
            }
          },
        ),
      ],
    );
  }
}
