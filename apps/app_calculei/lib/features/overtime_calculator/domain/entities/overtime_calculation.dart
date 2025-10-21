// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing an overtime (horas extras) calculation
///
/// Pure domain entity following Clean Architecture principles
/// Immutable with copyWith pattern for modifications
class OvertimeCalculation extends Equatable {
  // ========== INPUTS ==========

  /// Gross monthly salary
  final double grossSalary;

  /// Weekly work hours
  final int weeklyHours;

  /// Hours with 50% additional (normal + 50%)
  final double hours50;

  /// Hours with 100% additional (normal + 100%)
  final double hours100;

  /// Night shift hours
  final double nightHours;

  /// Night shift additional percentage
  final double nightAdditionalPercentage;

  /// Sunday/holiday hours
  final double sundayHolidayHours;

  /// Work days in month
  final int workDaysMonth;

  /// Number of dependents for IRRF calculation
  final int dependents;

  // ========== CALCULATION RESULTS ==========

  /// Monthly worked hours
  final double monthlyWorkedHours;

  /// Normal hour value
  final double normalHourValue;

  /// 50% overtime hour value
  final double hour50Value;

  /// 100% overtime hour value
  final double hour100Value;

  /// Night hour value
  final double nightHourValue;

  /// Sunday/holiday hour value
  final double sundayHolidayHourValue;

  /// Total 50% overtime value
  final double total50;

  /// Total 100% overtime value
  final double total100;

  /// Total night additional value
  final double totalNightAdditional;

  /// Total Sunday/holiday value
  final double totalSundayHoliday;

  /// DSR (Weekly Rest) over overtime
  final double dsrOvertime;

  /// Total overtime value (50% + 100%)
  final double totalOvertime;

  /// Vacation reflection
  final double vacationReflection;

  /// 13th salary reflection
  final double thirteenthReflection;

  /// Gross total (salary + all extras)
  final double grossTotal;

  /// INSS discount amount
  final double inssDiscount;

  /// INSS tax rate applied
  final double inssRate;

  /// IRRF discount amount
  final double irrfDiscount;

  /// IRRF tax rate applied
  final double irrfRate;

  /// Net total (gross - INSS - IRRF)
  final double netTotal;

  /// Total overtime hours in month
  final double totalOvertimeHours;

  // ========== METADATA ==========

  /// Unique identifier
  final String id;

  /// When this calculation was performed
  final DateTime calculatedAt;

  const OvertimeCalculation({
    // Inputs
    required this.grossSalary,
    required this.weeklyHours,
    required this.hours50,
    required this.hours100,
    required this.nightHours,
    required this.nightAdditionalPercentage,
    required this.sundayHolidayHours,
    required this.workDaysMonth,
    required this.dependents,
    // Results
    required this.monthlyWorkedHours,
    required this.normalHourValue,
    required this.hour50Value,
    required this.hour100Value,
    required this.nightHourValue,
    required this.sundayHolidayHourValue,
    required this.total50,
    required this.total100,
    required this.totalNightAdditional,
    required this.totalSundayHoliday,
    required this.dsrOvertime,
    required this.totalOvertime,
    required this.vacationReflection,
    required this.thirteenthReflection,
    required this.grossTotal,
    required this.inssDiscount,
    required this.inssRate,
    required this.irrfDiscount,
    required this.irrfRate,
    required this.netTotal,
    required this.totalOvertimeHours,
    // Metadata
    required this.id,
    required this.calculatedAt,
  });

  /// Creates a copy of this calculation with modified fields
  OvertimeCalculation copyWith({
    // Inputs
    double? grossSalary,
    int? weeklyHours,
    double? hours50,
    double? hours100,
    double? nightHours,
    double? nightAdditionalPercentage,
    double? sundayHolidayHours,
    int? workDaysMonth,
    int? dependents,
    // Results
    double? monthlyWorkedHours,
    double? normalHourValue,
    double? hour50Value,
    double? hour100Value,
    double? nightHourValue,
    double? sundayHolidayHourValue,
    double? total50,
    double? total100,
    double? totalNightAdditional,
    double? totalSundayHoliday,
    double? dsrOvertime,
    double? totalOvertime,
    double? vacationReflection,
    double? thirteenthReflection,
    double? grossTotal,
    double? inssDiscount,
    double? inssRate,
    double? irrfDiscount,
    double? irrfRate,
    double? netTotal,
    double? totalOvertimeHours,
    // Metadata
    String? id,
    DateTime? calculatedAt,
  }) {
    return OvertimeCalculation(
      // Inputs
      grossSalary: grossSalary ?? this.grossSalary,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      hours50: hours50 ?? this.hours50,
      hours100: hours100 ?? this.hours100,
      nightHours: nightHours ?? this.nightHours,
      nightAdditionalPercentage:
          nightAdditionalPercentage ?? this.nightAdditionalPercentage,
      sundayHolidayHours: sundayHolidayHours ?? this.sundayHolidayHours,
      workDaysMonth: workDaysMonth ?? this.workDaysMonth,
      dependents: dependents ?? this.dependents,
      // Results
      monthlyWorkedHours: monthlyWorkedHours ?? this.monthlyWorkedHours,
      normalHourValue: normalHourValue ?? this.normalHourValue,
      hour50Value: hour50Value ?? this.hour50Value,
      hour100Value: hour100Value ?? this.hour100Value,
      nightHourValue: nightHourValue ?? this.nightHourValue,
      sundayHolidayHourValue:
          sundayHolidayHourValue ?? this.sundayHolidayHourValue,
      total50: total50 ?? this.total50,
      total100: total100 ?? this.total100,
      totalNightAdditional: totalNightAdditional ?? this.totalNightAdditional,
      totalSundayHoliday: totalSundayHoliday ?? this.totalSundayHoliday,
      dsrOvertime: dsrOvertime ?? this.dsrOvertime,
      totalOvertime: totalOvertime ?? this.totalOvertime,
      vacationReflection: vacationReflection ?? this.vacationReflection,
      thirteenthReflection: thirteenthReflection ?? this.thirteenthReflection,
      grossTotal: grossTotal ?? this.grossTotal,
      inssDiscount: inssDiscount ?? this.inssDiscount,
      inssRate: inssRate ?? this.inssRate,
      irrfDiscount: irrfDiscount ?? this.irrfDiscount,
      irrfRate: irrfRate ?? this.irrfRate,
      netTotal: netTotal ?? this.netTotal,
      totalOvertimeHours: totalOvertimeHours ?? this.totalOvertimeHours,
      // Metadata
      id: id ?? this.id,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        // Inputs
        grossSalary,
        weeklyHours,
        hours50,
        hours100,
        nightHours,
        nightAdditionalPercentage,
        sundayHolidayHours,
        workDaysMonth,
        dependents,
        // Results
        monthlyWorkedHours,
        normalHourValue,
        hour50Value,
        hour100Value,
        nightHourValue,
        sundayHolidayHourValue,
        total50,
        total100,
        totalNightAdditional,
        totalSundayHoliday,
        dsrOvertime,
        totalOvertime,
        vacationReflection,
        thirteenthReflection,
        grossTotal,
        inssDiscount,
        inssRate,
        irrfDiscount,
        irrfRate,
        netTotal,
        totalOvertimeHours,
        // Metadata
        id,
        calculatedAt,
      ];
}
