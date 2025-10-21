// Flutter imports:
import 'package:flutter/services.dart';

class PercentInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '0,00');
    }

    // Limpa o texto para manter apenas dígitos e vírgula/ponto
    String text = newValue.text.replaceAll(RegExp(r'[^\d,.]'), '');

    // Substitui pontos por vírgulas
    text = text.replaceAll('.', ',');

    // Garante que há apenas uma vírgula
    final parts = text.split(',');
    if (parts.length > 2) {
      text = '${parts[0]},${parts.sublist(1).join('')}';
    }

    // Limita os decimais a 2
    if (parts.length == 2 && parts[1].length > 2) {
      text = '${parts[0]},${parts[1].substring(0, 2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
