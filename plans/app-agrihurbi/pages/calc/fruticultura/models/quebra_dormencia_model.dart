class QuebraDormenciaModel {
  num horasFrio;
  String especie;
  String variedade;
  num areaPomar;
  num numeroArvores;
  num idadePomar;
  num deficitHorasFrio;
  String recomendacaoPrincipal;
  Map<String, String> dosagensProdutos;
  num custoEstimadoPorHectare;
  num custoTotal;
  bool calculado;

  QuebraDormenciaModel({
    this.horasFrio = 0,
    this.especie = 'Maçã',
    this.variedade = 'Gala',
    this.areaPomar = 0,
    this.numeroArvores = 0,
    this.idadePomar = 0,
    this.deficitHorasFrio = 0,
    this.recomendacaoPrincipal = '',
    this.dosagensProdutos = const {},
    this.custoEstimadoPorHectare = 0,
    this.custoTotal = 0,
    this.calculado = false,
  });

  QuebraDormenciaModel copyWith({
    num? horasFrio,
    String? especie,
    String? variedade,
    num? areaPomar,
    num? numeroArvores,
    num? idadePomar,
    num? deficitHorasFrio,
    String? recomendacaoPrincipal,
    Map<String, String>? dosagensProdutos,
    num? custoEstimadoPorHectare,
    num? custoTotal,
    bool? calculado,
  }) {
    return QuebraDormenciaModel(
      horasFrio: horasFrio ?? this.horasFrio,
      especie: especie ?? this.especie,
      variedade: variedade ?? this.variedade,
      areaPomar: areaPomar ?? this.areaPomar,
      numeroArvores: numeroArvores ?? this.numeroArvores,
      idadePomar: idadePomar ?? this.idadePomar,
      deficitHorasFrio: deficitHorasFrio ?? this.deficitHorasFrio,
      recomendacaoPrincipal:
          recomendacaoPrincipal ?? this.recomendacaoPrincipal,
      dosagensProdutos: dosagensProdutos ?? this.dosagensProdutos,
      custoEstimadoPorHectare:
          custoEstimadoPorHectare ?? this.custoEstimadoPorHectare,
      custoTotal: custoTotal ?? this.custoTotal,
      calculado: calculado ?? this.calculado,
    );
  }
}
