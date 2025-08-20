
class PrevisaoSimplesModel {
  final double areaPlantada;
  final double custoPrevistoHectare;
  final double sacasPrevistas;
  final double valorSaca;

  // Calculated values
  double get custoPorSaca => custoPrevistoHectare / sacasPrevistas;
  double get lucroPorSaca => valorSaca - custoPorSaca;
  double get custoPorHa => custoPrevistoHectare;
  double get lucroPorHa => (sacasPrevistas * valorSaca) - custoPrevistoHectare;
  double get sacasGastasPorHa => custoPrevistoHectare / valorSaca;
  double get custoTotal => areaPlantada * custoPrevistoHectare;
  double get lucroTotal =>
      areaPlantada * ((sacasPrevistas * valorSaca) - custoPrevistoHectare);
  double get saldoGeral => lucroTotal;

  PrevisaoSimplesModel({
    required this.areaPlantada,
    required this.custoPrevistoHectare,
    required this.sacasPrevistas,
    required this.valorSaca,
  });

  factory PrevisaoSimplesModel.empty() {
    return PrevisaoSimplesModel(
      areaPlantada: 0,
      custoPrevistoHectare: 0,
      sacasPrevistas: 0,
      valorSaca: 0,
    );
  }
}
