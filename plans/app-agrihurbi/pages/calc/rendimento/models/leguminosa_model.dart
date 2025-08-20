class LeguminosaModel {
  final double vagensPorPlanta;
  final double sementesPorVagem;
  final double pesoMilGraos;
  final double plantasM2;

  // Cálculos derivados
  double get sementesPorM2 => plantasM2 * vagensPorPlanta * sementesPorVagem;
  double get pesoPorM2 => (sementesPorM2 * pesoMilGraos) / 1000;
  double get rendimento => pesoPorM2 * 10000; // Convertendo para kg/ha

  String get classificacao {
    if (rendimento < 1500) return 'Baixa produtividade';
    if (rendimento < 3000) return 'Produtividade média';
    if (rendimento < 4500) return 'Boa produtividade';
    return 'Excelente produtividade';
  }

  LeguminosaModel({
    required this.vagensPorPlanta,
    required this.sementesPorVagem,
    required this.pesoMilGraos,
    required this.plantasM2,
  });

  factory LeguminosaModel.empty() {
    return LeguminosaModel(
      vagensPorPlanta: 0,
      sementesPorVagem: 0,
      pesoMilGraos: 0,
      plantasM2: 0,
    );
  }
}
