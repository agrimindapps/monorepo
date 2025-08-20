// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/maquinario_calculation.dart';

class MaquinarioController extends GetxController {
  final _calculation = MaquinarioCalculation();

  // Estado compartilhado
  final RxBool _calculado = false.obs;
  final RxNum _resultado = RxNum(0);

  bool get calculado => _calculado.value;
  num get resultado => _resultado.value;

  // Métodos genéricos
  void limpar() {
    _calculado.value = false;
    _resultado.value = 0;
  }

  // Formatação
  String formatNumber(num value) {
    return _calculation.formatNumber(value);
  }

  // Cálculo de Consumo
  void calcularConsumo(
      double horaInicial, double horaFinal, double litrosAbastecidos) {
    _resultado.value = _calculation.calculateConsumo(
        horaInicial, horaFinal, litrosAbastecidos);
    _calculado.value = true;
  }

  // Cálculo de Patinamento
  void calcularPatinamento(double tempoLevantado, double tempoBaixado) {
    _resultado.value =
        _calculation.calculatePatinamento(tempoLevantado, tempoBaixado);
    _calculado.value = true;
  }

  // Cálculo de Patinamento N
  void calcularPatinamentoN(double voltasLevantado, double voltasBaixada) {
    _resultado.value =
        _calculation.calculatePatinamentoN(voltasLevantado, voltasBaixada);
    _calculado.value = true;
  }

  // Cálculo de Velocidade
  void calcularVelocidade(double distancia, double tempo) {
    _resultado.value = _calculation.calculateVelocidade(distancia, tempo);
    _calculado.value = true;
  }
}
