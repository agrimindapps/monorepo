class EvapotranspiracaoModel {
  // Parâmetros de entrada
  double evapotranspiracaoReferencia;
  double coeficienteCultura;
  double coeficienteEstresse;

  // Resultados calculados
  double evapotranspiracaoCultura = 0;

  EvapotranspiracaoModel({
    required this.evapotranspiracaoReferencia,
    required this.coeficienteCultura,
    required this.coeficienteEstresse,
  });

  void calcular() {
    // ETc = ETo * Kc * Ks
    evapotranspiracaoCultura =
        evapotranspiracaoReferencia * coeficienteCultura * coeficienteEstresse;
  }

  // Reiniciar o modelo com valores padrão
  void reset() {
    evapotranspiracaoReferencia = 0;
    coeficienteCultura = 0;
    coeficienteEstresse = 1.0;
    evapotranspiracaoCultura = 0;
  }
}
