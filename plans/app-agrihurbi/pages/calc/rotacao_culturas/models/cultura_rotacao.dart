// Flutter imports:
import 'package:flutter/material.dart';

class CulturaRotacao {
  final String nome;
  final Color cor;
  final IconData icon;
  double percentualArea;
  num areaCultura;

  CulturaRotacao({
    required this.nome,
    required this.cor,
    required this.percentualArea,
    this.areaCultura = 0,
    required this.icon,
  });

  static List<CulturaRotacao> getDefaultCulturas() {
    return [
      CulturaRotacao(
        nome: 'Soja',
        cor: Colors.green.shade600,
        percentualArea: 40,
        areaCultura: 0,
        icon: Icons.grass,
      ),
      CulturaRotacao(
        nome: 'Milho',
        cor: Colors.amber.shade600,
        percentualArea: 30,
        areaCultura: 0,
        icon: Icons.grass,
      ),
      CulturaRotacao(
        nome: 'Trigo',
        cor: Colors.brown.shade400,
        percentualArea: 15,
        areaCultura: 0,
        icon: Icons.agriculture,
      ),
      CulturaRotacao(
        nome: 'Aveia',
        cor: Colors.orange.shade600,
        percentualArea: 15,
        areaCultura: 0,
        icon: Icons.agriculture,
      ),
    ];
  }
}
