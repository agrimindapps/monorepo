class GastoEnergeticoModel {
  double peso;
  double altura;
  int idade;
  int generoSelecionado;
  double tmb;
  double gastoTotal;
  Map<String, double> gastosPorAtividade;
  bool calculado;

  // Valores de MET (Metabolic Equivalent of Task) para cada atividade
  static const Map<String, double> metValues = {
    'dormir': 0.95,
    'deitado': 1.2,
    'sentado': 1.5,
    'emPe': 2.0,
    'caminhando': 3.5,
    'exercicio': 7.0,
  };

  GastoEnergeticoModel({
    this.peso = 0,
    this.altura = 0,
    this.idade = 0,
    this.generoSelecionado = 1,
    this.tmb = 0,
    this.gastoTotal = 0,
    Map<String, double>? gastosPorAtividade,
    this.calculado = false,
  }) : gastosPorAtividade = gastosPorAtividade ?? {};

  // Método para limpar os dados
  void limpar() {
    peso = 0;
    altura = 0;
    idade = 0;
    generoSelecionado = 1;
    tmb = 0;
    gastoTotal = 0;
    gastosPorAtividade.clear();
    calculado = false;
  }

  // Método para calcular a TMB
  void calcularTMB() {
    if (generoSelecionado == 1) {
      // Masculino
      tmb = 88.362 + (13.397 * peso) + (4.799 * altura) - (5.677 * idade);
    } else {
      // Feminino
      tmb = 447.593 + (9.247 * peso) + (3.098 * altura) - (4.330 * idade);
    }
    tmb = double.parse(tmb.toStringAsFixed(0));
  }

  // Método para calcular o gasto por atividade
  void calcularGastoAtividade(String nome, String atividade, double horas) {
    if (horas <= 0) return;

    double met = metValues[atividade] ?? 1.0;
    double tmbPorHora = tmb / 24;
    double gasto = tmbPorHora * met * horas;

    gastosPorAtividade[nome] = double.parse(gasto.toStringAsFixed(0));
    gastoTotal += gasto;
  }
}
