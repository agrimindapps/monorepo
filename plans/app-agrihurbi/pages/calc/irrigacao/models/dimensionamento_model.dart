class DimensionamentoModel {
  // Parâmetros de entrada
  double vazaoRequerida;
  double areaIrrigada;
  double espacamentoAspersores;
  double pressaoOperacao;
  double tempoDisponivel;

  // Resultados calculados
  double vazaoTotal = 0;
  int numeroAspersores = 0;
  double vazaoPorAspersor = 0;
  double tempoIrrigacaoNecessario = 0;

  DimensionamentoModel({
    required this.vazaoRequerida,
    required this.areaIrrigada,
    required this.espacamentoAspersores,
    required this.pressaoOperacao,
    required this.tempoDisponivel,
  });

  void calcular() {
    // Cálculo da vazão total requerida pelo sistema (m³/h)
    vazaoTotal = vazaoRequerida * areaIrrigada;

    // Cálculo da área coberta por cada aspersor (m²)
    final areaPorAspersor = espacamentoAspersores * espacamentoAspersores;

    // Conversão de hectares para m²
    final areaTotal = areaIrrigada * 10000;

    // Cálculo do número de aspersores necessários
    numeroAspersores = (areaTotal / areaPorAspersor).ceil();

    // Cálculo da vazão por aspersor (m³/h)
    vazaoPorAspersor = vazaoTotal / numeroAspersores;

    // Cálculo do tempo de irrigação necessário (h)
    tempoIrrigacaoNecessario = (vazaoTotal * numeroAspersores) / vazaoRequerida;
  }

  // Getters para valores formatados
  String get vazaoTotalFormatada => vazaoTotal.toStringAsFixed(2);
  String get numeroAspersoresFormatado => numeroAspersores.toString();
  String get vazaoPorAspersorsFormatada => vazaoPorAspersor.toStringAsFixed(2);
  String get tempoIrrigacaoFormatado =>
      tempoIrrigacaoNecessario.toStringAsFixed(2);
}
