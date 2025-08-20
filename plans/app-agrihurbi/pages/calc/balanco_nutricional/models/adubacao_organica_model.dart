class AdubacaoOrganicaModel {
  double quantidadeAdubo = 0;
  double teorNitrogenio = 0;
  double teorFosforo = 0;
  double teorPotassio = 0;
  double areaTratada = 0;
  double materiaSecaAdubo = 0;
  String unidadeAdubo = 't/ha';
  int fonteOrganicaSelecionada = 0;

  // Resultados
  double quantidadeN = 0;
  double quantidadeP2O5 = 0;
  double quantidadeK2O = 0;
  double quantidadeNPorHectare = 0;
  double quantidadeP2O5PorHectare = 0;
  double quantidadeK2OPorHectare = 0;

  // Valores de referência para diferentes fontes de adubos orgânicos
  static final List<Map<String, dynamic>> fontesOrganicas = [
    {
      'nome': 'Personalizado',
      'N': 0,
      'P2O5': 0,
      'K2O': 0,
      'MS': 0,
    },
    {
      'nome': 'Esterco Bovino',
      'N': 1.7,
      'P2O5': 0.9,
      'K2O': 1.4,
      'MS': 40,
    },
    {
      'nome': 'Esterco de Aves',
      'N': 3.0,
      'P2O5': 3.0,
      'K2O': 2.0,
      'MS': 70,
    },
    {
      'nome': 'Esterco Suíno',
      'N': 2.8,
      'P2O5': 2.4,
      'K2O': 1.5,
      'MS': 35,
    },
    {
      'nome': 'Composto Orgânico',
      'N': 1.4,
      'P2O5': 1.0,
      'K2O': 0.8,
      'MS': 45,
    },
    {
      'nome': 'Vermicomposto',
      'N': 1.5,
      'P2O5': 1.3,
      'K2O': 1.3,
      'MS': 50,
    },
  ];

  void calcular() {
    // Fator para converter t/ha para kg/ha, se necessário
    final fatorConversao = unidadeAdubo == 't/ha' ? 1000 : 1;

    // Cálculo da quantidade de nutrientes em kg
    // A fórmula considera: Quantidade (kg/ha) * Teor (%) * Matéria Seca (%) / 100
    final quantidadeAduboPorArea = quantidadeAdubo * fatorConversao;
    final fatorMateriaSeca = materiaSecaAdubo / 100;

    // Calcula a quantidade de nutrientes por hectare
    quantidadeNPorHectare =
        quantidadeAduboPorArea * (teorNitrogenio / 100) * fatorMateriaSeca;
    quantidadeP2O5PorHectare =
        quantidadeAduboPorArea * (teorFosforo / 100) * fatorMateriaSeca;
    quantidadeK2OPorHectare =
        quantidadeAduboPorArea * (teorPotassio / 100) * fatorMateriaSeca;

    // Calcula a quantidade total de nutrientes
    quantidadeN = quantidadeNPorHectare * areaTratada;
    quantidadeP2O5 = quantidadeP2O5PorHectare * areaTratada;
    quantidadeK2O = quantidadeK2OPorHectare * areaTratada;
  }

  void limpar() {
    quantidadeAdubo = 0;
    teorNitrogenio = 0;
    teorFosforo = 0;
    teorPotassio = 0;
    areaTratada = 0;
    materiaSecaAdubo = 0;
    quantidadeN = 0;
    quantidadeP2O5 = 0;
    quantidadeK2O = 0;
    quantidadeNPorHectare = 0;
    quantidadeP2O5PorHectare = 0;
    quantidadeK2OPorHectare = 0;
  }

  String gerarTextoCompartilhamento() {
    return '''
    Cálculo de Adubação Orgânica
    
    Dados:
    Quantidade de adubo: $quantidadeAdubo $unidadeAdubo
    Teor de nitrogênio: $teorNitrogenio%
    Teor de fósforo: $teorFosforo% P2O5
    Teor de potássio: $teorPotassio% K2O
    Área tratada: $areaTratada ha
    Matéria seca: $materiaSecaAdubo%
    
    Resultados por hectare:
    Nitrogênio: $quantidadeNPorHectare kg/ha
    Fósforo (P2O5): $quantidadeP2O5PorHectare kg/ha
    Potássio (K2O): $quantidadeK2OPorHectare kg/ha
    
    Quantidade total:
    Nitrogênio: $quantidadeN kg
    Fósforo (P2O5): $quantidadeP2O5 kg
    Potássio (K2O): $quantidadeK2O kg
    ''';
  }
}
