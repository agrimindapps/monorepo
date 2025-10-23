// STUB: Temporary stub to fix compilation errors
// TODO: Implement proper DecimalInputFormatter or use existing formatter

import 'package:flutter/services.dart';

/// TextInputFormatter for decimal number input
/// Allows digits, decimal point, and optionally negative sign
class DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final bool allowNegative;

  DecimalInputFormatter({
    this.decimalPlaces = 2,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Build regex pattern
    final String pattern = allowNegative
        ? r'^-?\d*\.?\d{0,' + decimalPlaces.toString() + r'}$'
        : r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$';

    final RegExp regExp = RegExp(pattern);

    // Check if new value matches pattern
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }

    // If doesn't match, keep old value
    return oldValue;
  }
}
