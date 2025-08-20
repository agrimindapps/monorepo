class DietaCaseiraModel {
  String? especieSelecionada;
  String? estadoFisiologicoSelecionado;
  String? nivelAtividadeSelecionado;
  String? tipoAlimentacaoSelecionado;

  double? peso;
  int? idadeAnos;
  int? idadeMeses;

  double? necessidadeCalorica;
  Map<String, double>? macronutrientes;
  Map<String, double>? quantidadesAlimentos;
  Map<String, String>? recomendacoes;

  bool showInfoCard = true;

  // Opções para os dropdowns
  final List<String> especies = ['Cão', 'Gato'];

  final Map<String, List<String>> estadosFisiologicos = {
    'Cão': ['Filhote', 'Adulto', 'Idoso', 'Gestante', 'Lactante', 'Castrado'],
    'Gato': ['Filhote', 'Adulto', 'Idoso', 'Gestante', 'Lactante', 'Castrado'],
  };

  final Map<String, List<String>> niveisAtividade = {
    'Cão': ['Sedentário', 'Pouco ativo', 'Moderadamente ativo', 'Muito ativo'],
    'Gato': ['Sedentário', 'Ativo', 'Muito ativo'],
  };

  final List<String> tiposAlimentacao = [
    'Dieta Tradicional',
    'Dieta Hipoalergênica',
    'Dieta para Controle de Peso',
    'Dieta para Problemas Renais',
    'Dieta para Problemas Hepáticos'
  ];

  // Fatores para cálculo de necessidade energética
  final Map<String, Map<String, double>> fatoresEnergeticos = {
    'Cão': {
      'Filhote': 3.0,
      'Adulto': 1.6,
      'Idoso': 1.4,
      'Gestante': 3.0,
      'Lactante': 4.0,
      'Castrado': 1.4,
    },
    'Gato': {
      'Filhote': 2.5,
      'Adulto': 1.2,
      'Idoso': 1.1,
      'Gestante': 2.0,
      'Lactante': 3.0,
      'Castrado': 1.0,
    },
  };

  // Fatores para ajuste por nível de atividade
  final Map<String, Map<String, double>> fatoresAtividade = {
    'Cão': {
      'Sedentário': 0.8,
      'Pouco ativo': 1.0,
      'Moderadamente ativo': 1.2,
      'Muito ativo': 1.4,
    },
    'Gato': {
      'Sedentário': 0.9,
      'Ativo': 1.0,
      'Muito ativo': 1.2,
    },
  };

  // Proporções de macronutrientes por tipo de dieta para cães
  final Map<String, Map<String, double>> proporcoesMacronutrientesCaes = {
    'Dieta Tradicional': {
      'Proteína': 0.30,
      'Gordura': 0.15,
      'Carboidratos': 0.55,
    },
    'Dieta Hipoalergênica': {
      'Proteína': 0.25,
      'Gordura': 0.15,
      'Carboidratos': 0.60,
    },
    'Dieta para Controle de Peso': {
      'Proteína': 0.35,
      'Gordura': 0.10,
      'Carboidratos': 0.55,
    },
    'Dieta para Problemas Renais': {
      'Proteína': 0.18,
      'Gordura': 0.20,
      'Carboidratos': 0.62,
    },
    'Dieta para Problemas Hepáticos': {
      'Proteína': 0.20,
      'Gordura': 0.20,
      'Carboidratos': 0.60,
    },
  };

  // Proporções de macronutrientes por tipo de dieta para gatos
  final Map<String, Map<String, double>> proporcoesMacronutrientesGatos = {
    'Dieta Tradicional': {
      'Proteína': 0.45,
      'Gordura': 0.25,
      'Carboidratos': 0.30,
    },
    'Dieta Hipoalergênica': {
      'Proteína': 0.40,
      'Gordura': 0.25,
      'Carboidratos': 0.35,
    },
    'Dieta para Controle de Peso': {
      'Proteína': 0.50,
      'Gordura': 0.15,
      'Carboidratos': 0.35,
    },
    'Dieta para Problemas Renais': {
      'Proteína': 0.30,
      'Gordura': 0.25,
      'Carboidratos': 0.45,
    },
    'Dieta para Problemas Hepáticos': {
      'Proteína': 0.35,
      'Gordura': 0.20,
      'Carboidratos': 0.45,
    },
  };

  // Valores nutricionais médios de alimentos comuns (por 100g)
  final Map<String, Map<String, double>> valoresNutricionaisAlimentos = {
    'Frango (cozido)': {
      'Proteína': 25.0,
      'Gordura': 7.0,
      'Carboidratos': 0.0,
      'Calorias': 165.0,
    },
    'Carne bovina (cozida)': {
      'Proteína': 26.0,
      'Gordura': 15.0,
      'Carboidratos': 0.0,
      'Calorias': 250.0,
    },
    'Arroz (cozido)': {
      'Proteína': 2.5,
      'Gordura': 0.3,
      'Carboidratos': 28.0,
      'Calorias': 130.0,
    },
    'Batata doce (cozida)': {
      'Proteína': 1.5,
      'Gordura': 0.1,
      'Carboidratos': 20.0,
      'Calorias': 86.0,
    },
    'Cenoura (cozida)': {
      'Proteína': 0.8,
      'Gordura': 0.2,
      'Carboidratos': 8.0,
      'Calorias': 35.0,
    },
    'Óleo de coco': {
      'Proteína': 0.0,
      'Gordura': 99.0,
      'Carboidratos': 0.0,
      'Calorias': 900.0,
    },
    'Ovo (cozido)': {
      'Proteína': 13.0,
      'Gordura': 11.0,
      'Carboidratos': 1.0,
      'Calorias': 155.0,
    },
  };

  /// Limpa os dados do modelo
  void limpar() {
    especieSelecionada = null;
    estadoFisiologicoSelecionado = null;
    nivelAtividadeSelecionado = null;
    tipoAlimentacaoSelecionado = null;
    peso = null;
    idadeAnos = null;
    idadeMeses = null;
    necessidadeCalorica = null;
    macronutrientes = null;
    quantidadesAlimentos = null;
    recomendacoes = null;
  }
}
