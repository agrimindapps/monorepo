class NivelDanoEconomicoModel {
  num custoProduto = 0; // R$/ha
  num eficaciaControle = 0; // %
  num danoPlanta = 0; // %
  num valorProduto = 0; // R$/unidade
  num resultado = 0; // Nível de dano econômico
  bool calculado = false;

  void limpar() {
    custoProduto = 0;
    eficaciaControle = 0;
    danoPlanta = 0;
    valorProduto = 0;
    resultado = 0;
    calculado = false;
  }

  void calcular() {
    // Cálculo do nível de dano econômico
    // Fórmula: NDE = Custo do controle / (Preço × Perda × Eficiência)
    resultado = custoProduto /
        (valorProduto * (danoPlanta / 100) * (eficaciaControle / 100));
    calculado = true;
  }

  String getNivelRisco() {
    if (!calculado) return '';
    if (resultado <= 10) {
      return 'baixo';
    } else if (resultado <= 50) {
      return 'moderado';
    } else {
      return 'alto';
    }
  }

  String getInterpretacao() {
    switch (getNivelRisco()) {
      case 'baixo':
        return 'O nível de dano econômico é baixo, indicando que uma pequena quantidade de pragas já justifica a intervenção.';
      case 'moderado':
        return 'O nível de dano econômico é moderado, considere monitorar as pragas frequentemente.';
      case 'alto':
        return 'O nível de dano econômico é alto, indicando boa tolerância econômica às pragas antes de justificar intervenção.';
      default:
        return '';
    }
  }
}
