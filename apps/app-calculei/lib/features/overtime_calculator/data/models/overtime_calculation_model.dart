import 'package:hive/hive.dart';
import '../../domain/entities/overtime_calculation.dart';

part 'overtime_calculation_model.g.dart';

@HiveType(typeId: 12)
class OvertimeCalculationModel extends OvertimeCalculation {
  @HiveField(0) @override final String id;
  @HiveField(1) @override final double grossSalary;
  @HiveField(2) @override final int weeklyHours;
  @HiveField(3) @override final double hours50;
  @HiveField(4) @override final double hours100;
  @HiveField(5) @override final double nightHours;
  @HiveField(6) @override final double nightAdditionalPercentage;
  @HiveField(7) @override final double sundayHolidayHours;
  @HiveField(8) @override final int workDaysMonth;
  @HiveField(9) @override final int dependents;
  @HiveField(10) @override final double monthlyWorkedHours;
  @HiveField(11) @override final double normalHourValue;
  @HiveField(12) @override final double hour50Value;
  @HiveField(13) @override final double hour100Value;
  @HiveField(14) @override final double nightHourValue;
  @HiveField(15) @override final double sundayHolidayHourValue;
  @HiveField(16) @override final double total50;
  @HiveField(17) @override final double total100;
  @HiveField(18) @override final double totalNightAdditional;
  @HiveField(19) @override final double totalSundayHoliday;
  @HiveField(20) @override final double dsrOvertime;
  @HiveField(21) @override final double totalOvertime;
  @HiveField(22) @override final double vacationReflection;
  @HiveField(23) @override final double thirteenthReflection;
  @HiveField(24) @override final double grossTotal;
  @HiveField(25) @override final double inssDiscount;
  @HiveField(26) @override final double inssRate;
  @HiveField(27) @override final double irrfDiscount;
  @HiveField(28) @override final double irrfRate;
  @HiveField(29) @override final double netTotal;
  @HiveField(30) @override final double totalOvertimeHours;
  @HiveField(31) @override final DateTime calculatedAt;

  const OvertimeCalculationModel({
    required this.id, required this.grossSalary, required this.weeklyHours,
    required this.hours50, required this.hours100, required this.nightHours,
    required this.nightAdditionalPercentage, required this.sundayHolidayHours,
    required this.workDaysMonth, required this.dependents,
    required this.monthlyWorkedHours, required this.normalHourValue,
    required this.hour50Value, required this.hour100Value,
    required this.nightHourValue, required this.sundayHolidayHourValue,
    required this.total50, required this.total100,
    required this.totalNightAdditional, required this.totalSundayHoliday,
    required this.dsrOvertime, required this.totalOvertime,
    required this.vacationReflection, required this.thirteenthReflection,
    required this.grossTotal, required this.inssDiscount,
    required this.inssRate, required this.irrfDiscount,
    required this.irrfRate, required this.netTotal,
    required this.totalOvertimeHours, required this.calculatedAt,
  }) : super(
    id: id, grossSalary: grossSalary, weeklyHours: weeklyHours,
    hours50: hours50, hours100: hours100, nightHours: nightHours,
    nightAdditionalPercentage: nightAdditionalPercentage,
    sundayHolidayHours: sundayHolidayHours, workDaysMonth: workDaysMonth,
    dependents: dependents, monthlyWorkedHours: monthlyWorkedHours,
    normalHourValue: normalHourValue, hour50Value: hour50Value,
    hour100Value: hour100Value, nightHourValue: nightHourValue,
    sundayHolidayHourValue: sundayHolidayHourValue, total50: total50,
    total100: total100, totalNightAdditional: totalNightAdditional,
    totalSundayHoliday: totalSundayHoliday, dsrOvertime: dsrOvertime,
    totalOvertime: totalOvertime, vacationReflection: vacationReflection,
    thirteenthReflection: thirteenthReflection, grossTotal: grossTotal,
    inssDiscount: inssDiscount, inssRate: inssRate,
    irrfDiscount: irrfDiscount, irrfRate: irrfRate, netTotal: netTotal,
    totalOvertimeHours: totalOvertimeHours, calculatedAt: calculatedAt,
  );

  factory OvertimeCalculationModel.fromEntity(OvertimeCalculation e) {
    return OvertimeCalculationModel(
      id: e.id, grossSalary: e.grossSalary, weeklyHours: e.weeklyHours,
      hours50: e.hours50, hours100: e.hours100, nightHours: e.nightHours,
      nightAdditionalPercentage: e.nightAdditionalPercentage,
      sundayHolidayHours: e.sundayHolidayHours, workDaysMonth: e.workDaysMonth,
      dependents: e.dependents, monthlyWorkedHours: e.monthlyWorkedHours,
      normalHourValue: e.normalHourValue, hour50Value: e.hour50Value,
      hour100Value: e.hour100Value, nightHourValue: e.nightHourValue,
      sundayHolidayHourValue: e.sundayHolidayHourValue, total50: e.total50,
      total100: e.total100, totalNightAdditional: e.totalNightAdditional,
      totalSundayHoliday: e.totalSundayHoliday, dsrOvertime: e.dsrOvertime,
      totalOvertime: e.totalOvertime, vacationReflection: e.vacationReflection,
      thirteenthReflection: e.thirteenthReflection, grossTotal: e.grossTotal,
      inssDiscount: e.inssDiscount, inssRate: e.inssRate,
      irrfDiscount: e.irrfDiscount, irrfRate: e.irrfRate, netTotal: e.netTotal,
      totalOvertimeHours: e.totalOvertimeHours, calculatedAt: e.calculatedAt,
    );
  }

  OvertimeCalculation toEntity() => this;
}
