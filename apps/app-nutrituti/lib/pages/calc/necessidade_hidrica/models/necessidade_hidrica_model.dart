// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NecessidadeHidricaModel {
  // Controllers e focus nodes
  final TextEditingController pesoController = TextEditingController();
  final FocusNode focusPeso = FocusNode();

  // Variáveis
  double peso = 0;
  double resultado = 0;
  double resultadoAjustado = 0;
  bool calculado = false;
  bool showInfoCard = true;

  // Seleção de nível de atividade física
  int nivelAtividadeSelecionado = 1;
  final List<Map<String, dynamic>> niveisAtividade = [
    {'id': 1, 'text': 'Sedentário (pouco ou nenhum exercício)', 'fator': 0.0},
    {
      'id': 2,
      'text': 'Levemente ativo (exercício leve 1-3 dias/semana)',
      'fator': 0.2
    },
    {
      'id': 3,
      'text': 'Moderadamente ativo (exercício moderado 3-5 dias/semana)',
      'fator': 0.4
    },
    {
      'id': 4,
      'text': 'Muito ativo (exercício intenso 6-7 dias/semana)',
      'fator': 0.6
    },
    {
      'id': 5,
      'text': 'Extra ativo (exercício muito intenso, trabalho físico)',
      'fator': 0.8
    },
  ];

  // Seleção de clima
  int climaSelecionado = 2;
  final List<Map<String, dynamic>> tiposClima = [
    {'id': 1, 'text': 'Muito frio', 'fator': -0.2},
    {'id': 2, 'text': 'Temperado/Ameno', 'fator': 0.0},
    {'id': 3, 'text': 'Quente', 'fator': 0.2},
    {'id': 4, 'text': 'Muito quente e seco', 'fator': 0.4},
  ];

  // Formatadores de texto
  final pesoMask = MaskTextInputFormatter(
    mask: '###,##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Método para verificar se os campos estão válidos
  bool isValid() {
    if (pesoController.text.isEmpty) {
      return false;
    }

    try {
      final pesoValue = double.parse(pesoController.text.replaceAll(',', '.'));
      if (pesoValue <= 0 || pesoValue > 300) {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  // Método para obter o fator de nível de atividade
  double getNivelAtividadeFator() {
    final nivelAtividade = niveisAtividade.firstWhere(
      (nivel) => nivel['id'] == nivelAtividadeSelecionado,
      orElse: () => niveisAtividade[0],
    );
    return nivelAtividade['fator'];
  }

  // Método para obter o fator de clima
  double getClimaFator() {
    final clima = tiposClima.firstWhere(
      (tipo) => tipo['id'] == climaSelecionado,
      orElse: () => tiposClima[1],
    );
    return clima['fator'];
  }

  // Método para limpar os dados
  void limpar() {
    peso = 0;
    resultado = 0;
    resultadoAjustado = 0;
    nivelAtividadeSelecionado = 1;
    climaSelecionado = 2;
    pesoController.clear();
    calculado = false;
  }

  // Método para liberar recursos
  void dispose() {
    pesoController.dispose();
    focusPeso.dispose();
  }
}
