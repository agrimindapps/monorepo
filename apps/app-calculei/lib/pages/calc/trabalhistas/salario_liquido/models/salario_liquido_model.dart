class SalarioLiquidoModel {
  final double salarioBruto;
  final int dependentes;
  final double valeTransporte;
  final double planoSaude;
  final double outrosDescontos;
  
  // Resultados calculados
  final double descontoInss;
  final double descontoIrrf;
  final double descontoValeTransporte;
  final double totalDescontos;
  final double salarioLiquido;
  final double aliquotaInss;
  final double aliquotaIrrf;
  final double baseCalculoIrrf;
  
  SalarioLiquidoModel({
    required this.salarioBruto,
    required this.dependentes,
    required this.valeTransporte,
    required this.planoSaude,
    required this.outrosDescontos,
    required this.descontoInss,
    required this.descontoIrrf,
    required this.descontoValeTransporte,
    required this.totalDescontos,
    required this.salarioLiquido,
    required this.aliquotaInss,
    required this.aliquotaIrrf,
    required this.baseCalculoIrrf,
  });
}