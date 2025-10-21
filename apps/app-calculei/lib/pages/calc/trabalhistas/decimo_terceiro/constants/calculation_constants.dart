class CalculationConstants {
  // Faixas de INSS 2024 (mesmo do salário líquido)
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
  
  // Valores para cálculo do 13º
  static const int mesesAno = 12;
  static const int diasMes = 30;
  static const int diasFaltaDesconto = 15; // Acima de 15 faltas desconta 1 mês
  
  // Percentual primeira parcela (antecipação)
  static const double percentualPrimeiraParcela = 0.5;
  
  // Validação
  static const double minSalario = 1412.00;
  static const double maxSalario = 999999.99;
  static const int maxMeses = 12;
  static const int maxFaltas = 365;
  
  // Layout
  static const double formFieldSpacing = 16.0;
  static const double defaultFormPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Datas limites
  static const int anoMinimoAdmissao = 1900;
  static const int anoMaximoAdmissao = 2100;
}