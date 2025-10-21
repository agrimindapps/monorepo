// Package imports:
import 'package:equatable/equatable.dart';

/// Entity representing an overtime (horas extras) calculation
class OvertimeCalculation extends Equatable {
  // INPUTS
  final double grossSalary;
  final int weeklyHours;
  final double hours50;
  final double hours100;
  final double nightHours;
  final double nightAdditionalPercentage;
  final double sundayHolidayHours;
  final int workDaysMonth;
  final int dependents;

  // RESULTS
  final double monthlyWorkedHours;
  final double normalHourValue;
  final double hour50Value;
  final double hour100Value;
  final double nightHourValue;
  final double sundayHolidayHourValue;
  final double total50;
  final double total100;
  final double totalNightAdditional;
  final double totalSundayHoliday;
  final double dsrOvertime;
  final double totalOvertime;
  final double vacationReflection;
  final double thirteenthReflection;
  final double grossTotal;
  final double inssDiscount;
  final double inssRate;
  final double irrfDiscount;
  final double irrfRate;
  final double netTotal;
  final double totalOvertimeHours;

  // METADATA
  final String id;
  final DateTime calculatedAt;

  const OvertimeCalculation({
    required this.grossSalary,
    required this.weeklyHours,
    required this.hours50,
    required this.hours100,
    required this.nightHours,
    required this.nightAdditionalPercentage,
    required this.sundayHolidayHours,
    required this.workDaysMonth,
    required this.dependents,
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
    required this.id,
    required this.calculatedAt,
  });

  OvertimeCalculation copyWith({
    double? grossSalary,
    int? weeklyHours,
    double? hours50,
    double? hours100,
    double? nightHours,
    double? nightAdditionalPercentage,
    double? sundayHolidayHours,
    int? workDaysMonth,
    int? dependents,
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
    String? id,
    DateTime? calculatedAt,
  }) {
    return OvertimeCalculation(
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
      id: id ?? this.id,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  List<Object?> get props => [
        grossSalary,
        weeklyHours,
        hours50,
        hours100,
        nightHours,
        nightAdditionalPercentage,
        sundayHolidayHours,
        workDaysMonth,
        dependents,
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
        id,
        calculatedAt,
      ];
}
