class CalculationConstants {
  // Faixas de INSS 2024
  static const List<Map<String, double>> faixasInss = [
    {'min': 0.0, 'max': 1412.00, 'aliquota': 0.075},
    {'min': 1412.01, 'max': 2666.68, 'aliquota': 0.09},
    {'min': 2666.69, 'max': 4000.03, 'aliquota': 0.12},
    {'min': 4000.04, 'max': 7786.02, 'aliquota': 0.14},
  ];
  
  // Faixas de IRRF 2024
  static const List<Map<String, double>> faixasIrrf = [
    {'min': 0.0, 'max': 2112.00, 'aliquota': 0.0, 'deducao': 0.0},
    {'min': 2112.01, 'max': 2826.65, 'aliquota': 0.075, 'deducao': 158.40},
    {'min': 2826.66, 'max': 3751.05, 'aliquota': 0.15, 'deducao': 370.40},
    {'min': 3751.06, 'max': 4664.68, 'aliquota': 0.225, 'deducao': 651.73},
    {'min': 4664.69, 'max': double.infinity, 'aliquota': 0.275, 'deducao': 884.96},
  ];
  
  // Dedução por dependente IRRF
  static const double deducaoDependenteIrrf = 189.59;
  
  // Teto do INSS
  static const double tetoInss = 7786.02;
  
  // Valores para cálculo de férias
  static const int diasFeriasCompletas = 30;
  static const int diasMes = 30;
  static const int mesesAno = 12;
  static const double percentualAbonoConstitucional = 1.0 / 3.0; // 1/3 das férias
  static const double percentualMaximoAbonoPecuniario = 1.0 / 3.0; // Máximo 1/3 pode vender
  
  // Tabela de faltas e perda de dias de férias
  static const List<Map<String, int>> tabelaFaltas = [
    {'faltasMin': 0, 'faltasMax': 5, 'diasDireito': 30},
    {'faltasMin': 6, 'faltasMax': 14, 'diasDireito': 24},
    {'faltasMin': 15, 'faltasMax': 23, 'diasDireito': 18},
    {'faltasMin': 24, 'faltasMax': 32, 'diasDireito': 12},
    {'faltasMin': 33, 'faltasMax': 999, 'diasDireito': 0},
  ];
  
  // Validação
  static const double minSalario = 1412.00;
  static const double maxSalario = 999999.99;
  static const int maxDiasFerias = 30;
  static const int maxFaltas = 365;
  static const int maxDependentes = 99;
  
  // Layout
  static const double formFieldSpacing = 16.0;
  static const double defaultFormPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Datas limites
  static const int anoMinimoAquisitivo = 1900;
  static const int anoMaximoAquisitivo = 2100;
  
  // Períodos
  static const int diasPeriodoAquisitivo = 365;
  static const int diasMinimosFerias = 5; // Mínimo 5 dias corridos
}