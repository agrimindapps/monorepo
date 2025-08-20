// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/capacidade_campo_model.dart';
import '../models/solo_info_model.dart';

class CapacidadeCampoController extends GetxController {
  final _model = CapacidadeCampoModel(
    capacidadeCampo: 36.0, // Valor padrão para solo argiloso
    pontoMurcha: 17.0,
    densidadeSolo: 1.25,
    profundidadeRaiz: 0,
    areaIrrigada: 0,
  );

  // Controllers para os campos de texto
  final soloPesoController = TextEditingController();
  final soloSecoController = TextEditingController();
  final capacidadeCampoController = TextEditingController();
  final pontoMurchaController = TextEditingController();
  final densidadeSoloController = TextEditingController();
  final profundidadeRaizController = TextEditingController();
  final areaIrrigadaController = TextEditingController();

  // Focus nodes
  final soloPesoFocus = FocusNode();
  final soloSecoFocus = FocusNode();
  final capacidadeCampoFocus = FocusNode();
  final pontoMurchaFocus = FocusNode();
  final densidadeSoloFocus = FocusNode();
  final profundidadeRaizFocus = FocusNode();
  final areaIrrigadaFocus = FocusNode();

  // Estado do formulário
  final RxBool _calculado = false.obs;
  final RxBool _camposAdicionais = false.obs;
  final RxString _tipoSolo = 'Argiloso'.obs;

  // Getters
  bool get calculado => _calculado.value;
  bool get camposAdicionais => _camposAdicionais.value;
  String get tipoSolo => _tipoSolo.value;
  CapacidadeCampoModel get model => _model;

  CapacidadeCampoController() {
    _atualizarValoresPadraoSolo();
  }

  void setCamposAdicionais(bool value) {
    _camposAdicionais.value = value;
    _model.calculoUmidadeAtual = value;
  }

  void setTipoSolo(String tipo) {
    _tipoSolo.value = tipo;
    _atualizarValoresPadraoSolo();
  }

  void _atualizarValoresPadraoSolo() {
    final soloInfo =
        SoloInfo.solosDisponiveis.firstWhere((info) => info.nome == _tipoSolo.value);
    capacidadeCampoController.text = soloInfo.capacidadeCampo.toString();
    pontoMurchaController.text = soloInfo.pontoMurcha.toString();
    densidadeSoloController.text = soloInfo.densidadeSolo.toString();

    // Atualizar modelo
    _model.capacidadeCampo = soloInfo.capacidadeCampo;
    _model.pontoMurcha = soloInfo.pontoMurcha;
    _model.densidadeSolo = soloInfo.densidadeSolo;
  }

  bool validarCampos() {
    if (_camposAdicionais.value) {
      if (soloPesoController.text.isEmpty) {
        soloPesoFocus.requestFocus();
        return false;
      }
      if (soloSecoController.text.isEmpty) {
        soloSecoFocus.requestFocus();
        return false;
      }
    } else {
      if (capacidadeCampoController.text.isEmpty) {
        capacidadeCampoFocus.requestFocus();
        return false;
      }
      if (pontoMurchaController.text.isEmpty) {
        pontoMurchaFocus.requestFocus();
        return false;
      }
      if (densidadeSoloController.text.isEmpty) {
        densidadeSoloFocus.requestFocus();
        return false;
      }
    }

    if (profundidadeRaizController.text.isEmpty) {
      profundidadeRaizFocus.requestFocus();
      return false;
    }
    if (areaIrrigadaController.text.isEmpty) {
      areaIrrigadaFocus.requestFocus();
      return false;
    }

    return true;
  }

  void calcular() {
    if (!validarCampos()) return;

    if (_camposAdicionais.value) {
      _model.soloPesoUmido =
          double.parse(soloPesoController.text.replaceAll(',', '.'));
      _model.soloPesoSeco =
          double.parse(soloSecoController.text.replaceAll(',', '.'));
    }

    _model.capacidadeCampo =
        double.parse(capacidadeCampoController.text.replaceAll(',', '.'));
    _model.pontoMurcha =
        double.parse(pontoMurchaController.text.replaceAll(',', '.'));
    _model.densidadeSolo =
        double.parse(densidadeSoloController.text.replaceAll(',', '.'));
    _model.profundidadeRaiz =
        double.parse(profundidadeRaizController.text.replaceAll(',', '.'));
    _model.areaIrrigada =
        double.parse(areaIrrigadaController.text.replaceAll(',', '.'));

    _model.calcular();
    _calculado.value = true;
  }

  void limpar() {
    _calculado.value = false;
    soloPesoController.clear();
    soloSecoController.clear();
    profundidadeRaizController.clear();
    areaIrrigadaController.clear();
    _atualizarValoresPadraoSolo();
  }

  @override
  void onClose() {
    soloPesoController.dispose();
    soloSecoController.dispose();
    capacidadeCampoController.dispose();
    pontoMurchaController.dispose();
    densidadeSoloController.dispose();
    profundidadeRaizController.dispose();
    areaIrrigadaController.dispose();

    soloPesoFocus.dispose();
    soloSecoFocus.dispose();
    capacidadeCampoFocus.dispose();
    pontoMurchaFocus.dispose();
    densidadeSoloFocus.dispose();
    profundidadeRaizFocus.dispose();
    areaIrrigadaFocus.dispose();

    super.onClose();
  }
}
