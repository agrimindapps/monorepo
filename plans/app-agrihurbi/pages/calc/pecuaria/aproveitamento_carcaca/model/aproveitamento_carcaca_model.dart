// Flutter imports:
import 'package:flutter/material.dart';

class AproveitamentoCarcacaModel {
  final num pesoVivo;
  final num pesoCarcaca;
  late final num resultado;

  AproveitamentoCarcacaModel({
    required this.pesoVivo,
    required this.pesoCarcaca,
  }) {
    calcularRendimento();
  }

  void calcularRendimento() {
    resultado = (pesoCarcaca / pesoVivo) * 100;
  }

  String getAvaliacao() {
    if (resultado < 50) {
      return 'Baixo rendimento';
    } else if (resultado < 55) {
      return 'Rendimento médio';
    } else if (resultado < 60) {
      return 'Bom rendimento';
    } else {
      return 'Excelente rendimento';
    }
  }

  String getDescricaoAvaliacao() {
    if (resultado < 50) {
      return 'O rendimento está abaixo do esperado. Verifique a raça, manejo e alimentação.';
    } else if (resultado < 55) {
      return 'Rendimento dentro do esperado para bovinos em sistema tradicional.';
    } else if (resultado < 60) {
      return 'Bom rendimento, indicando boa eficiência produtiva.';
    } else {
      return 'Excelente rendimento, demonstrando alta eficiência na produção.';
    }
  }

  IconData getIcone() {
    if (resultado < 50) {
      return Icons.trending_down;
    } else if (resultado < 55) {
      return Icons.trending_flat;
    } else if (resultado < 60) {
      return Icons.trending_up;
    } else {
      return Icons.stars;
    }
  }

  Color getCor(bool isDark) {
    if (resultado < 50) {
      return isDark ? Colors.red.shade300 : Colors.red;
    } else if (resultado < 55) {
      return isDark ? Colors.orange.shade300 : Colors.orange;
    } else if (resultado < 60) {
      return isDark ? Colors.green.shade300 : Colors.green.shade600;
    } else {
      return isDark ? Colors.green.shade300 : Colors.green;
    }
  }
}
