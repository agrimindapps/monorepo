class JurosCompostosModel {
  final double? capitalInicial;
  final double? taxaJuros;
  final int? periodo;
  final double? aporteMensal;
  final double? montanteFinal;
  final double? totalInvestido;
  final double? totalJuros;
  final double? rendimentoTotal;

  JurosCompostosModel({
    this.capitalInicial,
    this.taxaJuros,
    this.periodo,
    this.aporteMensal,
    this.montanteFinal,
    this.totalInvestido,
    this.totalJuros,
    this.rendimentoTotal,
  });

  JurosCompostosModel copyWith({
    double? capitalInicial,
    double? taxaJuros,
    int? periodo,
    double? aporteMensal,
    double? montanteFinal,
    double? totalInvestido,
    double? totalJuros,
    double? rendimentoTotal,
  }) {
    return JurosCompostosModel(
      capitalInicial: capitalInicial ?? this.capitalInicial,
      taxaJuros: taxaJuros ?? this.taxaJuros,
      periodo: periodo ?? this.periodo,
      aporteMensal: aporteMensal ?? this.aporteMensal,
      montanteFinal: montanteFinal ?? this.montanteFinal,
      totalInvestido: totalInvestido ?? this.totalInvestido,
      totalJuros: totalJuros ?? this.totalJuros,
      rendimentoTotal: rendimentoTotal ?? this.rendimentoTotal,
    );
  }
}
