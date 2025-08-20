// Flutter imports:
import 'package:flutter/material.dart';

class LoteamentoBovinoModel {
  final num quantidadeAnimais;
  final num pesoMedio;
  final num areaHectares;
  late final num resultado;

  static const double unidadeAnimal = 450.0; // 1 UA = 450kg

  LoteamentoBovinoModel({
    required this.quantidadeAnimais,
    required this.pesoMedio,
    required this.areaHectares,
  }) {
    calcularCapacidadeSuporte();
  }

  void calcularCapacidadeSuporte() {
    final pesoTotalRebanho = quantidadeAnimais * pesoMedio;
    final unidadesAnimais = pesoTotalRebanho / unidadeAnimal;
    resultado = unidadesAnimais / areaHectares;
  }

  String getAvaliacao() {
    if (resultado < 1) {
      return 'Baixa capacidade de suporte';
    } else if (resultado < 3) {
      return 'Capacidade de suporte moderada';
    } else {
      return 'Alta capacidade de suporte';
    }
  }

  String getDescricaoAvaliacao() {
    if (resultado < 1) {
      return 'Considere melhorar as pastagens ou reduzir o número de animais.';
    } else if (resultado < 3) {
      return 'Sistema extensivo ou semi-intensivo típico com boa utilização da área.';
    } else {
      return 'Sistema intensivo de produção com elevada eficiência no uso da terra.';
    }
  }

  IconData getIcone() {
    if (resultado < 1) {
      return Icons.trending_down;
    } else if (resultado < 3) {
      return Icons.trending_flat;
    } else {
      return Icons.trending_up;
    }
  }

  Color getCor(bool isDark) {
    if (resultado < 1) {
      return isDark ? Colors.red.shade300 : Colors.red;
    } else if (resultado < 3) {
      return isDark ? Colors.amber.shade300 : Colors.amber;
    } else {
      return isDark ? Colors.green.shade300 : Colors.green;
    }
  }
}
