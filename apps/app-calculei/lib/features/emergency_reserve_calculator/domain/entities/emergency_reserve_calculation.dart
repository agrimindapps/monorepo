import 'package:equatable/equatable.dart';

class EmergencyReserveCalculation extends Equatable {
  // Input fields
  final String id;
  final double monthlyExpenses;
  final double extraExpenses;
  final int desiredMonths;
  final double monthlySavings;

  // Calculated results
  final double totalMonthlyExpenses;
  final double totalReserveAmount;
  final int constructionYears;
  final int constructionMonths;
  final String category;
  final String categoryDescription;

  // Metadata
  final DateTime calculatedAt;

  const EmergencyReserveCalculation({
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
  });

  @override
  List<Object?> get props => [
    id,
    monthlyExpenses,
    extraExpenses,
    desiredMonths,
    monthlySavings,
    totalMonthlyExpenses,
    totalReserveAmount,
    constructionYears,
    constructionMonths,
    category,
    categoryDescription,
    calculatedAt,
  ];

  EmergencyReserveCalculation copyWith({
    String? id,
    double? monthlyExpenses,
    double? extraExpenses,
    int? desiredMonths,
    double? monthlySavings,
    double? totalMonthlyExpenses,
    double? totalReserveAmount,
    int? constructionYears,
    int? constructionMonths,
    String? category,
    String? categoryDescription,
    DateTime? calculatedAt,
  }) {
    return EmergencyReserveCalculation(
      id: id ?? this.id,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      extraExpenses: extraExpenses ?? this.extraExpenses,
      desiredMonths: desiredMonths ?? this.desiredMonths,
      monthlySavings: monthlySavings ?? this.monthlySavings,
      totalMonthlyExpenses: totalMonthlyExpenses ?? this.totalMonthlyExpenses,
      totalReserveAmount: totalReserveAmount ?? this.totalReserveAmount,
      constructionYears: constructionYears ?? this.constructionYears,
      constructionMonths: constructionMonths ?? this.constructionMonths,
      category: category ?? this.category,
      categoryDescription: categoryDescription ?? this.categoryDescription,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
