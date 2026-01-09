import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Brazilian currency input formatter
/// 
/// Allows typing numbers directly and formats as Brazilian currency (R$)
/// Example: typing "150050" becomes "R$ 1.500,50"
/// 
/// More intuitive than mask-based formatters - just type numbers!
class BrazilianCurrencyFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only digits
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Empty input
    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse as cents (last 2 digits)
    final value = int.parse(newText);
    final doubleValue = value / 100.0;

    // Format with Brazilian locale
    final formatted = _formatter.format(doubleValue).trim();

    // Return with cursor at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Parse formatted string to double value
  static double parse(String text) {
    if (text.isEmpty) {
      return 0.0;
    }

    // Remove all non-digits except comma
    final cleaned = text.replaceAll(RegExp(r'[^\d,]'), '');

    // Replace comma with dot for parsing
    final withDot = cleaned.replaceAll(',', '.');

    return double.tryParse(withDot) ?? 0.0;
  }

  /// Format a double value to Brazilian currency string (without R$ symbol)
  static String format(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value).trim();
  }
}
