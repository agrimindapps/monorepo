// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:intl/intl.dart';

class ValorFuturoUtils {
  static double calcularValorFuturo(
    double valorPresente,
    double taxa,
    int periodo,
    bool ehAnual,
  ) {
    final taxaDecimal = taxa / 100;
    if (ehAnual) {
      return valorPresente * math.pow(1 + taxaDecimal, periodo);
    } else {
      return valorPresente * math.pow(1 + taxaDecimal, periodo);
    }
  }

  static double calcularValorPresente(
    double valorFuturo,
    double taxa,
    int periodo,
    bool ehAnual,
  ) {
    final taxaDecimal = taxa / 100;
    if (ehAnual) {
      return valorFuturo / math.pow(1 + taxaDecimal, periodo);
    } else {
      return valorFuturo / math.pow(1 + taxaDecimal, periodo);
    }
  }

  static double calcularAjusteInflacao(
    double valorInicial,
    double taxa,
    int periodo,
    bool ehAnual,
  ) {
    final taxaDecimal = taxa / 100;
    if (ehAnual) {
      return valorInicial / math.pow(1 + taxaDecimal, periodo);
    } else {
      return valorInicial / math.pow(1 + taxaDecimal, periodo);
    }
  }

  static String formatarMoeda(double valor) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(valor);
  }
}
