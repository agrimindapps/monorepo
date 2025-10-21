import 'package:hive/hive.dart';

import '../../domain/entities/vacation_calculation.dart';

part 'vacation_calculation_model.g.dart';

/// Hive adapter for VacationCalculation entity
@HiveType(typeId: 10) // Use unique typeId for app-calculei
class VacationCalculationModel extends VacationCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double grossSalary;

  @HiveField(2)
  @override
  final int vacationDays;

  @HiveField(3)
  @override
  final bool sellVacationDays;

  @HiveField(4)
  @override
  final double baseValue;

  @HiveField(5)
  @override
  final double constitutionalBonus;

  @HiveField(6)
  @override
  final double soldDaysValue;

  @HiveField(7)
  @override
  final double grossTotal;

  @HiveField(8)
  @override
  final double inssDiscount;

  @HiveField(9)
  @override
  final double irDiscount;

  @HiveField(10)
  @override
  final double netTotal;

  @HiveField(11)
  @override
  final DateTime calculatedAt;

  const VacationCalculationModel({
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
  }) : super(
          id: id,
          grossSalary: grossSalary,
          vacationDays: vacationDays,
          sellVacationDays: sellVacationDays,
          baseValue: baseValue,
          constitutionalBonus: constitutionalBonus,
          soldDaysValue: soldDaysValue,
          grossTotal: grossTotal,
          inssDiscount: inssDiscount,
          irDiscount: irDiscount,
          netTotal: netTotal,
          calculatedAt: calculatedAt,
        );

  /// Convert from domain entity to data model
  factory VacationCalculationModel.fromEntity(VacationCalculation entity) {
    return VacationCalculationModel(
      id: entity.id,
      grossSalary: entity.grossSalary,
      vacationDays: entity.vacationDays,
      sellVacationDays: entity.sellVacationDays,
      baseValue: entity.baseValue,
      constitutionalBonus: entity.constitutionalBonus,
      soldDaysValue: entity.soldDaysValue,
      grossTotal: entity.grossTotal,
      inssDiscount: entity.inssDiscount,
      irDiscount: entity.irDiscount,
      netTotal: entity.netTotal,
      calculatedAt: entity.calculatedAt,
    );
  }

  /// Convert to domain entity
  VacationCalculation toEntity() {
    return VacationCalculation(
      id: id,
      grossSalary: grossSalary,
      vacationDays: vacationDays,
      sellVacationDays: sellVacationDays,
      baseValue: baseValue,
      constitutionalBonus: constitutionalBonus,
      soldDaysValue: soldDaysValue,
      grossTotal: grossTotal,
      inssDiscount: inssDiscount,
      irDiscount: irDiscount,
      netTotal: netTotal,
      calculatedAt: calculatedAt,
    );
  }

  /// Convert to JSON (for Firebase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grossSalary': grossSalary,
      'vacationDays': vacationDays,
      'sellVacationDays': sellVacationDays,
      'baseValue': baseValue,
      'constitutionalBonus': constitutionalBonus,
      'soldDaysValue': soldDaysValue,
      'grossTotal': grossTotal,
      'inssDiscount': inssDiscount,
      'irDiscount': irDiscount,
      'netTotal': netTotal,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Firebase)
  factory VacationCalculationModel.fromJson(Map<String, dynamic> json) {
    return VacationCalculationModel(
      id: json['id'] as String,
      grossSalary: (json['grossSalary'] as num).toDouble(),
      vacationDays: json['vacationDays'] as int,
      sellVacationDays: json['sellVacationDays'] as bool,
      baseValue: (json['baseValue'] as num).toDouble(),
      constitutionalBonus: (json['constitutionalBonus'] as num).toDouble(),
      soldDaysValue: (json['soldDaysValue'] as num).toDouble(),
      grossTotal: (json['grossTotal'] as num).toDouble(),
      inssDiscount: (json['inssDiscount'] as num).toDouble(),
      irDiscount: (json['irDiscount'] as num).toDouble(),
      netTotal: (json['netTotal'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
