// Modelo de dados para cálculos de hidratação e fluidoterapia

class HidratacaoFluidoterapiaModel {
  // Dados de entrada
  final double? peso;
  final double? percentualDesidratacao;
  final double? perdaCorrente24h;
  final double? temperaturaCorporal;
  final String? especieSelecionada;
  final String? tipoSolucaoSelecionado;
  final String? viaAdministracaoSelecionada;
  final String? condicaoClinicaSelecionada;

  // Dados de cálculo
  double? volumeDesidratacao;
  double? manutencaoDiaria;
  double? perdaCorrente;
  double? volumeTotalDia;
  double? taxaInfusao;
  Map<String, double>? distribuicaoHoraria;
  Map<String, String>? recomendacoes;

  // Fatores de manutenção diária (ml/kg/dia)
  static final Map<String, double> fatoresManutencao = {
    'Cão': 60.0,
    'Gato': 50.0,
  };

  // Correções baseadas nas condições clínicas (multiplicadores)
  static final Map<String, double> correcaoCondicaoClinica = {
    'Desidratação simples': 1.0,
    'Gastroenterite': 1.2,
    'Insuficiência renal': 0.8,
    'Insuficiência cardíaca': 0.7,
    'Pancreatite': 1.1,
    'Obstrução urinária': 0.9,
    'Cetoacidose diabética': 1.2,
    'Pós-operatório': 1.0,
    'Choque': 1.3,
  };

  // Distribuição da infusão de acordo com a via
  static final Map<String, List<double>> distribuicaoPorVia = {
    'Intravenosa': [
      0.4,
      0.3,
      0.2,
      0.1
    ], // 40% nas primeiras 6h, 30% nas 6h seguintes, 20% nas próximas 6h, 10% nas últimas 6h
    'Subcutânea': [0.5, 0.5], // 50% de manhã, 50% à tarde
    'Intraóssea': [0.4, 0.3, 0.2, 0.1], // Mesma distribuição da IV
  };

  // Limitações de taxa de infusão por kg/hora por via
  static final Map<String, Map<String, double>> limiteTaxaInfusao = {
    'Cão': {
      'Intravenosa': 10.0, // ml/kg/hora
      'Subcutânea': 20.0, // ml/kg total por aplicação (não é horária)
      'Intraóssea': 5.0, // ml/kg/hora
    },
    'Gato': {
      'Intravenosa': 5.0, // ml/kg/hora
      'Subcutânea': 15.0, // ml/kg total por aplicação (não é horária)
      'Intraóssea': 4.0, // ml/kg/hora
    },
  };

  // Recomendações específicas por tipo de solução e condição clínica
  static final Map<String, Map<String, String>> recomendacoesSolucao = {
    'Solução Fisiológica (NaCl 0,9%)': {
      'geral':
          'Indicada para desidratações isotônicas. Cuidado em pacientes com insuficiência cardíaca.',
      'Insuficiência cardíaca':
          'USAR COM CAUTELA e sob monitoramento. Preferir volumes menores e infusão lenta.',
      'Insuficiência renal':
          'Pode ser usada, monitorar eletrólitos durante a terapia.',
    },
    'Ringer Lactato': {
      'geral':
          'Solução balanceada, útil para maioria dos casos de desidratação. Evitar em acidose láctica grave.',
      'Insuficiência hepática':
          'Evitar ou usar com cautela devido ao metabolismo do lactato comprometido.',
      'Cetoacidose diabética':
          'Preferir solução fisiológica nas fases iniciais.',
    },
    'Ringer Simples': {
      'geral':
          'Solução balanceada sem lactato, útil para pacientes com comprometimento hepático.',
    },
    'Glicose 5%': {
      'geral':
          'Fornece água livre. Não contém eletrólitos. Útil para hidratação em hipoglicemia, mas não em desidratação verdadeira.',
      'Hipoglicemia': 'Indicada para correção rápida da glicemia.',
      'Hipercalemia':
          'Pode auxiliar no tratamento quando associada a insulina.',
    },
    'Solução Fisiológica + Glicose 5%': {
      'geral':
          'Combinação que oferece eletrólitos e energia. Útil em animais debilitados ou não se alimentando.',
      'Hipoglicemia':
          'Boa opção para fornecer glicose enquanto corrige desidratação.',
    },
  };

