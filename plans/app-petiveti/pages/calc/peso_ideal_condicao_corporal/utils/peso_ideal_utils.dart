// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../model/peso_ideal_model.dart';

/// Classe de utilitários para os cálculos de peso ideal e condição corporal
class PesoIdealUtils {
  /// Valida um número de ponto flutuante
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (double.tryParse(value) == null) {
      return 'Digite um número válido';
    }
    if (double.parse(value) <= 0) {
      return 'O peso deve ser maior que zero';
    }
    return null;
  }

  /// Calcula o peso ideal com base nos dados fornecidos
  static void calcular(BuildContext context, PesoIdealModel model,
      GlobalKey<FormState> formKey, String pesoAtualText) {
    if (!formKey.currentState!.validate()) return;

    model.pesoAtual = double.parse(pesoAtualText);

    if (model.escalaECCSelecionada != null) {
      final fatorConversao =
          model.fatoresConversaoECC[model.escalaECCSelecionada] ?? 1.0;
      model.pesoIdeal = model.pesoAtual! * fatorConversao;

      if (model.racaSelecionada != null && model.sexoSelecionado != null) {
        final pesoReferencia = model.pesoIdealPorRaca[model.especieSelecionada]
                ?[model.sexoSelecionado]?[model.racaSelecionada] ??
            0.0;

        if (pesoReferencia > 0) {
          if ((model.pesoIdeal! / pesoReferencia < 0.7) ||
              (model.pesoIdeal! / pesoReferencia > 1.3)) {
            model.pesoIdeal = (model.pesoIdeal! + pesoReferencia) / 2;
          }
        }
      }

      model.pesoIdeal = double.parse(model.pesoIdeal!.toStringAsFixed(1));
      model.diferencaPeso = model.pesoIdeal! - model.pesoAtual!;

      final pesoMetabolico = model.calcularPesoMetabolico(model.pesoIdeal!);
      double kcalBase = pesoMetabolico *
          (model.kcalPorKgPesoMetabolico[model.especieSelecionada] ?? 0.0);

      double fatorAtividade = 1.0;
      double fatorIdade = 1.0;
      double fatorEsterilizacao = model.esterilizado ? 0.8 : 1.0;

      if (model.idadeAnos != null) {
        if (model.idadeAnos! < 1) {
          fatorIdade = 1.8;
        } else if (model.idadeAnos! >= 7) {
          fatorIdade = model.especieSelecionada == 'Cão'
              ? math.max(0.8, 1.0 - ((model.idadeAnos! - 7) * 0.02))
              : math.max(0.8, 1.0 - ((model.idadeAnos! - 7) * 0.01));
        }
      }

      model.kcalAjustadas =
          kcalBase * fatorAtividade * fatorIdade * fatorEsterilizacao;

      if (model.diferencaPeso!.abs() > 0.1) {
        if (model.diferencaPeso! < 0) {
          model.kcalAjustadas = model.kcalAjustadas! * 0.8;
          model.tempoEstimadoSemanas =
              (model.diferencaPeso!.abs() / 0.5 * 4).ceil();
        } else {
          model.kcalAjustadas = model.kcalAjustadas! * 1.2;
          model.tempoEstimadoSemanas =
              (model.diferencaPeso!.abs() / 0.25 * 4).ceil();
        }
      } else {
        model.tempoEstimadoSemanas = 0;
      }

      model.kcalAjustadas =
          double.parse(model.kcalAjustadas!.toStringAsFixed(0));
    }
  }

  /// Gera recomendações com base na diferença de peso
  static String gerarRecomendacoes(PesoIdealModel model) {
    if (model.diferencaPeso == null) return '';

    if (model.diferencaPeso! < -0.5) {
      return '• Ofereça uma dieta com baixo teor calórico e alta saciedade.\n'
          '• Divida a alimentação em pequenas porções ao longo do dia.\n'
          '• Aumente gradualmente a atividade física de acordo com a condição do animal.\n'
          '• Evite petiscos calóricos, substitua por vegetais como cenoura ou abobrinha.\n'
          '• Monitore o peso semanalmente.';
    } else if (model.diferencaPeso! > 0.5) {
      return '• Ofereça alimentos com maior densidade calórica.\n'
          '• Aumente a frequência de alimentação para 3-4 vezes ao dia.\n'
          '• Considere suplementar a dieta com alimentos de alta qualidade.\n'
          '• Monitore o peso semanalmente.\n'
          '• Consulte o veterinário para descartar problemas médicos.';
    } else {
      return '• Mantenha o plano alimentar atual, pois o peso está próximo do ideal.\n'
          '• Ofereça exercícios regulares para manter o tônus muscular.\n'
          '• Monitore o peso mensalmente para detectar variações importantes.';
    }
  }
}
