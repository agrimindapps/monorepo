// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../domain/entities/overtime_calculation.dart';

part 'overtime_calculation_model.g.dart';

/// Hive model for overtime calculation
@HiveType(typeId: 12) // Unique typeId
class OvertimeCalculationModel extends OvertimeCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double grossSalary;

  @HiveField(2)
  @override
  final int weeklyHours;

  @HiveField(3)
  @override
  final double hours50;

  @HiveField(4)
  @override
  final double hours100;

  @HiveField(5)
  @override
  final double nightHours;

  @HiveField(6)
  @override
  final double nightAdditionalPercentage;

  @HiveField(7)
  @override
  final double sundayHolidayHours;

  @HiveField(8)
  @override
  final int workDaysMonth;

  @HiveField(9)
  @override
  final int dependents;

  @HiveField(10)
  @override
  final double monthlyWorkedHours;

  @HiveField(11)
  @override
  final double normalHourValue;

  @HiveField(12)
  @override
  final double hour50Value;

  @HiveField(13)
  @override
  final double hour100Value;

  @HiveField(14)
  @override
  final double nightHourValue;

  @HiveField(15)
  @override
  final double sundayHolidayHourValue;

  @HiveField(16)
  @override
  final double total50;

  @HiveField(17)
  @override
  final double total100;

  @HiveField(18)
  @override
  final double totalNightAdditional;

  @HiveField(19)
  @override
  final double totalSundayHoliday;

  @HiveField(20)
  @override
  final double dsrOvertime;

  @HiveField(21)
  @override
  final double totalOvertime;

  @HiveField(22)
  @override
  final double vacationReflection;

  @HiveField(23)
  @override
  final double thirteenthReflection;

  @HiveField(24)
  @override
  final double grossTotal;

  @HiveField(25)
  @override
  final double inssDiscount;

  @HiveField(26)
  @override
  final double inssRate;

  @HiveField(27)
  @override
  final double irrfDiscount;

  @HiveField(28)
  @override
  final double irrfRate;

  @HiveField(29)
  @override
  final double netTotal;

  @HiveField(30)
  @override
  final double totalOvertimeHours;

  @HiveField(31)
  @override
  final DateTime calculatedAt;

  const OvertimeCalculationModel({
    required this.id,
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
    required this.calculatedAt,
  }) : super(
          id: id,
          grossSalary: grossSalary,
          weeklyHours: weeklyHours,
          hours50: hours50,
          hours100: hours100,
          nightHours: nightHours,
          nightAdditionalPercentage: nightAdditionalPercentage,
          sundayHolidayHours: sundayHolidayHours,
          workDaysMonth: workDaysMonth,
          dependents: dependents,
          monthlyWorkedHours: monthlyWorkedHours,
          normalHourValue: normalHourValue,
          hour50Value: hour50Value,
          hour100Value: hour100Value,
          nightHourValue: nightHourValue,
          sundayHolidayHourValue: sundayHolidayHourValue,
          total50: total50,
          total100: total100,
          totalNightAdditional: totalNightAdditional,
          totalSundayHoliday: totalSundayHoliday,
          dsrOvertime: dsrOvertime,
          totalOvertime: totalOvertime,
          vacationReflection: vacationReflection,
          thirteenthReflection: thirteenthReflection,
          grossTotal: grossTotal,
          inssDiscount: inssDiscount,
          inssRate: inssRate,
          irrfDiscount: irrfDiscount,
          irrfRate: irrfRate,
          netTotal: netTotal,
          totalOvertimeHours: totalOvertimeHours,
          calculatedAt: calculatedAt,
        );

  factory OvertimeCalculationModel.fromEntity(OvertimeCalculation entity) {
    return OvertimeCalculationModel(
      id: entity.id,
      grossSalary: entity.grossSalary,
      weeklyHours: entity.weeklyHours,
      hours50: entity.hours50,
      hours100: entity.hours100,
      nightHours: entity.nightHours,
      nightAdditionalPercentage: entity.nightAdditionalPercentage,
      sundayHolidayHours: entity.sundayHolidayHours,
      workDaysMonth: entity.workDaysMonth,
      dependents: entity.dependents,
      monthlyWorkedHours: entity.monthlyWorkedHours,
      normalHourValue: entity.normalHourValue,
      hour50Value: entity.hour50Value,
      hour100Value: entity.hour100Value,
      nightHourValue: entity.nightHourValue,
      sundayHolidayHourValue: entity.sundayHolidayHourValue,
      total50: entity.total50,
      total100: entity.total100,
      totalNightAdditional: entity.totalNightAdditional,
      totalSundayHoliday: entity.totalSundayHoliday,
      dsrOvertime: entity.dsrOvertime,
      totalOvertime: entity.totalOvertime,
      vacationReflection: entity.vacationReflection,
      thirteenthReflection: entity.thirteenthReflection,
      grossTotal: entity.grossTotal,
      inssDiscount: entity.inssDiscount,
      inssRate: entity.inssRate,
      irrfDiscount: entity.irrfDiscount,
      irrfRate: entity.irrfRate,
      netTotal: entity.netTotal,
      totalOvertimeHours: entity.totalOvertimeHours,
      calculatedAt: entity.calculatedAt,
    );
  }

  OvertimeCalculation toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grossSalary': grossSalary,
      'weeklyHours': weeklyHours,
      'hours50': hours50,
      'hours100': hours100,
      'nightHours': nightHours,
      'nightAdditionalPercentage': nightAdditionalPercentage,
      'sundayHolidayHours': sundayHolidayHours,
      'workDaysMonth': workDaysMonth,
      'dependents': dependents,
      'monthlyWorkedHours': monthlyWorkedHours,
      'normalHourValue': normalHourValue,
      'hour50Value': hour50Value,
      'hour100Value': hour100Value,
      'nightHourValue': nightHourValue,
      'sundayHolidayHourValue': sundayHolidayHourValue,
      'total50': total50,
      'total100': total100,
      'totalNightAdditional': totalNightAdditional,
      'totalSundayHoliday': totalSundayHoliday,
      'dsrOvertime': dsrOvertime,
      'totalOvertime': totalOvertime,
      'vacationReflection': vacationReflection,
      'thirteenthReflection': thirteenthReflection,
      'grossTotal': grossTotal,
      'inssDiscount': inssDiscount,
      'inssRate': inssRate,
      'irrfDiscount': irrfDiscount,
      'irrfRate': irrfRate,
      'netTotal': netTotal,
      'totalOvertimeHours': totalOvertimeHours,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory OvertimeCalculationModel.fromJson(Map<String, dynamic> json) {
    return OvertimeCalculationModel(
      id: json['id'] as String,
      grossSalary: (json['grossSalary'] as num).toDouble(),
      weeklyHours: json['weeklyHours'] as int,
      hours50: (json['hours50'] as num).toDouble(),
      hours100: (json['hours100'] as num).toDouble(),
      nightHours: (json['nightHours'] as num).toDouble(),
      nightAdditionalPercentage:
          (json['nightAdditionalPercentage'] as num).toDouble(),
      sundayHolidayHours: (json['sundayHolidayHours'] as num).toDouble(),
      workDaysMonth: json['workDaysMonth'] as int,
      dependents: json['dependents'] as int,
      monthlyWorkedHours: (json['monthlyWorkedHours'] as num).toDouble(),
      normalHourValue: (json['normalHourValue'] as num).toDouble(),
      hour50Value: (json['hour50Value'] as num).toDouble(),
      hour100Value: (json['hour100Value'] as num).toDouble(),
      nightHourValue: (json['nightHourValue'] as num).toDouble(),
      sundayHolidayHourValue:
          (json['sundayHolidayHourValue'] as num).toDouble(),
      total50: (json['total50'] as num).toDouble(),
      total100: (json['total100'] as num).toDouble(),
      totalNightAdditional: (json['totalNightAdditional'] as num).toDouble(),
      totalSundayHoliday: (json['totalSundayHoliday'] as num).toDouble(),
      dsrOvertime: (json['dsrOvertime'] as num).toDouble(),
      totalOvertime: (json['totalOvertime'] as num).toDouble(),
      vacationReflection: (json['vacationReflection'] as num).toDouble(),
      thirteenthReflection: (json['thirteenthReflection'] as num).toDouble(),
      grossTotal: (json['grossTotal'] as num).toDouble(),
      inssDiscount: (json['inssDiscount'] as num).toDouble(),
      inssRate: (json['inssRate'] as num).toDouble(),
      irrfDiscount: (json['irrfDiscount'] as num).toDouble(),
      irrfRate: (json['irrfRate'] as num).toDouble(),
      netTotal: (json['netTotal'] as num).toDouble(),
      totalOvertimeHours: (json['totalOvertimeHours'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
