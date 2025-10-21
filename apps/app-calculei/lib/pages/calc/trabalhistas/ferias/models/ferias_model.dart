class FeriasModel {
  final double salarioBruto;
  final DateTime inicioAquisitivo;
  final DateTime fimAquisitivo;
  final int diasFerias;
  final int faltasNaoJustificadas;
  final bool abonoPecuniario;
  final int dependentes;
  
  // Resultados calculados
  final double feriasProporcionais;
  final double abonoPecuniarioValor;
  final double abonoConstitucional;
  final double feriasBruto;
  final double descontoInss;
  final double descontoIrrf;
  final double feriasLiquido;
  final double aliquotaInss;
  final double aliquotaIrrf;
  final double baseCalculoIrrf;
  final int diasDireito;
  final int diasVendidos;
  final int diasGozados;
  final int mesesAquisitivos;
  final double valorDia;
  
  FeriasModel({
    required this.salarioBruto,
    required this.inicioAquisitivo,
    required this.fimAquisitivo,
    required this.diasFerias,
    required this.faltasNaoJustificadas,
    required this.abonoPecuniario,
    required this.dependentes,
    required this.feriasProporcionais,
    required this.abonoPecuniarioValor,
    required this.abonoConstitucional,
    required this.feriasBruto,
    required this.descontoInss,
    required this.descontoIrrf,
    required this.feriasLiquido,
    required this.aliquotaInss,
    required this.aliquotaIrrf,
    required this.baseCalculoIrrf,
    required this.diasDireito,
    required this.diasVendidos,
    required this.diasGozados,
    required this.mesesAquisitivos,
    required this.valorDia,
  });
}