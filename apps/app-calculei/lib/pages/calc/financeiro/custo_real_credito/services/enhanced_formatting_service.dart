// Flutter imports:
import 'package:flutter/services.dart';

/// Serviço responsável por formatação de campos monetários e percentuais
///
/// Inclui formatters otimizados e suporte a diferentes tipos de números
class FormattingService {
  static final FormattingService _instance = FormattingService._internal();
  factory FormattingService() => _instance;
  FormattingService._internal();

  /// Formata um número como porcentagem com duas casas decimais
  String formatPercentage(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Converte string com formato de porcentagem para double
  double parsePercentage(String value) {
    return double.parse(value.replaceAll(',', '.'));
  }

  /// Formatter para percentuais com duas casas decimais
  TextInputFormatter get percentageFormatter {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d*[,]?\d{0,2}$'));
  }

  /// Formata um número como moeda brasileira
  String formatCurrency(double value) {
    final valorFormatado = value.toStringAsFixed(2);
    final partes = valorFormatado.split('.');
    String partesInteiras = partes[0];
    final centavos = partes[1];

    // Adiciona pontos a cada 3 dígitos
    final caracteres = partesInteiras.split('').reversed.toList();
    final parteInteiraFormatada = [];
    for (var i = 0; i < caracteres.length; i++) {
      if (i > 0 && i % 3 == 0) {
        parteInteiraFormatada.add('.');
      }
      parteInteiraFormatada.add(caracteres[i]);
    }

    partesInteiras = parteInteiraFormatada.reversed.join('');
    return 'R\$ $partesInteiras,$centavos';
  }
}
