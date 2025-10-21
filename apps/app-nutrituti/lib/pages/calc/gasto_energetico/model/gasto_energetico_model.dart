class GastoEnergeticoModel {
  final int generoSelecionado;
  final double peso;
  final double altura;
  final int idade;
  final double tmb; // Taxa Metabólica Basal
  final double gastoTotal;
  final Map<String, double> gastosPorAtividade;

  GastoEnergeticoModel({
    required this.generoSelecionado,
    required this.peso,
    required this.altura,
    required this.idade,
    required this.tmb,
    required this.gastoTotal,
    required this.gastosPorAtividade,
  });

  factory GastoEnergeticoModel.empty() {
    return GastoEnergeticoModel(
      generoSelecionado: 1,
      peso: 0,
      altura: 0,
      idade: 0,
      tmb: 0,
      gastoTotal: 0,
      gastosPorAtividade: {
        'dormir': 0,
        'deitado': 0,
        'sentado': 0,
        'emPe': 0,
        'caminhando': 0,
        'exercicio': 0,
      },
    );
  }
}
