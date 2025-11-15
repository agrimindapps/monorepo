
import '../../domain/entities/vacation_calculation.dart';


/// Hive adapter for VacationCalculation entity
class VacationCalculationModel extends VacationCalculation {
  @override
  final String id;

  @override
  final double grossSalary;

  @override
  final int vacationDays;

  @override
  final bool sellVacationDays;

  @override
  final double baseValue;

  @override
  final double constitutionalBonus;

  @override
  final double soldDaysValue;

  @override
  final double grossTotal;

  @override
  final double inssDiscount;

  @override
  final double irDiscount;

  @override
  final double netTotal;

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
