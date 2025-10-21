// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing a 13th salary calculation
///
/// Pure domain entity following Clean Architecture principles
/// Immutable with copyWith pattern for modifications
class ThirteenthSalaryCalculation extends Equatable {
  // ========== INPUTS ==========

  /// Gross monthly salary
  final double grossSalary;

  /// Number of months worked in the year (1-12)
  final int monthsWorked;

  /// Employment start date
  final DateTime admissionDate;

  /// Calculation date
  final DateTime calculationDate;

  /// Number of unjustified absences
  final int unjustifiedAbsences;

  /// Whether it's an advance payment (2 installments)
  final bool isAdvancePayment;

  /// Number of dependents for IRRF calculation
  final int dependents;

  // ========== CALCULATION RESULTS ==========

  /// Months considered after absence discounts
  final int consideredMonths;

  /// Value per month (grossSalary / 12)
  final double valuePerMonth;

  /// Gross 13th salary
  final double grossThirteenthSalary;

  /// INSS discount amount
  final double inssDiscount;

  /// INSS tax rate applied
  final double inssRate;

  /// IRRF discount amount
  final double irrfDiscount;

  /// IRRF tax rate applied
  final double irrfRate;

  /// Base calculation for IRRF (gross - INSS)
  final double irrfBaseCalculation;

  /// Net 13th salary (gross - INSS - IRRF)
  final double netThirteenthSalary;

  /// First installment (if advance payment)
  final double firstInstallment;

  /// Second installment (if advance payment)
  final double secondInstallment;

  // ========== METADATA ==========

  /// Unique identifier
  final String id;

  /// When this calculation was performed
  final DateTime calculatedAt;

  const ThirteenthSalaryCalculation({
    // Inputs
    required this.grossSalary,
    required this.monthsWorked,
    required this.admissionDate,
    required this.calculationDate,
    required this.unjustifiedAbsences,
    required this.isAdvancePayment,
    required this.dependents,
    // Results
    required this.consideredMonths,
    required this.valuePerMonth,
    required this.grossThirteenthSalary,
    required this.inssDiscount,
    required this.inssRate,
    required this.irrfDiscount,
    required this.irrfRate,
    required this.irrfBaseCalculation,
    required this.netThirteenthSalary,
    required this.firstInstallment,
    required this.secondInstallment,
    // Metadata
    required this.id,
    required this.calculatedAt,
  });

  /// Creates a copy of this calculation with modified fields
  ThirteenthSalaryCalculation copyWith({
    // Inputs
    double? grossSalary,
    int? monthsWorked,
    DateTime? admissionDate,
    DateTime? calculationDate,
    int? unjustifiedAbsences,
    bool? isAdvancePayment,
    int? dependents,
    // Results
    int? consideredMonths,
    double? valuePerMonth,
    double? grossThirteenthSalary,
    double? inssDiscount,
    double? inssRate,
    double? irrfDiscount,
    double? irrfRate,
    double? irrfBaseCalculation,
    double? netThirteenthSalary,
    double? firstInstallment,
    double? secondInstallment,
    // Metadata
    String? id,
    DateTime? calculatedAt,
  }) {
    return ThirteenthSalaryCalculation(
      // Inputs
      grossSalary: grossSalary ?? this.grossSalary,
      monthsWorked: monthsWorked ?? this.monthsWorked,
      admissionDate: admissionDate ?? this.admissionDate,
      calculationDate: calculationDate ?? this.calculationDate,
      unjustifiedAbsences: unjustifiedAbsences ?? this.unjustifiedAbsences,
      isAdvancePayment: isAdvancePayment ?? this.isAdvancePayment,
      dependents: dependents ?? this.dependents,
      // Results
      consideredMonths: consideredMonths ?? this.consideredMonths,
      valuePerMonth: valuePerMonth ?? this.valuePerMonth,
      grossThirteenthSalary: grossThirteenthSalary ?? this.grossThirteenthSalary,
      inssDiscount: inssDiscount ?? this.inssDiscount,
      inssRate: inssRate ?? this.inssRate,
      irrfDiscount: irrfDiscount ?? this.irrfDiscount,
      irrfRate: irrfRate ?? this.irrfRate,
      irrfBaseCalculation: irrfBaseCalculation ?? this.irrfBaseCalculation,
      netThirteenthSalary: netThirteenthSalary ?? this.netThirteenthSalary,
      firstInstallment: firstInstallment ?? this.firstInstallment,
      secondInstallment: secondInstallment ?? this.secondInstallment,
      // Metadata
      id: id ?? this.id,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        // Inputs
        grossSalary,
        monthsWorked,
        admissionDate,
        calculationDate,
        unjustifiedAbsences,
        isAdvancePayment,
        dependents,
        // Results
        consideredMonths,
        valuePerMonth,
        grossThirteenthSalary,
        inssDiscount,
        inssRate,
        irrfDiscount,
        irrfRate,
        irrfBaseCalculation,
        netThirteenthSalary,
        firstInstallment,
        secondInstallment,
        // Metadata
        id,
        calculatedAt,
      ];
}
