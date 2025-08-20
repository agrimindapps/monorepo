// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../models/balanco_nitrogenio.dart';

class BalancoNitrogenioController extends GetxController {
  final _balancoNitrogenio = BalancoNitrogenio();
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');

  // Controllers
  final areaPlantio = TextEditingController();
  final produtividadeEsperada = TextEditingController();
  final teorNitrogenioSolo = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();

  bool calculado = false;

  BalancoNitrogenioController() {
    _setupListeners();
  }

  void _setupListeners() {
    areaPlantio.addListener(() {
      if (areaPlantio.text.isNotEmpty) {
        _balancoNitrogenio.areaPlantio =
            num.parse(areaPlantio.text.replaceAll(',', '.'));
      }
    });

    produtividadeEsperada.addListener(() {
      if (produtividadeEsperada.text.isNotEmpty) {
        _balancoNitrogenio.produtividadeEsperada =
            num.parse(produtividadeEsperada.text.replaceAll(',', '.'));
      }
    });

    teorNitrogenioSolo.addListener(() {
      if (teorNitrogenioSolo.text.isNotEmpty) {
        _balancoNitrogenio.teorNitrogenioSolo =
            num.parse(teorNitrogenioSolo.text.replaceAll(',', '.'));
      }
    });
  }

  bool validarCampos(Function(String) exibirMensagem) {
    if (areaPlantio.text.isEmpty) {
      focus1.requestFocus();
      exibirMensagem('Informe a área de plantio');
      return false;
    }

    if (produtividadeEsperada.text.isEmpty) {
      focus2.requestFocus();
      exibirMensagem('Informe a produtividade esperada');
      return false;
    }

    if (teorNitrogenioSolo.text.isEmpty) {
      focus3.requestFocus();
      exibirMensagem('Informe o teor de nitrogênio no solo');
      return false;
    }

    return true;
  }

  void calcular() {
    _balancoNitrogenio.calcular();
    calculado = true;
    
  }

  void limpar() {
    areaPlantio.clear();
    produtividadeEsperada.clear();
    teorNitrogenioSolo.clear();
    _balancoNitrogenio.limpar();
    calculado = false;
    
  }

  String getShareText() {
    return '''
    Balanço de Nitrogênio

    Valores
    Área de plantio: ${_numberFormat.format(_balancoNitrogenio.areaPlantio)} ha
    Produtividade esperada: ${_numberFormat.format(_balancoNitrogenio.produtividadeEsperada)} kg/ha
    Teor de nitrogênio no solo: ${_numberFormat.format(_balancoNitrogenio.teorNitrogenioSolo)} kg/ha

    Resultados
    Necessidade de nitrogênio: ${_numberFormat.format(_balancoNitrogenio.nitrogenioNecessario)} kg
    Nitrogênio disponível no solo: ${_numberFormat.format(_balancoNitrogenio.nitrogenioSolo)} kg
    Nitrogênio de fixação biológica: ${_numberFormat.format(_balancoNitrogenio.nitrogenioFixacao)} kg
    Nitrogênio a ser adicionado: ${_numberFormat.format(_balancoNitrogenio.nitrogenioAdicionar)} kg
    ''';
  }

  // Getters para os resultados
  num get nitrogenioNecessario => _balancoNitrogenio.nitrogenioNecessario;
  num get nitrogenioSolo => _balancoNitrogenio.nitrogenioSolo;
  num get nitrogenioFixacao => _balancoNitrogenio.nitrogenioFixacao;
  num get nitrogenioAdicionar => _balancoNitrogenio.nitrogenioAdicionar;

  String formatNumber(num value) => _numberFormat.format(value);

  @override
  void onClose() {
    areaPlantio.dispose();
    produtividadeEsperada.dispose();
    teorNitrogenioSolo.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    super.onClose();
  }
}
