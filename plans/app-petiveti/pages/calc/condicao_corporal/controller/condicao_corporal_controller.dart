// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/condicao_corporal_model.dart';

class CondicaoCorporalController {
  final _model = CondicaoCorporalModel();

  // ValueNotifiers for specific properties
  late final ValueNotifier<String?> especieNotifier;
  late final ValueNotifier<int?> indiceNotifier;
  late final ValueNotifier<String?> resultadoNotifier;
  late final ValueNotifier<bool> isLoadingNotifier;

  CondicaoCorporalController() {
    especieNotifier = ValueNotifier(_model.especieSelecionada);
    indiceNotifier = ValueNotifier(_model.indiceSelecionado);
    resultadoNotifier = ValueNotifier(_model.resultado);
    isLoadingNotifier = ValueNotifier(false);
  }

  CondicaoCorporalModel get model => _model;
  bool get showInfoCard => _model.showInfoCard;
  String? get especieSelecionada => _model.especieSelecionada;
  int? get indiceSelecionado => _model.indiceSelecionado;
  String? get resultado => _model.resultado;
  bool get isLoading => isLoadingNotifier.value;

  void limpar() {
    _model.limpar();
    especieNotifier.value = _model.especieSelecionada;
    indiceNotifier.value = _model.indiceSelecionado;
    resultadoNotifier.value = _model.resultado;
  }

  void atualizarEspecie(String? especie) {
    try {
      if (especie != null && !_model.especies.contains(especie)) {
        throw ArgumentError('Espécie inválida: $especie');
      }
      _model.atualizarEspecie(especie);
      especieNotifier.value = _model.especieSelecionada;
      resultadoNotifier.value = _model.resultado;
    } catch (e) {
      debugPrint('Erro ao atualizar espécie: $e');
    }
  }

  void atualizarIndice(int? indice) {
    try {
      if (indice != null && (indice < 1 || indice > 9)) {
        throw ArgumentError('Índice inválido: $indice. Deve estar entre 1 e 9.');
      }
      _model.indiceSelecionado = indice;
      indiceNotifier.value = _model.indiceSelecionado;
      resultadoNotifier.value = _model.resultado;
    } catch (e) {
      debugPrint('Erro ao atualizar índice: $e');
    }
  }

  bool _validateInput() {
    if (_model.especieSelecionada == null) {
      debugPrint('Erro: Espécie não selecionada');
      return false;
    }
    if (_model.indiceSelecionado == null) {
      debugPrint('Erro: Índice não selecionado');
      return false;
    }
    if (_model.indiceSelecionado! < 1 || _model.indiceSelecionado! > 9) {
      debugPrint('Erro: Índice fora do intervalo válido (1-9)');
      return false;
    }
    if (!_model.especies.contains(_model.especieSelecionada)) {
      debugPrint('Erro: Espécie inválida');
      return false;
    }
    return true;
  }

  void calcular() async {
    try {
      if (!_validateInput()) {
        return;
      }

      isLoadingNotifier.value = true;
      
      // Simulate async calculation for better UX
      await Future.delayed(const Duration(milliseconds: 300));
      
      final indiceStr = _model.indiceSelecionado.toString();
      
      // Validação adicional dos dados do modelo
      if (!_model.descricoes.containsKey(_model.especieSelecionada) ||
          !_model.descricoes[_model.especieSelecionada]!.containsKey(indiceStr)) {
        throw StateError('Descrição não encontrada para espécie ${_model.especieSelecionada} e índice $indiceStr');
      }
      
      if (!_model.classificacoes.containsKey(indiceStr)) {
        throw StateError('Classificação não encontrada para índice $indiceStr');
      }
      
      final descricao = _model.descricoes[_model.especieSelecionada]![indiceStr]!;
      final classificacao = _model.classificacoes[indiceStr]!;

      String recomendacao;
      if (_model.indiceSelecionado! <= 3) {
        recomendacao = _model.recomendacoes['baixo'] ?? 'Recomendação não disponível';
      } else if (_model.indiceSelecionado! >= 4 && _model.indiceSelecionado! <= 5) {
        recomendacao = _model.recomendacoes['ideal'] ?? 'Recomendação não disponível';
      } else {
        recomendacao = _model.recomendacoes['alto'] ?? 'Recomendação não disponível';
      }

      _model.resultado = 'Classificação: $classificacao\n\n$descricao\n\nRecomendação: $recomendacao';
      
      isLoadingNotifier.value = false;
      resultadoNotifier.value = _model.resultado;
    } catch (e) {
      isLoadingNotifier.value = false;
      debugPrint('Erro durante o cálculo: $e');
      resultadoNotifier.value = 'Erro ao calcular resultado. Tente novamente.';
    }
  }

  void toggleInfoCard() {
    _model.toggleInfoCard();
  }

  Color getColorForIndice(int indice) {
    if (indice <= 3) {
      return Colors.orange.shade100;
    } else if (indice <= 5) {
      return Colors.green.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  Color getSelectedColorForIndice(int indice) {
    if (indice <= 3) {
      return Colors.orange;
    } else if (indice <= 5) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  void dispose() {
    especieNotifier.dispose();
    indiceNotifier.dispose();
    resultadoNotifier.dispose();
    isLoadingNotifier.dispose();
  }
}
