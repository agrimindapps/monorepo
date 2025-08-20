// Flutter imports:
import 'package:flutter/material.dart';

class SoloInfo {
  final String nome;
  final String descricao;
  final double capacidadeCampo;
  final double pontoMurcha;
  final double densidadeSolo;
  final Color cor;

  SoloInfo({
    required this.nome,
    required this.descricao,
    required this.capacidadeCampo,
    required this.pontoMurcha,
    required this.densidadeSolo,
    required this.cor,
  });

  static List<SoloInfo> get solosDisponiveis => [
        SoloInfo(
          nome: 'Arenoso',
          descricao:
              'Solo com partículas grandes, alta drenagem e baixa retenção de água',
          capacidadeCampo: 10.0,
          pontoMurcha: 4.0,
          densidadeSolo: 1.65,
          cor: Colors.amber.shade700,
        ),
        SoloInfo(
          nome: 'Franco-Arenoso',
          descricao:
              'Solo equilibrado com predominância de areia, boa drenagem',
          capacidadeCampo: 15.0,
          pontoMurcha: 6.0,
          densidadeSolo: 1.55,
          cor: Colors.amber.shade500,
        ),
        SoloInfo(
          nome: 'Franco',
          descricao:
              'Solo equilibrado entre areia, silte e argila, boa para maioria das culturas',
          capacidadeCampo: 22.0,
          pontoMurcha: 10.0,
          densidadeSolo: 1.40,
          cor: Colors.green.shade600,
        ),
        SoloInfo(
          nome: 'Franco-Argiloso',
          descricao:
              'Solo com maior proporção de argila, boa retenção de nutrientes',
          capacidadeCampo: 27.0,
          pontoMurcha: 13.0,
          densidadeSolo: 1.35,
          cor: Colors.brown.shade400,
        ),
        SoloInfo(
          nome: 'Argiloso',
          descricao:
              'Solo com alta proporção de argila, alta retenção de água e nutrientes',
          capacidadeCampo: 36.0,
          pontoMurcha: 17.0,
          densidadeSolo: 1.25,
          cor: Colors.brown.shade700,
        ),
        SoloInfo(
          nome: 'Muito Argiloso',
          descricao:
              'Solo predominantemente argiloso, alta retenção, pode ter drenagem limitada',
          capacidadeCampo: 40.0,
          pontoMurcha: 20.0,
          densidadeSolo: 1.20,
          cor: Colors.brown.shade900,
        ),
      ];
}
