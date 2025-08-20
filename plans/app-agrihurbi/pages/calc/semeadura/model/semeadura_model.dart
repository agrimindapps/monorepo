class SemeaduraInputModel {
  num areaPlantada;
  num espacamentoLinha;
  num espacamentoPlanta;
  num poderGerminacao;
  num pesoMilSementes;

  SemeaduraInputModel({
    this.areaPlantada = 0,
    this.espacamentoLinha = 0,
    this.espacamentoPlanta = 0,
    this.poderGerminacao = 0,
    this.pesoMilSementes = 0,
  });

  void clear() {
    areaPlantada = 0;
    espacamentoLinha = 0;
    espacamentoPlanta = 0;
    poderGerminacao = 0;
    pesoMilSementes = 0;
  }
}

class SemeaduraResultModel {
  final num sementesM2;
  final num sementesHa;
  final num sementesTotal;
  final num kgSementesHa;
  final num kgSementesTotal;

  SemeaduraResultModel({
    this.sementesM2 = 0,
    this.sementesHa = 0,
    this.sementesTotal = 0,
    this.kgSementesHa = 0,
    this.kgSementesTotal = 0,
  });

  factory SemeaduraResultModel.calculate(SemeaduraInputModel input) {
    // Cálculo de sementes por m²
    final sementesM2 =
        10000 / (input.espacamentoLinha * input.espacamentoPlanta);

    // Cálculo de sementes por hectare (considerando o poder de germinação)
    final sementesHa = sementesM2 * 10000 * (100 / input.poderGerminacao);

    // Cálculo de sementes total
    final sementesTotal = sementesHa * input.areaPlantada;

    // Cálculo de kg de sementes por hectare
    final kgSementesHa = (sementesHa * input.pesoMilSementes) / 1000000;

    // Cálculo de kg de sementes total
    final kgSementesTotal = kgSementesHa * input.areaPlantada;

    return SemeaduraResultModel(
      sementesM2: sementesM2,
      sementesHa: sementesHa,
      sementesTotal: sementesTotal,
      kgSementesHa: kgSementesHa,
      kgSementesTotal: kgSementesTotal,
    );
  }
}
