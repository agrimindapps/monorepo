/// Formatador otimizado para entrada de valores monetários
///
/// Implementa formatação em tempo real com otimizações de performance
/// e reutilização de formatters para evitar memory leaks.
library;

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'formatting_service.dart';

class MoneyInputFormatter extends TextInputFormatter {
  // Instância singleton do serviço de formatação
  final FormattingService _formattingService = FormattingService();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove todos os caracteres não numéricos
    String value = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Converte entrada numérica para valor real
    double number = _formattingService.centavosToReal(value);

    // Formata o número usando o serviço
    String formatted = _formattingService.formatCurrency(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Extrai valor numérico de string formatada
  double getUnmaskedDouble(String value) {
    return _formattingService.parseUnmaskedDouble(value);
  }
}
