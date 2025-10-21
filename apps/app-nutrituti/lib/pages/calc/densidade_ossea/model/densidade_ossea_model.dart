// Modelo de dados para o cálculo de densidade óssea

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class DensidadeOsseaModel {
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final FocusNode focusIdade = FocusNode();
  final FocusNode focusPeso = FocusNode();
  int idade = 0;
  double peso = 0;
  int generoSelecionado = 1;
  final List<Map<String, dynamic>> generos = [
    {'id': 1, 'text': 'Masculino'},
    {'id': 2, 'text': 'Feminino'}
  ];
  bool historicoFamiliar = false;
  bool atividadeFisicaBaixa = false;
  bool fumante = false;
  bool consumoAlcool = false;
  bool dietaPobre = false;
  bool menopausa = false;
  bool corticosteroides = false;
  bool doencasTiroide = false;
  int pontuacao = 0;
  String resultado = '';
  String recomendacoes = '';
  bool calculado = false;
  bool showInfoCard = true;
  var pesoMask = MaskTextInputFormatter(
    mask: '##,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  var alturaMask = MaskTextInputFormatter(
    mask: '#,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  var inteiroMask = MaskTextInputFormatter(
    mask: '###',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  void limpar() {
    generoSelecionado = 1;
    idade = 0;
    peso = 0;
    pontuacao = 0;
    resultado = '';
    recomendacoes = '';
    idadeController.clear();
    pesoController.clear();
    historicoFamiliar = false;
    atividadeFisicaBaixa = false;
    fumante = false;
    consumoAlcool = false;
    dietaPobre = false;
    menopausa = false;
    corticosteroides = false;
    doencasTiroide = false;
    calculado = false;
  }

  int countFatoresRisco() {
    int count = 0;
    if (historicoFamiliar) count++;
    if (atividadeFisicaBaixa) count++;
    if (fumante) count++;
    if (consumoAlcool) count++;
    if (dietaPobre) count++;
    if (generoSelecionado == 2 && menopausa) count++;
    if (corticosteroides) count++;
    if (doencasTiroide) count++;
    return count;
  }

  void dispose() {
    idadeController.dispose();
    pesoController.dispose();
    focusIdade.dispose();
    focusPeso.dispose();
  }
}
