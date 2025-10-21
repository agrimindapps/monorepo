// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../model/alcool_sangue_model.dart';

class AlcoolSangueUtils {
  static final _numberFormat = NumberFormat('#,##0.00', 'pt_BR');

  static double calcularTAS(
      double alcoolPerc, double volume, double tempo, double peso) {
    final pesoEmLibras = peso * 2.2;
    final volumeEmOz = volume / 29.5735;
    final tas =
        ((alcoolPerc * volumeEmOz * 0.075) / pesoEmLibras) - (tempo * 0.015);

    // Garantir que o TAS não seja negativo
    return math.max(0, tas);
  }

  static String obterCondicao(double tas) {
    if (tas <= 0) {
      return 'Sem Problemas.';
    } else if (tas > 0 && tas <= 0.02) {
      return 'Sentimento de alegria e leve alteração corporal.';
    } else if (tas > 0.02 && tas <= 0.05) {
      return 'Comprometimento de coordenação e menos atenção.';
    } else if (tas > 0.05 && tas <= 0.08) {
      return 'Limite para dirigir embriagado. Imparidade em coordenação.';
    } else if (tas > 0.08 && tas <= 0.10) {
      return 'Comportamento barulhento e humilhante.';
    } else if (tas > 0.10 && tas <= 0.15) {
      return 'Claramente bebado. Diminuição do equilíbrio e movimento.';
    } else if (tas > 0.15 && tas <= 0.30) {
      return 'Muitos perdem a consciência.';
    } else if (tas > 0.30 && tas <= 0.40) {
      return 'Perda de Consciência. Alguns morrem.';
    } else {
      return 'Respiração para. Muitos morrem.';
    }
  }

  static double calcularHorasParaLimite(double tas) {
    if (tas <= 0.05) return 0;
    return (tas - 0.05) / 0.015;
  }

  static String formatarTAS(double tas) {
    return _numberFormat.format(tas);
  }

  static String gerarTextoCompartilhamento(AlcoolSangueModel modelo) {
    final horasParaLimite = calcularHorasParaLimite(modelo.tas);
    final horas = horasParaLimite.floor();
    final minutos = ((horasParaLimite - horas) * 60).round();

    final tempoRecuperacao = modelo.tas > 0.05
        ? '\nTempo estimado para dirigir: ${horas}h ${minutos}min'
        : '';

    return '''
    Cálculo de Álcool no Sangue (TAS)

    Valores
    % de Álcool da Bebida: ${_numberFormat.format(modelo.alcoolPerc)} %
    Volume Consumido: ${_numberFormat.format(modelo.volume)} ml
    Tempo Passado: ${_numberFormat.format(modelo.tempo)} h
    Peso: ${_numberFormat.format(modelo.peso)} kg

    Resultado
    TAS: ${_numberFormat.format(modelo.tas)} %
    Condição: ${modelo.condicao}$tempoRecuperacao
    ''';
  }
}
