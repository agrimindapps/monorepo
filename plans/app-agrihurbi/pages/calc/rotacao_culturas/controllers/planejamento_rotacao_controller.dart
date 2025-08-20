// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/cultura_rotacao.dart';

class PlanejamentoRotacaoController extends GetxController {
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');
  final areaTotal = TextEditingController();
  final focus1 = FocusNode();

  List<CulturaRotacao> culturas = [];
  num areaTotalValue = 0;
  bool calculado = false;

  PlanejamentoRotacaoController() {
    culturas = CulturaRotacao.getDefaultCulturas();
    _setupListeners();
  }

  void _setupListeners() {
    areaTotal.addListener(() {
      if (areaTotal.text.isNotEmpty) {
        areaTotalValue = num.parse(areaTotal.text.replaceAll(',', '.'));
        if (calculado) {
          calcular();
        }
      }
    });
  }

  bool validarCampos(Function(String) exibirMensagem) {
    if (areaTotal.text.isEmpty) {
      focus1.requestFocus();
      exibirMensagem('Informe a área total disponível');
      return false;
    }

    // Verificar se a soma dos percentuais é 100%
    final somaPercentuais =
        culturas.fold<double>(0, (prev, curr) => prev + curr.percentualArea);

    if (somaPercentuais != 100) {
      exibirMensagem('A soma dos percentuais das culturas deve ser 100%');
      return false;
    }

    return true;
  }

  void calcular() {
    areaTotalValue = num.parse(areaTotal.text.replaceAll(',', '.'));

    // Calcula a área para cada cultura baseada no percentual
    for (var cultura in culturas) {
      cultura.areaCultura = areaTotalValue * (cultura.percentualArea / 100);
    }

    calculado = true;
    
  }

  void atualizarPercentual(int index, double novoValor) {
    // Limita o valor máximo para não exceder 100% no total
    double valorMaximo = 100;
    for (int i = 0; i < culturas.length; i++) {
      if (i != index) {
        valorMaximo -= culturas[i].percentualArea;
      }
    }

    if (novoValor > valorMaximo) novoValor = valorMaximo;
    if (novoValor < 0) novoValor = 0;

    culturas[index].percentualArea = novoValor;

    // Recalcula se já tiver calculado antes
    if (calculado) {
      calcular();
    }

    
  }

  void limpar() {
    areaTotal.clear();
    calculado = false;

    // Reseta as áreas das culturas
    for (var cultura in culturas) {
      cultura.areaCultura = 0;
    }

    
  }

  String formatNumber(num value) => _numberFormat.format(value);

  String getShareText() {
    final culturasText = culturas
        .map((c) =>
            '${c.nome}: ${formatNumber(c.percentualArea)}% (${formatNumber(c.areaCultura)} ha)')
        .join('\n');

    return '''
    Planejamento de Rotação de Culturas

    Área Total: ${formatNumber(areaTotalValue)} ha

    Distribuição das Culturas:
    $culturasText
    ''';
  }

  @override
  void onClose() {
    areaTotal.dispose();
    focus1.dispose();
    super.onClose();
  }
}
