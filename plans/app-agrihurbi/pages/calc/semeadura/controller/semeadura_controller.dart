// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/semeadura_model.dart';

class SemeaduraController extends GetxController {
  final _input = SemeaduraInputModel();
  SemeaduraResultModel? _result;
  final RxBool _calculado = false.obs;
  final RxBool _showInfoCard = false.obs;

  // Controllers
  final areaPlantada = TextEditingController();
  final espacamentoLinha = TextEditingController();
  final espacamentoPlanta = TextEditingController();
  final poderGerminacao = TextEditingController();
  final pesoMilSementes = TextEditingController();

  // Focus Nodes
  final focus1 = FocusNode();
  final focus2 = FocusNode();
  final focus3 = FocusNode();
  final focus4 = FocusNode();
  final focus5 = FocusNode();

  // Formatters
  final _numberFormat = NumberFormat('#,###.00#', 'pt_BR');
  final _numberFormatSimple = NumberFormat('###.0#', 'pt_BR');

  // Getters
  bool get calculado => _calculado.value;
  bool get showInfoCard => _showInfoCard.value;
  SemeaduraResultModel? get result => _result;
  NumberFormat get numberFormat => _numberFormat;
  NumberFormat get numberFormatSimple => _numberFormatSimple;
  SemeaduraInputModel get input => _input;

  void toggleInfoCard() {
    _showInfoCard.value = !_showInfoCard.value;
    
  }

  bool validarCampos(Function(String) exibirMensagem) {
    if (areaPlantada.text.isEmpty) {
      focus1.requestFocus();
      exibirMensagem('Informe a área plantada');
      return false;
    }

    if (espacamentoLinha.text.isEmpty) {
      focus2.requestFocus();
      exibirMensagem('Informe o espaçamento entre linhas');
      return false;
    }

    if (espacamentoPlanta.text.isEmpty) {
      focus3.requestFocus();
      exibirMensagem('Informe o espaçamento entre plantas');
      return false;
    }

    if (poderGerminacao.text.isEmpty) {
      focus4.requestFocus();
      exibirMensagem('Informe o poder de germinação');
      return false;
    }

    if (pesoMilSementes.text.isEmpty) {
      focus5.requestFocus();
      exibirMensagem('Informe o peso de mil sementes');
      return false;
    }

    return true;
  }

  void calcular() {
    _input.areaPlantada = num.parse(areaPlantada.text.replaceAll(',', '.'));
    _input.espacamentoLinha =
        num.parse(espacamentoLinha.text.replaceAll(',', '.'));
    _input.espacamentoPlanta =
        num.parse(espacamentoPlanta.text.replaceAll(',', '.'));
    _input.poderGerminacao =
        num.parse(poderGerminacao.text.replaceAll(',', '.'));
    _input.pesoMilSementes =
        num.parse(pesoMilSementes.text.replaceAll(',', '.'));

    _result = SemeaduraResultModel.calculate(_input);
    _calculado.value = true;
    
  }

  void limpar() {
    areaPlantada.clear();
    espacamentoLinha.clear();
    espacamentoPlanta.clear();
    poderGerminacao.clear();
    pesoMilSementes.clear();
    _input.clear();
    _result = null;
    _calculado.value = false;
    
  }

  void compartilhar() {
    if (_result == null) return;

    final shareText = '''
    Cálculo de Semeadura

    Valores
    Área plantada: ${_numberFormatSimple.format(_input.areaPlantada)} ha
    Espaçamento entre linhas: ${_numberFormatSimple.format(_input.espacamentoLinha)} m
    Espaçamento entre plantas: ${_numberFormatSimple.format(_input.espacamentoPlanta)} m
    Poder de germinação: ${_numberFormatSimple.format(_input.poderGerminacao)} %
    Peso de mil sementes: ${_numberFormatSimple.format(_input.pesoMilSementes)} g

    Resultados
    Sementes por m²: ${_numberFormat.format(_result!.sementesM2)}
    Sementes por ha: ${_numberFormat.format(_result!.sementesHa)}
    Sementes total: ${_numberFormat.format(_result!.sementesTotal)}
    Kg de sementes por ha: ${_numberFormat.format(_result!.kgSementesHa)}
    Kg de sementes total: ${_numberFormat.format(_result!.kgSementesTotal)}
    ''';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  void onClose() {
    areaPlantada.dispose();
    espacamentoLinha.dispose();
    espacamentoPlanta.dispose();
    poderGerminacao.dispose();
    pesoMilSementes.dispose();
    focus1.dispose();
    focus2.dispose();
    focus3.dispose();
    focus4.dispose();
    focus5.dispose();
    super.onClose();
  }
}
