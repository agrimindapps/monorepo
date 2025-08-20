class CulturaInfo {
  final String nome;
  final double kcInicial;
  final double kcMedio;
  final double kcFinal;

  CulturaInfo({
    required this.nome,
    required this.kcInicial,
    required this.kcMedio,
    required this.kcFinal,
  });

  static List<CulturaInfo> get culturasDisponiveis => [
        CulturaInfo(
          nome: 'Milho',
          kcInicial: 0.30,
          kcMedio: 1.20,
          kcFinal: 0.35,
        ),
        CulturaInfo(
          nome: 'Soja',
          kcInicial: 0.40,
          kcMedio: 1.15,
          kcFinal: 0.50,
        ),
        CulturaInfo(
          nome: 'Feijão',
          kcInicial: 0.40,
          kcMedio: 1.15,
          kcFinal: 0.35,
        ),
        CulturaInfo(
          nome: 'Arroz',
          kcInicial: 1.05,
          kcMedio: 1.20,
          kcFinal: 0.90,
        ),
        CulturaInfo(
          nome: 'Cana-de-açúcar',
          kcInicial: 0.40,
          kcMedio: 1.25,
          kcFinal: 0.75,
        ),
        CulturaInfo(
          nome: 'Algodão',
          kcInicial: 0.35,
          kcMedio: 1.20,
          kcFinal: 0.60,
        ),
        CulturaInfo(
          nome: 'Tomate',
          kcInicial: 0.60,
          kcMedio: 1.15,
          kcFinal: 0.80,
        ),
        CulturaInfo(
          nome: 'Café',
          kcInicial: 0.90,
          kcMedio: 0.95,
          kcFinal: 0.95,
        ),
        CulturaInfo(
          nome: 'Laranja',
          kcInicial: 0.70,
          kcMedio: 0.65,
          kcFinal: 0.70,
        ),
        CulturaInfo(
          nome: 'Uva',
          kcInicial: 0.30,
          kcMedio: 0.70,
          kcFinal: 0.45,
        ),
      ];
}
