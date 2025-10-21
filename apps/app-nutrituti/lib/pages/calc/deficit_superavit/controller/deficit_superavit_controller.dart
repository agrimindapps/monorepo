// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/deficit_superavit_model.dart';

class DeficitSuperavitController extends ChangeNotifier {
  final DeficitSuperavitModel model;

  // Controllers e focus nodes
  final caloriasDiariasController = TextEditingController();
  final metaPesoController = TextEditingController();
  final tempoSemanaController = TextEditingController(text: '12');
  final focusCalorias = FocusNode();
  final focusMetaPeso = FocusNode();
  final focusTempo = FocusNode();

  DeficitSuperavitController() : model = DeficitSuperavitModel();

  bool get calculado => model.calculado;
  bool get perderPeso => model.perderPeso;
  int get tipoMetaSelecionado => model.tipoMetaSelecionado;
  double get deficitSuperavitDiario => model.deficitSuperavitDiario;
  double get deficitSuperavitSemanal => model.deficitSuperavitSemanal;
  double get metaCaloricaDiaria => model.metaCaloricaDiaria;

  void calcular(BuildContext context) {
    if (caloriasDiariasController.text.isEmpty) {
      _exibirMensagem(
          context, 'Necessário informar as calorias diárias atuais.');
      focusCalorias.requestFocus();
      return;
    }

    if (metaPesoController.text.isEmpty) {
      _exibirMensagem(context, 'Necessário informar a meta de peso.');
      focusMetaPeso.requestFocus();
      return;
    }

    if (tempoSemanaController.text.isEmpty) {
      _exibirMensagem(
          context, 'Necessário informar o tempo para atingir a meta.');
      focusTempo.requestFocus();
      return;
    }

    model.caloriasDiarias = double.parse(caloriasDiariasController.text);
    model.metaPeso = double.parse(metaPesoController.text.replaceAll(',', '.'));
    model.tempoSemanas = int.parse(tempoSemanaController.text);

    model.calcular();

    // Atualizar o texto do controller se o tempo foi ajustado
    if (int.parse(tempoSemanaController.text) != model.tempoSemanas) {
      tempoSemanaController.text = model.tempoSemanas.toString();
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    notifyListeners();
  }

  void compartilhar() {
    Share.share(model.gerarTextoCompartilhamento());
  }

  void _exibirMensagem(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.red.shade900);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void limpar() {
    model.limpar();
    caloriasDiariasController.clear();
    metaPesoController.clear();
    tempoSemanaController.text = '12';
    notifyListeners();
  }

  void handleTipoMetaChanged(int value) {
    model.tipoMetaSelecionado = value;
    model.perderPeso = value == 1;
    notifyListeners();
  }

  @override
  void dispose() {
    caloriasDiariasController.dispose();
    metaPesoController.dispose();
    tempoSemanaController.dispose();
    focusCalorias.dispose();
    focusMetaPeso.dispose();
    focusTempo.dispose();
    super.dispose();
  }
}
