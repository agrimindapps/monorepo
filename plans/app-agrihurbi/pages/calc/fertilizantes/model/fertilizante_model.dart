// Package imports:
import 'package:intl/intl.dart';

class FertilizanteModel {
  num nitrogenio;
  num fosforo;
  num potassio;
  num quantidade;
  num resultadoDap;
  num resultadoU;
  num resultadoMop;
  bool calculado;
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  FertilizanteModel({
    this.nitrogenio = 0,
    this.fosforo = 0,
    this.potassio = 0,
    this.quantidade = 0,
    this.resultadoDap = 0,
    this.resultadoU = 0,
    this.resultadoMop = 0,
    this.calculado = false,
  });

  void calcular() {
    final dap = (quantidade * fosforo) / 46;
    final proporcaoN = (18 * dap) / quantidade;
    final nitrogenioRestante = nitrogenio - proporcaoN;
    final ureia = (quantidade * nitrogenioRestante) / 46;
    final mop = (quantidade * potassio) / 60;

    resultadoDap = dap;
    resultadoU = ureia;
    resultadoMop = mop;
    calculado = true;
  }

  void limpar() {
    nitrogenio = 0;
    fosforo = 0;
    potassio = 0;
    quantidade = 0;
    resultadoDap = 0;
    resultadoU = 0;
    resultadoMop = 0;
    calculado = false;
  }

  String gerarTextoCompartilhamento() {
    return '''
    Fertilizantes

    Valores
    Nitrogênio: ${_numberFormat.format(nitrogenio)} N
    Fósforo: ${_numberFormat.format(fosforo)} P
    Potássio: ${_numberFormat.format(potassio)} K
    Quantidade: ${_numberFormat.format(quantidade)} Kgs

    Resultado
    DAP: ${_numberFormat.format(resultadoDap)} Kg
    U: ${_numberFormat.format(resultadoU)} Kg
    MOP: ${_numberFormat.format(resultadoMop)} Kg
    ''';
  }
}
