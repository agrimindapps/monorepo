// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/cultura_info_model.dart';
import '../models/necessidade_hidrica_model.dart';

class NecessidadeHidricaController extends GetxController {
  final _model = NecessidadeHidricaModel(
    evapotranspiracao: 0,
    coeficienteCultura: 0,
    areaPlantada: 0,
    eficienciaIrrigacao: 75, // Valor padrão
  );

  // Controllers para os campos de texto
  final evapotranspiracaoController = TextEditingController();
  final coeficienteCulturaController = TextEditingController();
  final areaPlantadaController = TextEditingController();
  final eficienciaIrrigacaoController = TextEditingController();

  // Focus nodes
  final evapotranspiracaoFocus = FocusNode();
  final coeficienteCulturaFocus = FocusNode();
  final areaPlantadaFocus = FocusNode();
  final eficienciaIrrigacaoFocus = FocusNode();

  // Estado do formulário
  final RxBool _calculado = false.obs;
  final RxnString _selectedCultura = RxnString();

  // Getters
  bool get calculado => _calculado.value;
  String? get selectedCultura => _selectedCultura.value;
  NecessidadeHidricaModel get model => _model;

  NecessidadeHidricaController() {
    _inicializar();
  }

  void _inicializar() {
    eficienciaIrrigacaoController.text = _model.eficienciaIrrigacao.toString();
  }

  void setCultura(String? cultura) {
    _selectedCultura.value = cultura;
    if (cultura != null) {
      final culturaInfo = CulturaInfo.culturasDisponiveis
          .firstWhere((info) => info.nome == cultura);
      coeficienteCulturaController.text = culturaInfo.kcMedio.toString();
      _model.coeficienteCultura = culturaInfo.kcMedio;
    }
  }

  bool validarCampos() {
    if (evapotranspiracaoController.text.isEmpty) {
      evapotranspiracaoFocus.requestFocus();
      return false;
    }
    if (coeficienteCulturaController.text.isEmpty) {
      coeficienteCulturaFocus.requestFocus();
      return false;
    }
    if (areaPlantadaController.text.isEmpty) {
      areaPlantadaFocus.requestFocus();
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

    _model.evapotranspiracao =
        double.parse(evapotranspiracaoController.text.replaceAll(',', '.'));
    _model.coeficienteCultura =
        double.parse(coeficienteCulturaController.text.replaceAll(',', '.'));
    _model.areaPlantada =
        double.parse(areaPlantadaController.text.replaceAll(',', '.'));
    _model.eficienciaIrrigacao =
        double.parse(eficienciaIrrigacaoController.text.replaceAll(',', '.'));

    _model.calcular();
    _calculado.value = true;
  }

  void limpar() {
    _calculado.value = false;
    evapotranspiracaoController.clear();
    coeficienteCulturaController.clear();
    areaPlantadaController.clear();
    eficienciaIrrigacaoController.text = '75';
    _selectedCultura.value = null;
  }

  @override
  void onClose() {
    evapotranspiracaoController.dispose();
    coeficienteCulturaController.dispose();
    areaPlantadaController.dispose();
    eficienciaIrrigacaoController.dispose();

    evapotranspiracaoFocus.dispose();
    coeficienteCulturaFocus.dispose();
    areaPlantadaFocus.dispose();
    eficienciaIrrigacaoFocus.dispose();

    super.onClose();
  }
}
