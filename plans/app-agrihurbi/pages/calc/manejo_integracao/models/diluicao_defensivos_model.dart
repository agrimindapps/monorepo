class DiluicaoDefensivosModel {
  num doseRecomendada = 0; // L ou kg/ha
  num volumeCalda = 0; // L/ha
  num volumePulverizador = 0; // L
  num resultado = 0; // Quantidade do defensivo
  num areaAtingida = 0; // Área atingida com o pulverizador
  String unidadeSelecionada = 'L';
  static const List<String> unidades = ['L', 'mL', 'kg', 'g'];
  bool calculado = false;

  void limpar() {
    doseRecomendada = 0;
    volumeCalda = 0;
    volumePulverizador = 0;
    resultado = 0;
    areaAtingida = 0;
    calculado = false;
  }

  void calcular() {
    // Cálculo da quantidade do defensivo para o volume do pulverizador
    resultado = (doseRecomendada * volumePulverizador) / volumeCalda;

    // Cálculo da área atingida com o pulverizador
    areaAtingida = volumePulverizador / volumeCalda;

    // Converter para mL ou g se necessário
    if (unidadeSelecionada == 'mL' || unidadeSelecionada == 'g') {
      resultado *= 1000;
    }

    calculado = true;
  }

  String get unidadeOriginal => unidadeSelecionada == 'mL'
      ? 'L'
      : unidadeSelecionada == 'g'
          ? 'kg'
          : unidadeSelecionada;
}
