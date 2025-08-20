// Package imports:
import 'package:intl/intl.dart';

class MaquinarioCalculation {
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  // Cálculo de Consumo (Maquinario01)
  double calculateConsumo(
      double horaInicial, double horaFinal, double litrosAbastecidos) {
    return litrosAbastecidos / (horaFinal - horaInicial);
  }

  // Cálculo de Patinamento (Maquinario02)
  double calculatePatinamento(double tempoLevantado, double tempoBaixado) {
    return ((tempoBaixado / tempoLevantado) - 1) * 100;
  }

  // Cálculo de Patinamento N (Maquinario03)
  double calculatePatinamentoN(double voltasLevantado, double voltasBaixada) {
    return ((voltasBaixada / voltasLevantado) - 1) * 100;
  }

  // Cálculo de Velocidade (Maquinario04)
  double calculateVelocidade(double distancia, double tempo) {
    return (distancia / tempo) * 3.6; // Convertendo m/s para km/h
  }

  String formatNumber(num value) {
    return _numberFormat.format(value);
  }
}
