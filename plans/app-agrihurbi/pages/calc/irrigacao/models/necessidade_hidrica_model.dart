class NecessidadeHidricaModel {
  // Parâmetros de entrada
  double evapotranspiracao;
  double coeficienteCultura;
  double areaPlantada;
  double eficienciaIrrigacao;

  // Resultados calculados
  double necessidadeBruta = 0;
  double volumeTotalDiario = 0;

  NecessidadeHidricaModel({
    required this.evapotranspiracao,
    required this.coeficienteCultura,
    required this.areaPlantada,
    required this.eficienciaIrrigacao,
  });

  void calcular() {
    // Calcula a necessidade bruta de irrigação (mm/dia)
    necessidadeBruta =
        evapotranspiracao * coeficienteCultura / (eficienciaIrrigacao / 100);

    // Calcula o volume total diário (m³/dia)
    // 1 mm = 1 L/m² = 10 m³/ha
    volumeTotalDiario = necessidadeBruta * areaPlantada * 10;
  }

  // Getters para valores formatados
  String get necessidadeBrutaFormatada => necessidadeBruta.toStringAsFixed(2);
  String get volumeTotalDiarioFormatado => volumeTotalDiario.toStringAsFixed(2);
}
