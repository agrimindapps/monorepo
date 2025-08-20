// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/sistema_irrigacao_model.dart';
import '../models/tempo_irrigacao_model.dart';

class TempoIrrigacaoController extends GetxController {
  final _model = TempoIrrigacaoModel(
    laminaAplicar: 0,
    vazaoEmissor: 0,
    espacamentoEmissores: 0,
    espacamentoLinhas: 0,
    eficienciaIrrigacao: 85, // Valor padrão
  );

  // Controllers para os campos de texto
  final laminaAplicarController = TextEditingController();
  final vazaoEmissorController = TextEditingController();
  final espacamentoEmissoresController = TextEditingController();
  final espacamentoLinhasController = TextEditingController();
  final eficienciaIrrigacaoController = TextEditingController();

  // Focus nodes
  final laminaAplicarFocus = FocusNode();
  final vazaoEmissorFocus = FocusNode();
  final espacamentoEmissoresFocus = FocusNode();
  final espacamentoLinhasFocus = FocusNode();
  final eficienciaIrrigacaoFocus = FocusNode();

  // Estado do formulário
  final RxBool _calculado = false.obs;
  final RxnString _selectedSistema = RxnString();

  // Getters
  bool get calculado => _calculado.value;
  String? get selectedSistema => _selectedSistema.value;
  TempoIrrigacaoModel get model => _model;

  TempoIrrigacaoController() {
    _inicializar();
  }

  void _inicializar() {
    eficienciaIrrigacaoController.text = _model.eficienciaIrrigacao.toString();
  }

  void setSistemaIrrigacao(String? sistema) {
    _selectedSistema.value = sistema;
    if (sistema != null) {
      final sistemaInfo = SistemaIrrigacaoInfo.sistemasDisponiveis
          .firstWhere((info) => info.nome == sistema);

      vazaoEmissorController.text = sistemaInfo.vazaoPadrao.toString();
      espacamentoEmissoresController.text =
          sistemaInfo.espacamentoPadrao.toString();
      eficienciaIrrigacaoController.text =
          (sistemaInfo.eficienciaPadrao * 100).toString();

      _model.vazaoEmissor = sistemaInfo.vazaoPadrao;
      _model.espacamentoEmissores = sistemaInfo.espacamentoPadrao;
      _model.eficienciaIrrigacao = sistemaInfo.eficienciaPadrao * 100;
    }
  }

  bool validarCampos() {
    if (laminaAplicarController.text.isEmpty) {
      laminaAplicarFocus.requestFocus();
      return false;
    }
    if (vazaoEmissorController.text.isEmpty) {
      vazaoEmissorFocus.requestFocus();
      return false;
    }
    if (espacamentoEmissoresController.text.isEmpty) {
      espacamentoEmissoresFocus.requestFocus();
      return false;
    }
    if (espacamentoLinhasController.text.isEmpty) {
      espacamentoLinhasFocus.requestFocus();
      return false;
    }
    if (eficienciaIrrigacaoController.text.isEmpty) {
      eficienciaIrrigacaoFocus.requestFocus();
      return false;
    }
    return true;
  }

  void calcular() {
    if (!validarCampos()) return;

    _model.laminaAplicar =
        double.parse(laminaAplicarController.text.replaceAll(',', '.'));
    _model.vazaoEmissor =
        double.parse(vazaoEmissorController.text.replaceAll(',', '.'));
    _model.espacamentoEmissores =
        double.parse(espacamentoEmissoresController.text.replaceAll(',', '.'));
    _model.espacamentoLinhas =
        double.parse(espacamentoLinhasController.text.replaceAll(',', '.'));
    _model.eficienciaIrrigacao =
        double.parse(eficienciaIrrigacaoController.text.replaceAll(',', '.'));

    _model.calcular();
    _calculado.value = true;
  }

  void limpar() {
    _calculado.value = false;
    laminaAplicarController.clear();
    vazaoEmissorController.clear();
    espacamentoEmissoresController.clear();
    espacamentoLinhasController.clear();
    eficienciaIrrigacaoController.text = '85';
    _selectedSistema.value = null;
  }

  @override
  void onClose() {
    laminaAplicarController.dispose();
    vazaoEmissorController.dispose();
    espacamentoEmissoresController.dispose();
    espacamentoLinhasController.dispose();
    eficienciaIrrigacaoController.dispose();

    laminaAplicarFocus.dispose();
    vazaoEmissorFocus.dispose();
    espacamentoEmissoresFocus.dispose();
    espacamentoLinhasFocus.dispose();
    eficienciaIrrigacaoFocus.dispose();

    super.onClose();
  }
}
