class SeguroDesempregoModel {
  final double salarioMedio;
  final int tempoTrabalho;
  final int vezesRecebidas;
  final DateTime dataDemissao;
  
  // Resultados calculados
  final double valorParcela;
  final int quantidadeParcelas;
  final double valorTotal;
  final DateTime prazoRequerer;
  final DateTime inicioPagamento;
  final DateTime fimPagamento;
  final List<DateTime> cronogramaPagamento;
  final bool temDireito;
  final String motivoSemDireito;
  final int mesesCarencia;
  final int mesesDesdeUltimo;
  
  SeguroDesempregoModel({
    required this.salarioMedio,
    required this.tempoTrabalho,
    required this.vezesRecebidas,
    required this.dataDemissao,
    required this.valorParcela,
    required this.quantidadeParcelas,
    required this.valorTotal,
    required this.prazoRequerer,
    required this.inicioPagamento,
    required this.fimPagamento,
    required this.cronogramaPagamento,
    required this.temDireito,
    required this.motivoSemDireito,
    required this.mesesCarencia,
    required this.mesesDesdeUltimo,
  });
}