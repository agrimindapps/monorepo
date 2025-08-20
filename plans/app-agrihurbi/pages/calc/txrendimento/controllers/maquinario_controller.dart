// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../models/maquinario_model.dart';

class MaquinarioController extends GetxController {
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');
  late TabController tabController;
  final List<MaquinarioModel> calculos = [];

  MaquinarioController(TickerProvider vsync) {
    tabController = TabController(length: 4, vsync: vsync);
    _initializeCalculos();
  }

  void _initializeCalculos() {
    calculos.addAll([
      MaquinarioModel(
        title: 'Consumo Lt/H',
        tipo: TipoCalculo.consumo,
        cor: Colors.orange,
      ),
      MaquinarioModel(
        title: 'Patinamento',
        tipo: TipoCalculo.patinamento,
        cor: Colors.blue,
      ),
      MaquinarioModel(
        title: 'Patinamento N',
        tipo: TipoCalculo.patinamentoN,
        cor: Colors.purple,
      ),
      MaquinarioModel(
        title: 'Velocidade',
        tipo: TipoCalculo.velocidade,
        cor: Colors.green,
      ),
    ]);
  }

  double calcularResultado(TipoCalculo tipo, double valor1, double valor2) {
    switch (tipo) {
      case TipoCalculo.consumo:
        return valor2 / (valor2 - valor1);
      case TipoCalculo.patinamento:
      case TipoCalculo.patinamentoN:
        return ((valor2 / valor1) - 1) * 100;
      case TipoCalculo.velocidade:
        return (valor1 / valor2) * 3.6;
    }
  }

  void updateCalculo(int index, double valor1, double valor2) {
    final calculo = calculos[index];
    final resultado = calcularResultado(calculo.tipo, valor1, valor2);

    calculos[index] = calculo.copyWith(
      valor1: valor1,
      valor2: valor2,
      resultado: resultado,
    );

    
  }

  String formatNumber(double value) {
    return _numberFormat.format(value);
  }

  void compartilharResultado(int index) {
    final calculo = calculos[index];
    String unidades;
    String descricao;

    switch (calculo.tipo) {
      case TipoCalculo.consumo:
        unidades = 'Hras, Hras, Lts, Lt/Ha';
        descricao = 'Consumo de Diesel L/H';
        break;
      case TipoCalculo.patinamento:
        unidades = 'Segs, Segs, %';
        descricao = 'Índice de Patinamento em 100 m';
        break;
      case TipoCalculo.patinamentoN:
        unidades = 'Und, Und, %';
        descricao = 'Índice de Patinamento em 100 m por N de voltas';
        break;
      case TipoCalculo.velocidade:
        unidades = 'Mts, Segs, Km/H';
        descricao = 'Velocidade de operação em Km/H';
        break;
    }

    final shareText = '''
    $descricao
    
    Valores
    Valor 1: ${formatNumber(calculo.valor1)} ${unidades.split(', ')[0]}
    Valor 2: ${formatNumber(calculo.valor2)} ${unidades.split(', ')[1]}
    
    Resultado
    ${formatNumber(calculo.resultado)} ${unidades.split(', ').last}
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
