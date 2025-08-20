class BalancoNitrogenio {
  num areaPlantio; // ha
  num produtividadeEsperada; // kg/ha
  num teorNitrogenioSolo; // kg/ha

  // Resultados
  num nitrogenioNecessario = 0; // kg
  num nitrogenioSolo = 0; // kg
  num nitrogenioFixacao = 0; // kg
  num nitrogenioAdicionar = 0; // kg

  BalancoNitrogenio({
    this.areaPlantio = 0,
    this.produtividadeEsperada = 0,
    this.teorNitrogenioSolo = 0,
  });

  void calcular() {
    // Necessidade de nitrogênio - aproximadamente 20kg de N para cada 1000kg de grãos
    nitrogenioNecessario = (produtividadeEsperada * 20) / 1000 * areaPlantio;

    // Nitrogênio já disponível no solo
    nitrogenioSolo = teorNitrogenioSolo * areaPlantio;

    // Nitrogênio obtido por fixação biológica (aproximadamente 50% para leguminosas)
    nitrogenioFixacao = nitrogenioNecessario * 0.5;

    // Nitrogênio que precisa ser adicionado
    nitrogenioAdicionar =
        nitrogenioNecessario - nitrogenioSolo - nitrogenioFixacao;

    // Se a quantidade a adicionar for negativa, não é necessário adicionar
    if (nitrogenioAdicionar < 0) {
      nitrogenioAdicionar = 0;
    }
  }

  void limpar() {
    areaPlantio = 0;
    produtividadeEsperada = 0;
    teorNitrogenioSolo = 0;
    nitrogenioNecessario = 0;
    nitrogenioSolo = 0;
    nitrogenioFixacao = 0;
    nitrogenioAdicionar = 0;
  }
}
