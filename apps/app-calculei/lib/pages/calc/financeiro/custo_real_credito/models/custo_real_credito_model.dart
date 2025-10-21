class CustoRealCreditoModel {
  double valorAVista;
  double valorParcela;
  int numeroParcelas;
  double taxaInvestimento;
  double valorTotalPago;
  double totalJurosPagos;
  double ganhoInvestimento;
  double custoRealEfetivo;

  CustoRealCreditoModel({
    this.valorAVista = 0.0,
    this.valorParcela = 0.0,
    this.numeroParcelas = 0,
    this.taxaInvestimento = 0.0,
    this.valorTotalPago = 0.0,
    this.totalJurosPagos = 0.0,
    this.ganhoInvestimento = 0.0,
    this.custoRealEfetivo = 0.0,
  });

  void calcular() {
    // Calcula o valor total pago no parcelamento
    valorTotalPago = valorParcela * numeroParcelas;

    // Calcula o total de juros pagos
    totalJurosPagos = valorTotalPago - valorAVista;

    // Calcula o ganho potencial se investisse o valor à vista
    double valorInvestido = valorAVista;

    // Simula o rendimento do investimento durante o período do parcelamento
    for (int i = 0; i < numeroParcelas; i++) {
      valorInvestido *= (1 + (taxaInvestimento / 100));
    }

    ganhoInvestimento = valorInvestido - valorAVista;

    // Calcula o custo real efetivo
    custoRealEfetivo = totalJurosPagos + ganhoInvestimento;
  }

  Map<String, dynamic> toJson() {
    return {
      'valorAVista': valorAVista,
      'valorParcela': valorParcela,
      'numeroParcelas': numeroParcelas,
      'taxaInvestimento': taxaInvestimento,
      'valorTotalPago': valorTotalPago,
      'totalJurosPagos': totalJurosPagos,
      'ganhoInvestimento': ganhoInvestimento,
      'custoRealEfetivo': custoRealEfetivo,
    };
  }

  factory CustoRealCreditoModel.fromJson(Map<String, dynamic> json) {
    return CustoRealCreditoModel(
      valorAVista: json['valorAVista'] ?? 0.0,
      valorParcela: json['valorParcela'] ?? 0.0,
      numeroParcelas: json['numeroParcelas'] ?? 0,
      taxaInvestimento: json['taxaInvestimento'] ?? 0.0,
      valorTotalPago: json['valorTotalPago'] ?? 0.0,
      totalJurosPagos: json['totalJurosPagos'] ?? 0.0,
      ganhoInvestimento: json['ganhoInvestimento'] ?? 0.0,
      custoRealEfetivo: json['custoRealEfetivo'] ?? 0.0,
    );
  }
}
