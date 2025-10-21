class DecimoTerceiroModel {
  final double salarioBruto;
  final int mesesTrabalhados;
  final DateTime dataAdmissao;
  final DateTime dataCalculo;
  final int faltasNaoJustificadas;
  final bool antecipacao;
  
  // Resultados calculados
  final double decimoTerceiroBruto;
  final double descontoInss;
  final double descontoIrrf;
  final double decimoTerceiroLiquido;
  final double primeiraParcela;
  final double segundaParcela;
  final double aliquotaInss;
  final double aliquotaIrrf;
  final double baseCalculoIrrf;
  final int mesesConsiderados;
  final double valorPorMes;
  
  DecimoTerceiroModel({
    required this.salarioBruto,
    required this.mesesTrabalhados,
    required this.dataAdmissao,
    required this.dataCalculo,
    required this.faltasNaoJustificadas,
    required this.antecipacao,
    required this.decimoTerceiroBruto,
    required this.descontoInss,
    required this.descontoIrrf,
    required this.decimoTerceiroLiquido,
    required this.primeiraParcela,
    required this.segundaParcela,
    required this.aliquotaInss,
    required this.aliquotaIrrf,
    required this.baseCalculoIrrf,
    required this.mesesConsiderados,
    required this.valorPorMes,
  });
}