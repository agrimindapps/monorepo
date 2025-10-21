import 'package:equatable/equatable.dart';

/// Pure domain entity - Vacation calculation result
///
/// Represents the complete calculation of vacation pay including
/// base value, constitutional bonus, taxes, and net amount.
class VacationCalculation extends Equatable {
  /// Unique identifier for this calculation
  final String id;

  /// Gross monthly salary used for calculation
  final double grossSalary;

  /// Number of vacation days (1-30)
  final int vacationDays;

  /// Whether to sell 10 days of vacation (abono pecuniário)
  final bool sellVacationDays;

  /// Base vacation value (proportional to days)
  final double baseValue;

  /// Constitutional 1/3 bonus
  final double constitutionalBonus;

  /// Sold vacation days value (if applicable)
  final double soldDaysValue;

  /// Gross total before taxes
  final double grossTotal;

  /// INSS discount
  final double inssDiscount;

  /// Income tax discount
  final double irDiscount;

  /// Net amount to receive
  final double netTotal;

  /// Calculation timestamp
  final DateTime calculatedAt;

  const VacationCalculation({
    required this.id,
    required this.grossSalary,
    required this.vacationDays,
    required this.sellVacationDays,
    required this.baseValue,
    required this.constitutionalBonus,
    required this.soldDaysValue,
    required this.grossTotal,
    required this.inssDiscount,
    required this.irDiscount,
    required this.netTotal,
    required this.calculatedAt,
  });

  /// Create empty calculation
  factory VacationCalculation.empty() {
    return VacationCalculation(
      id: '',
      grossSalary: 0,
      vacationDays: 30,
      sellVacationDays: false,
      baseValue: 0,
      constitutionalBonus: 0,
      soldDaysValue: 0,
      grossTotal: 0,
      inssDiscount: 0,
      irDiscount: 0,
      netTotal: 0,
      calculatedAt: DateTime.now(),
    );
  }

  VacationCalculation copyWith({
    String? id,
    double? grossSalary,
    int? vacationDays,
    bool? sellVacationDays,
    double? baseValue,
    double? constitutionalBonus,
    double? soldDaysValue,
    double? grossTotal,
    double? inssDiscount,
    double? irDiscount,
    double? netTotal,
    DateTime? calculatedAt,
  }) {
    return VacationCalculation(
      id: id ?? this.id,
      grossSalary: grossSalary ?? this.grossSalary,
      vacationDays: vacationDays ?? this.vacationDays,
      sellVacationDays: sellVacationDays ?? this.sellVacationDays,
      baseValue: baseValue ?? this.baseValue,
      constitutionalBonus: constitutionalBonus ?? this.constitutionalBonus,
      soldDaysValue: soldDaysValue ?? this.soldDaysValue,
      grossTotal: grossTotal ?? this.grossTotal,
      inssDiscount: inssDiscount ?? this.inssDiscount,
      irDiscount: irDiscount ?? this.irDiscount,
      netTotal: netTotal ?? this.netTotal,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        grossSalary,
        vacationDays,
        sellVacationDays,
        baseValue,
        constitutionalBonus,
        soldDaysValue,
        grossTotal,
        inssDiscount,
        irDiscount,
        netTotal,
        calculatedAt,
      ];
}