  // Sinais clínicos de desidratação para referência
  static final List<Map<String, dynamic>> sinaisDesidratacao = [
    {
      'percentual': 5,
      'sinais': 'Perda de elasticidade cutânea leve, mucosas levemente secas'
    },
    {
      'percentual': 7,
      'sinais':
          'Perda de elasticidade cutânea moderada, mucosas secas, retorno capilar prolongado (>2 seg)'
    },
    {
      'percentual': 9,
      'sinais':
          'Perda acentuada de elasticidade cutânea, mucosas muito secas, olhos afundados, retorno capilar lento (>3 seg)'
    },
    {
      'percentual': 12,
      'sinais':
          'Sinais de choque, colapso circulatório, risco de morte. EMERGÊNCIA'
    },
  ];

  // Opções para os dropdowns
  static final List<String> especies = ['Cão', 'Gato'];

  static final List<String> tiposSolucao = [
    'Solução Fisiológica (NaCl 0,9%)',
    'Ringer Lactato',
    'Ringer Simples',
    'Glicose 5%',
    'Solução Fisiológica + Glicose 5%'
  ];

  static final List<String> viasAdministracao = [
    'Intravenosa',
    'Subcutânea',
    'Intraóssea'
  ];

  static final List<String> condicoesClinicas = [
    'Desidratação simples',
    'Gastroenterite',
    'Insuficiência renal',
    'Insuficiência cardíaca',
    'Pancreatite',
    'Obstrução urinária',
    'Cetoacidose diabética',
    'Pós-operatório',
    'Choque'
  ];

  HidratacaoFluidoterapiaModel({
    this.peso,
    this.percentualDesidratacao,
    this.perdaCorrente24h,
    this.temperaturaCorporal,
    this.especieSelecionada,
    this.tipoSolucaoSelecionado,
    this.viaAdministracaoSelecionada,
    this.condicaoClinicaSelecionada,
    this.volumeDesidratacao,
    this.manutencaoDiaria,
    this.perdaCorrente,
    this.volumeTotalDia,
    this.taxaInfusao,
    this.distribuicaoHoraria,
    this.recomendacoes,
  });

  // Cria uma cópia do modelo com os campos especificados alterados
  HidratacaoFluidoterapiaModel copyWith({
    double? peso,
    double? percentualDesidratacao,
    double? perdaCorrente24h,
    double? temperaturaCorporal,
    String? especieSelecionada,
    String? tipoSolucaoSelecionado,
    String? viaAdministracaoSelecionada,
    String? condicaoClinicaSelecionada,
    double? volumeDesidratacao,
    double? manutencaoDiaria,
    double? perdaCorrente,
    double? volumeTotalDia,
    double? taxaInfusao,
    Map<String, double>? distribuicaoHoraria,
    Map<String, String>? recomendacoes,
  }) {
    return HidratacaoFluidoterapiaModel(
      peso: peso ?? this.peso,
      percentualDesidratacao:
          percentualDesidratacao ?? this.percentualDesidratacao,
      perdaCorrente24h: perdaCorrente24h ?? this.perdaCorrente24h,
      temperaturaCorporal: temperaturaCorporal ?? this.temperaturaCorporal,
      especieSelecionada: especieSelecionada ?? this.especieSelecionada,
      tipoSolucaoSelecionado:
          tipoSolucaoSelecionado ?? this.tipoSolucaoSelecionado,
      viaAdministracaoSelecionada:
          viaAdministracaoSelecionada ?? this.viaAdministracaoSelecionada,
      condicaoClinicaSelecionada:
          condicaoClinicaSelecionada ?? this.condicaoClinicaSelecionada,
      volumeDesidratacao: volumeDesidratacao ?? this.volumeDesidratacao,
      manutencaoDiaria: manutencaoDiaria ?? this.manutencaoDiaria,
      perdaCorrente: perdaCorrente ?? this.perdaCorrente,
      volumeTotalDia: volumeTotalDia ?? this.volumeTotalDia,
      taxaInfusao: taxaInfusao ?? this.taxaInfusao,
      distribuicaoHoraria: distribuicaoHoraria ?? this.distribuicaoHoraria,
      recomendacoes: recomendacoes ?? this.recomendacoes,
    );
  }
}
