// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../models/necessidades_caloricas_model.dart';
import '../utils/necessidades_caloricas_utils.dart';

class NecessidasCaloricas_Controller extends ChangeNotifier {
  final TextEditingController pesoController = TextEditingController();
  String? especieSelecionada;
  String? estadoFisiologicoSelecionado;
  String? nivelAtividadeSelecionado;
  NecessidadesCaloricas? resultado;
  bool showInfoCard = true;

  void toggleInfoCard() {
    showInfoCard = !showInfoCard;
    notifyListeners();
  }

  void limpar() {
    pesoController.clear();
    especieSelecionada = null;
    estadoFisiologicoSelecionado = null;
    nivelAtividadeSelecionado = null;
    resultado = null;
    notifyListeners();
  }

  void atualizarEspecie(String? especie) {
    especieSelecionada = especie;
    estadoFisiologicoSelecionado = null;
    nivelAtividadeSelecionado = null;
    notifyListeners();
  }

  void atualizarEstadoFisiologico(String? estado) {
    estadoFisiologicoSelecionado = estado;
    notifyListeners();
  }

  void atualizarNivelAtividade(String? nivel) {
    nivelAtividadeSelecionado = nivel;
    notifyListeners();
  }

  String? validatePeso(String? value) {
    return NecessidadesCaloricas_Utils.validateNumber(value);
  }

  void calcular() {
    if (pesoController.text.isNotEmpty &&
        especieSelecionada != null &&
        estadoFisiologicoSelecionado != null &&
        nivelAtividadeSelecionado != null) {
      final peso = double.parse(pesoController.text.replaceAll(',', '.'));
      final rer = _calcularRER(peso);

      final fatorBase = NecessidadesCaloricas_Utils
          .fatoresBase[especieSelecionada!]![estadoFisiologicoSelecionado!]!;
      final fatorAtividade = NecessidadesCaloricas_Utils
          .fatoresAtividade[especieSelecionada!]![nivelAtividadeSelecionado!]!;

      final resultadoCalculo = rer * fatorBase * fatorAtividade;
      final recomendacao = _gerarRecomendacao(
        especie: especieSelecionada!,
        estadoFisiologico: estadoFisiologicoSelecionado!,
      );

      resultado = NecessidadesCaloricas(
        peso: peso,
        especie: especieSelecionada!,
        estadoFisiologico: estadoFisiologicoSelecionado!,
        nivelAtividade: nivelAtividadeSelecionado!,
        resultado: resultadoCalculo,
        recomendacao: recomendacao,
      );

      notifyListeners();
    }
  }

  double _calcularRER(double peso) {
    return 70 * math.pow(peso, 0.75).toDouble();
  }

  String _gerarRecomendacao({
    required String especie,
    required String estadoFisiologico,
  }) {
    String recomendacao = 'Recomendações:\n';

    if (especie == 'Cão') {
      if (estadoFisiologico == 'Filhote') {
        recomendacao += '• Divida a alimentação em 3-4 refeições por dia.\n';
        recomendacao +=
            '• Utilize ração específica para filhotes de cachorro.\n';
      } else if (estadoFisiologico == 'Idoso') {
        recomendacao +=
            '• Prefira alimentos de fácil digestão e baixo teor de gordura.\n';
        recomendacao +=
            '• Monitore o peso regularmente para evitar obesidade.\n';
      } else if (estadoFisiologico == 'Castrado') {
        recomendacao +=
            '• Cães castrados tendem a ganhar peso. Monitore cuidadosamente.\n';
      }
    } else if (especie == 'Gato') {
      if (estadoFisiologico == 'Filhote') {
        recomendacao += '• Divida a alimentação em 3-4 refeições por dia.\n';
        recomendacao += '• Utilize ração específica para filhotes de gato.\n';
      } else if (estadoFisiologico == 'Idoso') {
        recomendacao +=
            '• Prefira alimentos com maior teor de umidade para prevenir problemas renais.\n';
      } else if (estadoFisiologico == 'Castrado') {
        recomendacao +=
            '• Gatos castrados têm necessidades energéticas reduzidas. Monitore o peso.\n';
      }
    }

    recomendacao += '• Sempre disponibilize água fresca.\n';
    recomendacao +=
        '• Ajuste a quantidade de alimento se notar ganho ou perda de peso não planejados.\n';

    return recomendacao;
  }

  @override
  void dispose() {
    pesoController.dispose();
    super.dispose();
  }
}
