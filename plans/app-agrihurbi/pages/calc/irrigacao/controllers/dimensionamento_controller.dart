// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
// Project imports:
import '../models/dimensionamento_model.dart';

class DimensionamentoController extends GetxController {
  final _model = DimensionamentoModel(
    vazaoRequerida: 0,
    areaIrrigada: 0,
    espacamentoAspersores: 0,
    pressaoOperacao: 0,
    tempoDisponivel: 0,
  );

  // Controllers para os campos de texto
  final vazaoRequeridaController = TextEditingController();
  final areaIrrigadaController = TextEditingController();
  final espacamentoAspersoresController = TextEditingController();
  final pressaoOperacaoController = TextEditingController();
  final tempoDisponivelController = TextEditingController();

  // Focus nodes
  final vazaoRequeridaFocus = FocusNode();
  final areaIrrigadaFocus = FocusNode();
  final espacamentoAspersoresFocus = FocusNode();
  final pressaoOperacaoFocus = FocusNode();
  final tempoDisponivelFocus = FocusNode();

  // Estado do formulário
  final RxBool _calculado = false.obs;

  // Getters
  bool get calculado => _calculado.value;
  DimensionamentoModel get model => _model;

  bool validarCampos() {
    if (vazaoRequeridaController.text.isEmpty) {
      vazaoRequeridaFocus.requestFocus();
      return false;
    }
    if (areaIrrigadaController.text.isEmpty) {
      areaIrrigadaFocus.requestFocus();
      return false;
    }
    if (espacamentoAspersoresController.text.isEmpty) {
      espacamentoAspersoresFocus.requestFocus();
      return false;
    }
    if (pressaoOperacaoController.text.isEmpty) {
      pressaoOperacaoFocus.requestFocus();
      return false;
    }
    if (tempoDisponivelController.text.isEmpty) {
      tempoDisponivelFocus.requestFocus();
      return false;
    }
    return true;
  }

  void calcular() {
    if (!validarCampos()) return;

    _model.vazaoRequerida =
        double.parse(vazaoRequeridaController.text.replaceAll(',', '.'));
    _model.areaIrrigada =
        double.parse(areaIrrigadaController.text.replaceAll(',', '.'));
    _model.espacamentoAspersores =
        double.parse(espacamentoAspersoresController.text.replaceAll(',', '.'));
    _model.pressaoOperacao =
        double.parse(pressaoOperacaoController.text.replaceAll(',', '.'));
    _model.tempoDisponivel =
        double.parse(tempoDisponivelController.text.replaceAll(',', '.'));

    _model.calcular();
    _calculado.value = true;
  }

  void limpar() {
    _calculado.value = false;
    vazaoRequeridaController.clear();
    areaIrrigadaController.clear();
    espacamentoAspersoresController.clear();
    pressaoOperacaoController.clear();
    tempoDisponivelController.clear();
  }

  @override
  void onClose() {
    vazaoRequeridaController.dispose();
    areaIrrigadaController.dispose();
    espacamentoAspersoresController.dispose();
    pressaoOperacaoController.dispose();
    tempoDisponivelController.dispose();

    vazaoRequeridaFocus.dispose();
    areaIrrigadaFocus.dispose();
    espacamentoAspersoresFocus.dispose();
    pressaoOperacaoFocus.dispose();
    tempoDisponivelFocus.dispose();

    super.onClose();
  }
}
