class TempoIrrigacaoModel {
  // Parâmetros de entrada
  double laminaAplicar;
  double vazaoEmissor;
  double espacamentoEmissores;
  double espacamentoLinhas;
  double eficienciaIrrigacao;

  // Resultados calculados
  double tempoIrrigacao = 0;
  double tempoIrrigacaoMinutos = 0;
  double areaPorEmissor = 0;
  double volumePorEmissor = 0;
  double volumeTotalPorHectare = 0;

  TempoIrrigacaoModel({
    required this.laminaAplicar,
    required this.vazaoEmissor,
    required this.espacamentoEmissores,
    required this.espacamentoLinhas,
    required this.eficienciaIrrigacao,
  });

  void calcular() {
    // Cálculo da área por emissor (m²)
    areaPorEmissor = espacamentoEmissores * espacamentoLinhas;

    // Cálculo do volume por emissor (L)
    volumePorEmissor =
        (laminaAplicar * areaPorEmissor) / (eficienciaIrrigacao / 100);

    // Cálculo do tempo de irrigação (h)
    tempoIrrigacao = volumePorEmissor / vazaoEmissor;

    // Conversão para minutos
    tempoIrrigacaoMinutos = tempoIrrigacao * 60;

    // Cálculo do volume total por hectare (m³/ha)
    volumeTotalPorHectare =
        (volumePorEmissor * 10000) / (areaPorEmissor * 1000);
  }

  // Getters para valores formatados
  String get laminaAplicarFormatada => laminaAplicar.toStringAsFixed(2);
  String get tempoIrrigacaoFormatado => tempoIrrigacao.toStringAsFixed(2);
  String get tempoIrrigacaoMinutosFormatado =>
      tempoIrrigacaoMinutos.toStringAsFixed(0);
  String get areaPorEmissorFormatada => areaPorEmissor.toStringAsFixed(2);
  String get volumePorEmissorFormatado => volumePorEmissor.toStringAsFixed(2);
  String get volumeTotalPorHectareFormatado =>
      volumeTotalPorHectare.toStringAsFixed(2);
}
