// Flutter imports:
import 'package:flutter/material.dart';

enum TipoCalculo { consumo, patinamento, patinamentoN, velocidade }

class MaquinarioModel {
  final String title;
  final TipoCalculo tipo;
  final double valor1;
  final double valor2;
  final double resultado;
  final Color cor;

  MaquinarioModel({
    required this.title,
    required this.tipo,
    this.valor1 = 0,
    this.valor2 = 0,
    this.resultado = 0,
    required this.cor,
  });

  MaquinarioModel copyWith({
    String? title,
    TipoCalculo? tipo,
    double? valor1,
    double? valor2,
    double? resultado,
    Color? cor,
  }) {
    return MaquinarioModel(
      title: title ?? this.title,
      tipo: tipo ?? this.tipo,
      valor1: valor1 ?? this.valor1,
      valor2: valor2 ?? this.valor2,
      resultado: resultado ?? this.resultado,
      cor: cor ?? this.cor,
    );
  }
}
