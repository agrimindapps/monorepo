// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../model/alcool_sangue_model.dart';
import '../utils/alcool_sangue_utils.dart';

class AlcoolSangueController extends ChangeNotifier {
  // Controllers
  final alcoolController = TextEditingController();
  final volumeController = TextEditingController();
  final tempoController = TextEditingController();
  final pesoController = TextEditingController();

  // Focus Nodes
  final focusAlcool = FocusNode();
  final focusVolume = FocusNode();
  final focusTempo = FocusNode();
  final focusPeso = FocusNode();

  // Estado
  bool _calculado = false;
  bool get calculado => _calculado;

  AlcoolSangueModel _modelo = AlcoolSangueModel.empty();
  AlcoolSangueModel get modelo => _modelo;

  void limpar() {
    alcoolController.clear();
    volumeController.clear();
    tempoController.clear();
    pesoController.clear();
    _modelo = AlcoolSangueModel.empty();
    _calculado = false;
    notifyListeners();
  }

  String? validarCampo(String valor, String campo, FocusNode focus) {
    try {
      final numero = double.parse(valor.replaceAll(',', '.'));
      switch (campo) {
        case 'alcool':
          if (numero <= 0) {
            return 'O percentual de álcool deve ser maior que zero';
          }
          if (numero > 70) {
            return 'O percentual de álcool parece muito alto (máx. 70%)';
          }
        case 'volume':
          if (numero <= 0) return 'O volume consumido deve ser maior que zero';
          if (numero > 5000) {
            return 'O volume consumido parece muito alto (máx. 5000ml)';
          }
        case 'tempo':
          if (numero < 0) return 'O tempo não pode ser negativo';
          if (numero > 48) return 'O tempo parece muito alto (máx. 48h)';
        case 'peso':
          if (numero < 30) return 'O peso parece muito baixo (mín. 30kg)';
          if (numero > 200) return 'O peso parece muito alto (máx. 200kg)';
      }
      return null;
    } catch (e) {
      return 'Valor inválido';
    }
  }

  bool calcular() {
    // Validar campos
    final validacaoAlcool =
        validarCampo(alcoolController.text, 'alcool', focusAlcool);
    if (validacaoAlcool != null) {
      focusAlcool.requestFocus();
      return false;
    }

    final validacaoVolume =
        validarCampo(volumeController.text, 'volume', focusVolume);
    if (validacaoVolume != null) {
      focusVolume.requestFocus();
      return false;
    }

    final validacaoTempo =
        validarCampo(tempoController.text, 'tempo', focusTempo);
    if (validacaoTempo != null) {
      focusTempo.requestFocus();
      return false;
    }

    final validacaoPeso = validarCampo(pesoController.text, 'peso', focusPeso);
    if (validacaoPeso != null) {
      focusPeso.requestFocus();
      return false;
    }

    // Processar os dados
    final alcoolPerc = double.parse(alcoolController.text.replaceAll(',', '.'));
    final volume = double.parse(volumeController.text.replaceAll(',', '.'));
    final tempo = double.parse(tempoController.text.replaceAll(',', '.'));
    final peso = double.parse(pesoController.text.replaceAll(',', '.'));

    // Calcular TAS
    final tas = AlcoolSangueUtils.calcularTAS(alcoolPerc, volume, tempo, peso);

    // Obter condição
    final condicao = AlcoolSangueUtils.obterCondicao(tas);

    // Atualizar modelo e estado
    _modelo = AlcoolSangueModel(
      alcoolPerc: alcoolPerc,
      volume: volume,
      tempo: tempo,
      peso: peso,
      tas: tas,
      condicao: condicao,
    );
    _calculado = true;
    notifyListeners();
    return true;
  }

  void compartilhar() {
    final texto = AlcoolSangueUtils.gerarTextoCompartilhamento(_modelo);
    SharePlus.instance.share(ShareParams(text: texto));
  }

  @override
  void dispose() {
    alcoolController.dispose();
    volumeController.dispose();
    tempoController.dispose();
    pesoController.dispose();
    focusAlcool.dispose();
    focusVolume.dispose();
    focusTempo.dispose();
    focusPeso.dispose();
    super.dispose();
  }
}
