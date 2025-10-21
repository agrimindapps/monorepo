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
  
  // Valores para cálculo de horas extras
  static const double percentualHorasExtras50 = 0.50; // 50% sobre hora normal
  static const double percentualHorasExtras100 = 1.00; // 100% sobre hora normal
  static const double percentualAdicionalNoturnoMinimo = 0.20; // Mínimo 20%
  static const double percentualDomingoFeriado = 1.00; // 100% sobre hora normal
  
  // DSR - Descanso Semanal Remunerado
  static const double percentualDsr = 1.0 / 6.0; // 1/6 sobre horas extras
  
  // Reflexos
  static const double percentualReflexoFerias = 1.0 / 12.0; // 1/12 sobre extras
  static const double percentualReflexoDecimoTerceiro = 1.0 / 12.0; // 1/12 sobre extras
  
  // Padrões de jornada
  static const int horasSemanaisPadrao = 44;
  static const int diasUteisPadrao = 22;
  static const int diasSemana = 7;
  static const int diasTrabalhoSemana = 6;
  
  // Limites de validação
  static const double minSalario = 1412.00;
  static const double maxSalario = 999999.99;
  static const int minHorasSemanais = 1;
  static const int maxHorasSemanais = 60;
  static const double maxHorasExtras = 200.0;
  static const double maxPercentualNoturno = 100.0;
  static const int maxDependentes = 99;
  static const int minDiasUteis = 1;
  static const int maxDiasUteis = 31;
  
  // Layout
  static const double formFieldSpacing = 16.0;
  static const double defaultFormPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  
  // Horários noturnos (22h às 5h)
  static const int horaInicioNoturno = 22;
  static const int horaFimNoturno = 5;
  
  // Redução da hora noturna (52'30" = 52.5 minutos)
  static const double minutosHoraNoturna = 52.5;
  static const double minutosHoraNormal = 60.0;
  static const double fatorReducaoHoraNoturna = minutosHoraNoturna / minutosHoraNormal;
}