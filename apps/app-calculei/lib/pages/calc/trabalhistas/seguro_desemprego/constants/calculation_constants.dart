class CalculationConstants {
  // Tabela de faixas salariais para seguro-desemprego 2024
  static const List<Map<String, dynamic>> faixasSalario = [
    {
      'min': 0.0,
      'max': 1968.36,
      'multiplicador': 0.8,
      'valorFixo': 0.0,
    },
    {
      'min': 1968.37,
      'max': 3280.93,
      'multiplicador': 0.5,
      'valorFixo': 1574.69,
    },
    {
      'min': 3280.94,
      'max': double.infinity,
      'multiplicador': 0.0,
      'valorFixo': 2230.97,
    },
  ];
  
  // Tabela de parcelas por tempo de trabalho
  static const List<Map<String, int>> tabelaParcelas = [
    {'mesesMin': 12, 'mesesMax': 23, 'parcelas': 4},
    {'mesesMin': 24, 'mesesMax': 35, 'parcelas': 5},
    {'mesesMin': 36, 'mesesMax': 999, 'parcelas': 5},
  ];
  
  // Tabela de parcelas para quem já recebeu
  static const List<Map<String, dynamic>> tabelaParcelasJaRecebeu = [
    {'vezesRecebidas': 1, 'mesesMin': 9, 'mesesMax': 23, 'parcelas': 3},
    {'vezesRecebidas': 1, 'mesesMin': 24, 'mesesMax': 999, 'parcelas': 4},
    {'vezesRecebidas': 2, 'mesesMin': 6, 'mesesMax': 23, 'parcelas': 2},
    {'vezesRecebidas': 2, 'mesesMax': 999, 'parcelas': 3},
  ];
  
  // Valores limites
  static const double salarioMinimo = 1412.00;
  static const double valorMinimoParcela = 1412.00; // Valor mínimo = salário mínimo
  static const double valorMaximoParcela = 2230.97; // Valor máximo
  
  // Prazos em dias
  static const int prazoRequererDias = 120; // 4 meses para requerer
  static const int intervaloParcelasDias = 30; // Parcelas mensais
  
  // Carência em meses
  static const int carenciaPrimeiraVez = 12; // 12 meses para primeira vez
  static const int carenciaSegundaVez = 9; // 9 meses para segunda vez
  static const int carenciaTerceiraVez = 6; // 6 meses para terceira vez
  
  // Período de carência entre recebimentos (16 meses)
  static const int carenciaEntreRecebimentos = 16;
  
  // Validação
  static const double minSalario = 1412.00;
  static const double maxSalario = 99999.99;
  static const int minTempoTrabalho = 1;
  static const int maxTempoTrabalho = 600; // 50 anos
  static const int maxVezesRecebidas = 10;
  
  // Layout
  static const double formFieldSpacing = 16.0;
  static const double defaultFormPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Datas limites
  static const int anoMinimoAdmissao = 1900;
  static const int anoMaximoAdmissao = 2100;
}