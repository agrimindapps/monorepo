
class GestacaoPartoModel {
  // Controllers para input
  DateTime? dataAcasalamento;
  DateTime? dataUltrassom;
  double? tamanhoFetos;
  String? especieSelecionada;
  String? racaSelecionada;
  String? metodoCalculo;

  // Resultados
  DateTime? dataParto;
  List<String>? fasesPrenhez;
  String? fasePrenhezAtual;
  bool showInfoCard;

  // Opções para os dropdowns
  final List<String> especies = ['Cão', 'Gato', 'Coelho', 'Hamster'];
  final List<String> opcoesTipoCalculo = [
    'Data de acasalamento',
    'Ultrassom (apenas para cães e gatos)'
  ];

  // Duração média da gestação em dias por espécie
  final Map<String, int> diasGestacao = {
    'Cão': 63,
    'Gato': 65,
    'Coelho': 31,
    'Hamster': 18,
  };

  // Variação possível na duração da gestação (em dias) por espécie
  final Map<String, List<int>> variacaoGestacao = {
    'Cão': [58, 68],
    'Gato': [61, 72],
    'Coelho': [29, 35],
    'Hamster': [16, 20],
  };

  // Ajuste de raças
  final Map<String, Map<String, int>> ajusteRacasDias = {
    'Cão': {
      'Chihuahua': -2,
      'Yorkshire': -1,
      'Bulldog': 1,
      'São Bernardo': 3,
      'Pastor Alemão': 0,
      'Labrador': 0,
      'Poodle': -1,
      'Rottweiler': 1,
      'Dachshund': -1,
      'Pinscher': -2,
      'Outras raças': 0,
    },
    'Gato': {
      'Siamês': -1,
      'Persa': 2,
      'Maine Coon': 1,
      'Ragdoll': 1,
      'Sphynx': 0,
      'Bengal': 0,
      'British Shorthair': 1,
      'Munchkin': -1,
      'Outras raças': 0,
    },
    'Coelho': {'Todas as raças': 0},
    'Hamster': {'Todas as raças': 0},
  };

  // Fases da gestação para cada espécie
  final Map<String, List<Map<String, dynamic>>> fasesGestacao = {
    'Cão': [
      {
        'inicio': 0,
        'fim': 21,
        'descricao':
            'Primeira fase: Fertilização e implantação dos embriões. Fetos não visíveis em ultrassom.'
      },
      {
        'inicio': 22,
        'fim': 42,
        'descricao':
            'Segunda fase: Desenvolvimento fetal inicial. Fetos visíveis em ultrassom por volta do dia 25-30. Batimentos cardíacos detectáveis.'
      },
      {
        'inicio': 43,
        'fim': 58,
        'descricao':
            'Terceira fase: Desenvolvimento fetal avançado. Fetos crescem rapidamente, mamas da cadela aumentam, ganho de peso visível.'
      },
      {
        'inicio': 59,
        'fim': 63,
        'descricao':
            'Quarta fase: Preparação para o parto. Temperatura corporal cai 24h antes do parto. A cadela pode ficar inquieta e começar a preparar "ninho".'
      },
    ],
    'Gato': [
      {
        'inicio': 0,
        'fim': 15,
        'descricao':
            'Primeira fase: Fertilização e implantação. Não há sinais externos visíveis.'
      },
      {
        'inicio': 16,
        'fim': 35,
        'descricao':
            'Segunda fase: Desenvolvimento embrionário. Pequeno inchaço abdominal, mamilos mais rosados. Fetos visíveis em ultrassom após dia 20.'
      },
      {
        'inicio': 36,
        'fim': 57,
        'descricao':
            'Terceira fase: Desenvolvimento fetal. Abdômen visivelmente inchado, movimentos fetais podem ser sentidos.'
      },
      {
        'inicio': 58,
        'fim': 65,
        'descricao':
            'Quarta fase: Pré-parto. Gata procura local para o parto, pode ficar mais carinhosa ou mais agressiva, produção de leite começa.'
      },
    ],
    'Coelho': [
      {
        'inicio': 0,
        'fim': 8,
        'descricao':
            'Primeira fase: Implantação. Não há sinais externos visíveis.'
      },
      {
        'inicio': 9,
        'fim': 21,
        'descricao':
            'Segunda fase: Desenvolvimento. Aumento do abdômen, comportamento de nidificação pode começar.'
      },
      {
        'inicio': 22,
        'fim': 31,
        'descricao':
            'Terceira fase: Preparação para o parto. Coelha arranca pelo para fazer ninho, comportamento mais protetor.'
      },
    ],
    'Hamster': [
      {
        'inicio': 0,
        'fim': 10,
        'descricao':
            'Primeira fase: Desenvolvimento inicial. Pequeno aumento abdominal.'
      },
      {
        'inicio': 11,
        'fim': 18,
        'descricao':
            'Segunda fase: Preparação para o parto. Abdômen visível, comportamento mais recluso.'
      },
    ],
  };

  // Estimativa de idade baseada no tamanho dos fetos
  final List<Map<String, dynamic>> estimativaIdadePeloTamanho = [
    {'tamanho': 10, 'dias': 30},
    {'tamanho': 15, 'dias': 35},
    {'tamanho': 20, 'dias': 40},
    {'tamanho': 30, 'dias': 45},
    {'tamanho': 45, 'dias': 50},
    {'tamanho': 60, 'dias': 55},
    {'tamanho': 90, 'dias': 60},
  ];

  GestacaoPartoModel({
    this.showInfoCard = true,
    this.metodoCalculo,
  });

  // Factory constructor para criar uma instância inicial
  factory GestacaoPartoModel.initial() {
    return GestacaoPartoModel(
      showInfoCard: true,
      metodoCalculo: 'Data de acasalamento',
    );
  }

  // Método para criar uma cópia do modelo com novos valores
  GestacaoPartoModel copyWith({
    DateTime? dataAcasalamento,
    DateTime? dataUltrassom,
    double? tamanhoFetos,
    String? especieSelecionada,
    String? racaSelecionada,
    String? metodoCalculo,
    DateTime? dataParto,
    List<String>? fasesPrenhez,
    String? fasePrenhezAtual,
    bool? showInfoCard,
  }) {
    return GestacaoPartoModel(
      showInfoCard: showInfoCard ?? this.showInfoCard,
      metodoCalculo: metodoCalculo ?? this.metodoCalculo,
    )
      ..dataAcasalamento = dataAcasalamento ?? this.dataAcasalamento
      ..dataUltrassom = dataUltrassom ?? this.dataUltrassom
      ..tamanhoFetos = tamanhoFetos ?? this.tamanhoFetos
      ..especieSelecionada = especieSelecionada ?? this.especieSelecionada
      ..racaSelecionada = racaSelecionada ?? this.racaSelecionada
      ..dataParto = dataParto ?? this.dataParto
      ..fasesPrenhez = fasesPrenhez ?? this.fasesPrenhez
      ..fasePrenhezAtual = fasePrenhezAtual ?? this.fasePrenhezAtual;
  }

  void limpar() {
    dataAcasalamento = null;
    dataUltrassom = null;
    tamanhoFetos = null;
    especieSelecionada = null;
    racaSelecionada = null;
    metodoCalculo = opcoesTipoCalculo[0];
    dataParto = null;
    fasesPrenhez = null;
    fasePrenhezAtual = null;
  }
}
