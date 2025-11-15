import '../../domain/entities/emergency_reserve_calculation.dart';

class EmergencyReserveCalculationModel extends EmergencyReserveCalculation {
  @override
  final String id;

  @override
  final double monthlyExpenses;

  @override
  final double extraExpenses;

  @override
  final int desiredMonths;

  @override
  final double monthlySavings;

  @override
  final double totalMonthlyExpenses;

  @override
  final double totalReserveAmount;

  @override
  final int constructionYears;

  @override
  final int constructionMonths;

  @override
  final String category;

  @override
  final String categoryDescription;

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

  factory EmergencyReserveCalculationModel.fromEntity(
    EmergencyReserveCalculation entity,
  ) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthlyExpenses': monthlyExpenses,
      'extraExpenses': extraExpenses,
      'desiredMonths': desiredMonths,
      'monthlySavings': monthlySavings,
      'totalMonthlyExpenses': totalMonthlyExpenses,
      'totalReserveAmount': totalReserveAmount,
      'constructionYears': constructionYears,
      'constructionMonths': constructionMonths,
      'category': category,
      'categoryDescription': categoryDescription,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory EmergencyReserveCalculationModel.fromJson(Map<String, dynamic> json) {
    return EmergencyReserveCalculationModel(
      id: json['id'] as String,
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      extraExpenses: (json['extraExpenses'] as num).toDouble(),
      desiredMonths: json['desiredMonths'] as int,
      monthlySavings: (json['monthlySavings'] as num).toDouble(),
      totalMonthlyExpenses: (json['totalMonthlyExpenses'] as num).toDouble(),
      totalReserveAmount: (json['totalReserveAmount'] as num).toDouble(),
      constructionYears: json['constructionYears'] as int,
      constructionMonths: json['constructionMonths'] as int,
      category: json['category'] as String,
      categoryDescription: json['categoryDescription'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
