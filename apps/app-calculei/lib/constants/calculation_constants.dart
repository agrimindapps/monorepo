/// Global calculation constants for labor and financial calculators
///
/// Contains Brazilian tax tables, limits, and calculation parameters
/// Updated for 2024 legislation
class CalculationConstants {
  // ========== INSS (Social Security) ==========

  /// INSS tax brackets for 2024
  ///
  /// Progressive rates from 7.5% to 14%
  static const List<Map<String, double>> faixasInss = [
    {'min': 0.0, 'max': 1412.00, 'aliquota': 0.075}, // 7.5%
    {'min': 1412.01, 'max': 2666.68, 'aliquota': 0.09}, // 9%
    {'min': 2666.69, 'max': 4000.03, 'aliquota': 0.12}, // 12%
    {'min': 4000.04, 'max': 7786.02, 'aliquota': 0.14}, // 14%
  ];

  /// INSS maximum contribution base (ceiling)
  static const double tetoInss = 7786.02;

  // ========== IRRF (Income Tax) ==========

  /// IRRF tax brackets for 2024
  ///
  /// Progressive rates from 0% to 27.5%
  static const List<Map<String, double>> faixasIrrf = [
    {'min': 0.0, 'max': 2112.00, 'aliquota': 0.0, 'deducao': 0.0}, // Exempt
    {
      'min': 2112.01,
      'max': 2826.65,
      'aliquota': 0.075,
      'deducao': 158.40
    }, // 7.5%
    {
      'min': 2826.66,
      'max': 3751.05,
      'aliquota': 0.15,
      'deducao': 370.40
    }, // 15%
    {
      'min': 3751.06,
      'max': 4664.68,
      'aliquota': 0.225,
      'deducao': 651.73
    }, // 22.5%
    {
      'min': 4664.69,
      'max': double.infinity,
      'aliquota': 0.275,
      'deducao': 884.96
    }, // 27.5%
  ];

  /// IRRF deduction per dependent
  static const double deducaoDependenteIrrf = 189.59;

  // ========== Net Salary (Salário Líquido) ==========

  /// Transportation voucher discount percentage (maximum 6% of gross salary)
  static const double percentualValeTransporte = 0.06;

  // ========== 13th Salary ==========

  /// Months in a year
  static const int mesesAno = 12;

  /// Days in a month (for calculations)
  static const int diasMes = 30;

  /// Unjustified absences threshold for month discount
  ///
  /// Every 15 absences = 1 month discount
  static const int diasFaltaDesconto = 15;

  /// First installment percentage (advance payment)
  static const double percentualPrimeiraParcela = 0.5; // 50%

  // ========== Vacation ==========

  /// Maximum vacation days per year
  static const int maxVacationDays = 30;

  /// Constitutional bonus (1/3)
  static const double vacationConstitutionalBonus = 1 / 3;

  /// Maximum sellable vacation days (abono pecuniário)
  static const double maxSellableVacationDays = 10; // 1/3 of 30 days

  // ========== Overtime (Horas Extras) ==========

  /// Standard weekly work hours
  static const int horasSemanaisPadrao = 44;

  /// Work days per week
  static const double diasTrabalhoSemana = 5.0;

  /// Standard work days per month
  static const int diasUteisPadrao = 22;

  /// 50% overtime rate (normal + 50%)
  static const double percentualHorasExtras50 = 0.50;

  /// 100% overtime rate (normal + 100%)
  static const double percentualHorasExtras100 = 1.00;

  /// Sunday/holiday rate (normal + 100%)
  static const double percentualDomingoFeriado = 1.00;

  /// Minimum night shift additional (20%)
  static const double percentualAdicionalNoturnoMinimo = 0.20;

  /// DSR over overtime (1/6 = ~16.67%)
  static const double percentualDsr = 1 / 6;

  /// Vacation reflection (1/3 = ~33.33%)
  static const double percentualReflexoFerias = 1 / 3;

  /// 13th salary reflection (1/12 = ~8.33%)
  static const double percentualReflexoDecimoTerceiro = 1 / 12;

  /// Maximum weekly work hours (legal limit)
  static const int maxHorasSemanais = 60;

  /// Maximum monthly overtime hours (legal limit)
  static const double maxHorasExtrasMes = 100.0;

  // ========== Validation Limits ==========

  /// Minimum salary (national floor 2024)
  static const double minSalario = 1412.00;

  /// Maximum salary for calculations
  static const double maxSalario = 999999.99;

  /// Maximum months worked per year
  static const int maxMeses = 12;

  /// Maximum unjustified absences
  static const int maxFaltas = 365;

  /// Maximum dependents
  static const int maxDependentes = 20;

  // ========== Date Limits ==========

  /// Minimum admission year
  static const int anoMinimoAdmissao = 1900;

  /// Maximum admission year
  static const int anoMaximoAdmissao = 2100;

  // ========== UI Constants ==========

  /// Form field spacing
  static const double formFieldSpacing = 16.0;

  /// Default form padding
  static const double defaultFormPadding = 16.0;

  /// Card border radius
  static const double cardBorderRadius = 12.0;

  /// Maximum container width (responsive)
  static const double maxContainerWidth = 1120.0;
}
