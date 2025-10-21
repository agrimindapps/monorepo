import 'package:hive/hive.dart';
import '../../domain/entities/emergency_reserve_calculation.dart';

part 'emergency_reserve_calculation_model.g.dart';

@HiveType(typeId: 14)
class EmergencyReserveCalculationModel extends EmergencyReserveCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double monthlyExpenses;

  @HiveField(2)
  @override
  final double extraExpenses;

  @HiveField(3)
  @override
  final int desiredMonths;

  @HiveField(4)
  @override
  final double monthlySavings;

  @HiveField(5)
  @override
  final double totalMonthlyExpenses;

  @HiveField(6)
  @override
  final double totalReserveAmount;

  @HiveField(7)
  @override
  final int constructionYears;

  @HiveField(8)
  @override
  final int constructionMonths;

  @HiveField(9)
  @override
  final String category;

  @HiveField(10)
  @override
  final String categoryDescription;

  @HiveField(11)
  @override
  final DateTime calculatedAt;

  const EmergencyReserveCalculationModel({
    required this.id,
    required this.monthlyExpenses,
    required this.extraExpenses,
    required this.desiredMonths,
    required this.monthlySavings,
    required this.totalMonthlyExpenses,
    required this.totalReserveAmount,
    required this.constructionYears,
    required this.constructionMonths,
    required this.category,
    required this.categoryDescription,
    required this.calculatedAt,
  }) : super(
          id: id,
          monthlyExpenses: monthlyExpenses,
          extraExpenses: extraExpenses,
          desiredMonths: desiredMonths,
          monthlySavings: monthlySavings,
          totalMonthlyExpenses: totalMonthlyExpenses,
          totalReserveAmount: totalReserveAmount,
          constructionYears: constructionYears,
          constructionMonths: constructionMonths,
          category: category,
          categoryDescription: categoryDescription,
          calculatedAt: calculatedAt,
        );

  factory EmergencyReserveCalculationModel.fromEntity(EmergencyReserveCalculation entity) {
    return EmergencyReserveCalculationModel(
      id: entity.id,
      monthlyExpenses: entity.monthlyExpenses,
      extraExpenses: entity.extraExpenses,
      desiredMonths: entity.desiredMonths,
      monthlySavings: entity.monthlySavings,
      totalMonthlyExpenses: entity.totalMonthlyExpenses,
      totalReserveAmount: entity.totalReserveAmount,
      constructionYears: entity.constructionYears,
      constructionMonths: entity.constructionMonths,
      category: entity.category,
      categoryDescription: entity.categoryDescription,
      calculatedAt: entity.calculatedAt,
    );
  }

  EmergencyReserveCalculation toEntity() => this;
}
