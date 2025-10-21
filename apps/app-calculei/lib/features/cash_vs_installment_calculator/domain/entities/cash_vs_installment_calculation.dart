import 'package:equatable/equatable.dart';

class CashVsInstallmentCalculation extends Equatable {
  // Input fields
  final String id;
  final double cashPrice;
  final double installmentPrice;
  final int numberOfInstallments;
  final double monthlyInterestRate;

  // Calculated results
  final double totalInstallmentPrice;
  final double implicitRate;
  final double presentValueOfInstallments;
  final String bestOption;
  final double savingsOrAdditionalCost;

  // Metadata
  final DateTime calculatedAt;

  const CashVsInstallmentCalculation({
    required this.id,
    required this.cashPrice,
    required this.installmentPrice,
    required this.numberOfInstallments,
    required this.monthlyInterestRate,
    required this.totalInstallmentPrice,
    required this.implicitRate,
    required this.presentValueOfInstallments,
    required this.bestOption,
    required this.savingsOrAdditionalCost,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    cashPrice,
    installmentPrice,
    numberOfInstallments,
    monthlyInterestRate,
    totalInstallmentPrice,
    implicitRate,
    presentValueOfInstallments,
    bestOption,
    savingsOrAdditionalCost,
    calculatedAt,
  ];

  CashVsInstallmentCalculation copyWith({
    String? id,
    double? cashPrice,
    double? installmentPrice,
    int? numberOfInstallments,
    double? monthlyInterestRate,
    double? totalInstallmentPrice,
    double? implicitRate,
    double? presentValueOfInstallments,
    String? bestOption,
    double? savingsOrAdditionalCost,
    DateTime? calculatedAt,
  }) {
    return CashVsInstallmentCalculation(
      id: id ?? this.id,
      cashPrice: cashPrice ?? this.cashPrice,
      installmentPrice: installmentPrice ?? this.installmentPrice,
      numberOfInstallments: numberOfInstallments ?? this.numberOfInstallments,
      monthlyInterestRate: monthlyInterestRate ?? this.monthlyInterestRate,
      totalInstallmentPrice: totalInstallmentPrice ?? this.totalInstallmentPrice,
      implicitRate: implicitRate ?? this.implicitRate,
      presentValueOfInstallments: presentValueOfInstallments ?? this.presentValueOfInstallments,
      bestOption: bestOption ?? this.bestOption,
      savingsOrAdditionalCost: savingsOrAdditionalCost ?? this.savingsOrAdditionalCost,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
