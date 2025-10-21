class HorasExtrasModel {
  final double salarioBruto;
  final int horasSemanais;
  final double horas50;
  final double horas100;
  final double horasNoturnas;
  final double percentualNoturno;
  final double horasDomingoFeriado;
  final int dependentes;
  final int diasUteis;
  
  // Resultados calculados
  final double valorHoraNormal;
  final double valorHora50;
  final double valorHora100;
  final double valorHoraNoturna;
  final double valorHoraDomingoFeriado;
  final double totalHoras50;
  final double totalHoras100;
  final double totalAdicionalNoturno;
  final double totalDomingoFeriado;
  final double dsrSobreExtras;
  final double totalHorasExtras;
  final double reflexoFerias;
  final double reflexoDecimoTerceiro;
  final double totalBruto;
  final double descontoInss;
  final double descontoIrrf;
  final double totalLiquido;
  final double aliquotaInss;
  final double aliquotaIrrf;
  final double horasTrabalhadasMes;
  final double horasExtrasMes;
  
  HorasExtrasModel({
    required this.salarioBruto,
    required this.horasSemanais,
    required this.horas50,
    required this.horas100,
    required this.horasNoturnas,
    required this.percentualNoturno,
    required this.horasDomingoFeriado,
    required this.dependentes,
    required this.diasUteis,
    required this.valorHoraNormal,
    required this.valorHora50,
    required this.valorHora100,
    required this.valorHoraNoturna,
    required this.valorHoraDomingoFeriado,
    required this.totalHoras50,
    required this.totalHoras100,
    required this.totalAdicionalNoturno,
    required this.totalDomingoFeriado,
    required this.dsrSobreExtras,
    required this.totalHorasExtras,
    required this.reflexoFerias,
    required this.reflexoDecimoTerceiro,
    required this.totalBruto,
    required this.descontoInss,
    required this.descontoIrrf,
    required this.totalLiquido,
    required this.aliquotaInss,
    required this.aliquotaIrrf,
    required this.horasTrabalhadasMes,
    required this.horasExtrasMes,
  });
}