// Package imports:

// Project imports:
import '../../domain/entities/thirteenth_salary_calculation.dart';


/// Hive model for 13th salary calculation
///
/// Extends domain entity to maintain LSP (Liskov Substitution Principle)
/// Uses Hive annotations for local storage persistence
class ThirteenthSalaryCalculationModel extends ThirteenthSalaryCalculation {
  @override
  final String id;

  @override
  final double grossSalary;

  @override
  final int monthsWorked;

  @override
  final DateTime admissionDate;

  @override
  final DateTime calculationDate;

  @override
  final int unjustifiedAbsences;

  @override
  final bool isAdvancePayment;

  @override
  final int dependents;

  @override
  final int consideredMonths;

  @override
  final double valuePerMonth;

  @override
  final double grossThirteenthSalary;

  @override
  final double inssDiscount;

  @override
  final double inssRate;

  @override
  final double irrfDiscount;

  @override
  final double irrfRate;

  @override
  final double irrfBaseCalculation;

  @override
  final double netThirteenthSalary;

  @override
  final double firstInstallment;

  @override
  final double secondInstallment;

  @override
  final DateTime calculatedAt;

  const ThirteenthSalaryCalculationModel({
    required this.id,
    required this.grossSalary,
    required this.monthsWorked,
    required this.admissionDate,
    required this.calculationDate,
    required this.unjustifiedAbsences,
    required this.isAdvancePayment,
    required this.dependents,
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
    required this.calculatedAt,
  }) : super(
          id: id,
          grossSalary: grossSalary,
          monthsWorked: monthsWorked,
          admissionDate: admissionDate,
          calculationDate: calculationDate,
          unjustifiedAbsences: unjustifiedAbsences,
          isAdvancePayment: isAdvancePayment,
          dependents: dependents,
          consideredMonths: consideredMonths,
          valuePerMonth: valuePerMonth,
          grossThirteenthSalary: grossThirteenthSalary,
          inssDiscount: inssDiscount,
          inssRate: inssRate,
          irrfDiscount: irrfDiscount,
          irrfRate: irrfRate,
          irrfBaseCalculation: irrfBaseCalculation,
          netThirteenthSalary: netThirteenthSalary,
          firstInstallment: firstInstallment,
          secondInstallment: secondInstallment,
          calculatedAt: calculatedAt,
        );

  /// Converts domain entity to data model
  factory ThirteenthSalaryCalculationModel.fromEntity(
    ThirteenthSalaryCalculation entity,
  ) {
    return ThirteenthSalaryCalculationModel(
      id: entity.id,
      grossSalary: entity.grossSalary,
      monthsWorked: entity.monthsWorked,
      admissionDate: entity.admissionDate,
      calculationDate: entity.calculationDate,
      unjustifiedAbsences: entity.unjustifiedAbsences,
      isAdvancePayment: entity.isAdvancePayment,
      dependents: entity.dependents,
      consideredMonths: entity.consideredMonths,
      valuePerMonth: entity.valuePerMonth,
      grossThirteenthSalary: entity.grossThirteenthSalary,
      inssDiscount: entity.inssDiscount,
      inssRate: entity.inssRate,
      irrfDiscount: entity.irrfDiscount,
      irrfRate: entity.irrfRate,
      irrfBaseCalculation: entity.irrfBaseCalculation,
      netThirteenthSalary: entity.netThirteenthSalary,
      firstInstallment: entity.firstInstallment,
      secondInstallment: entity.secondInstallment,
      calculatedAt: entity.calculatedAt,
    );
  }

  /// Converts data model to domain entity
  ThirteenthSalaryCalculation toEntity() {
    return ThirteenthSalaryCalculation(
      id: id,
      grossSalary: grossSalary,
      monthsWorked: monthsWorked,
      admissionDate: admissionDate,
      calculationDate: calculationDate,
      unjustifiedAbsences: unjustifiedAbsences,
      isAdvancePayment: isAdvancePayment,
      dependents: dependents,
      consideredMonths: consideredMonths,
      valuePerMonth: valuePerMonth,
      grossThirteenthSalary: grossThirteenthSalary,
      inssDiscount: inssDiscount,
      inssRate: inssRate,
      irrfDiscount: irrfDiscount,
      irrfRate: irrfRate,
      irrfBaseCalculation: irrfBaseCalculation,
      netThirteenthSalary: netThirteenthSalary,
      firstInstallment: firstInstallment,
      secondInstallment: secondInstallment,
      calculatedAt: calculatedAt,
    );
  }

  /// Converts to JSON for Firebase/remote storage (optional)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grossSalary': grossSalary,
      'monthsWorked': monthsWorked,
      'admissionDate': admissionDate.toIso8601String(),
      'calculationDate': calculationDate.toIso8601String(),
      'unjustifiedAbsences': unjustifiedAbsences,
      'isAdvancePayment': isAdvancePayment,
      'dependents': dependents,
      'consideredMonths': consideredMonths,
      'valuePerMonth': valuePerMonth,
      'grossThirteenthSalary': grossThirteenthSalary,
      'inssDiscount': inssDiscount,
      'inssRate': inssRate,
      'irrfDiscount': irrfDiscount,
      'irrfRate': irrfRate,
      'irrfBaseCalculation': irrfBaseCalculation,
      'netThirteenthSalary': netThirteenthSalary,
      'firstInstallment': firstInstallment,
      'secondInstallment': secondInstallment,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Converts from JSON for Firebase/remote storage (optional)
  factory ThirteenthSalaryCalculationModel.fromJson(Map<String, dynamic> json) {
    return ThirteenthSalaryCalculationModel(
      id: json['id'] as String,
      grossSalary: (json['grossSalary'] as num).toDouble(),
      monthsWorked: json['monthsWorked'] as int,
      admissionDate: DateTime.parse(json['admissionDate'] as String),
      calculationDate: DateTime.parse(json['calculationDate'] as String),
      unjustifiedAbsences: json['unjustifiedAbsences'] as int,
      isAdvancePayment: json['isAdvancePayment'] as bool,
      dependents: json['dependents'] as int,
      consideredMonths: json['consideredMonths'] as int,
      valuePerMonth: (json['valuePerMonth'] as num).toDouble(),
      grossThirteenthSalary: (json['grossThirteenthSalary'] as num).toDouble(),
      inssDiscount: (json['inssDiscount'] as num).toDouble(),
      inssRate: (json['inssRate'] as num).toDouble(),
      irrfDiscount: (json['irrfDiscount'] as num).toDouble(),
      irrfRate: (json['irrfRate'] as num).toDouble(),
      irrfBaseCalculation: (json['irrfBaseCalculation'] as num).toDouble(),
      netThirteenthSalary: (json['netThirteenthSalary'] as num).toDouble(),
      firstInstallment: (json['firstInstallment'] as num).toDouble(),
      secondInstallment: (json['secondInstallment'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
