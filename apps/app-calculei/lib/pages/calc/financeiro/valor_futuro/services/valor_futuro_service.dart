// Dart imports:
import 'dart:math' as math;

class ValorFuturoService {
  static double calcularValorFuturo(
      double valorInicial, double taxa, int periodo, bool ehAnual) {
    double taxaDecimal = taxa / 100;
    if (ehAnual) {
      return valorInicial * math.pow(1 + taxaDecimal, periodo);
    } else {
      return valorInicial * math.pow(1 + taxaDecimal / 12, periodo);
    }
  }

  static double calcularValorPresente(
      double valorFinal, double taxa, int periodo, bool ehAnual) {
    double taxaDecimal = taxa / 100;
    if (ehAnual) {
      return valorFinal / math.pow(1 + taxaDecimal, periodo);
    } else {
      return valorFinal / math.pow(1 + taxaDecimal / 12, periodo);
    }
  }
}
