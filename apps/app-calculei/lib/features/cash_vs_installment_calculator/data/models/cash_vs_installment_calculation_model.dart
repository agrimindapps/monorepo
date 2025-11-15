import '../../domain/entities/cash_vs_installment_calculation.dart';

class CashVsInstallmentCalculationModel extends CashVsInstallmentCalculation {
  @override
  final String id;

  @override
  final double cashPrice;

  @override
  final double installmentPrice;

  @override
  final int numberOfInstallments;

  @override
  final double monthlyInterestRate;

  @override
  final double totalInstallmentPrice;

  @override
  final double implicitRate;

  @override
  final double presentValueOfInstallments;

  @override
  final String bestOption;

  @override
  final double savingsOrAdditionalCost;

  @override
  final DateTime calculatedAt;

  const CashVsInstallmentCalculationModel({
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
  }) : super(
         id: id,
         cashPrice: cashPrice,
         installmentPrice: installmentPrice,
         numberOfInstallments: numberOfInstallments,
         monthlyInterestRate: monthlyInterestRate,
         totalInstallmentPrice: totalInstallmentPrice,
         implicitRate: implicitRate,
         presentValueOfInstallments: presentValueOfInstallments,
         bestOption: bestOption,
         savingsOrAdditionalCost: savingsOrAdditionalCost,
         calculatedAt: calculatedAt,
       );

  factory CashVsInstallmentCalculationModel.fromEntity(
    CashVsInstallmentCalculation entity,
  ) {
    return CashVsInstallmentCalculationModel(
      id: entity.id,
      cashPrice: entity.cashPrice,
      installmentPrice: entity.installmentPrice,
      numberOfInstallments: entity.numberOfInstallments,
      monthlyInterestRate: entity.monthlyInterestRate,
      totalInstallmentPrice: entity.totalInstallmentPrice,
      implicitRate: entity.implicitRate,
      presentValueOfInstallments: entity.presentValueOfInstallments,
      bestOption: entity.bestOption,
      savingsOrAdditionalCost: entity.savingsOrAdditionalCost,
      calculatedAt: entity.calculatedAt,
    );
  }

  CashVsInstallmentCalculation toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashPrice': cashPrice,
      'installmentPrice': installmentPrice,
      'numberOfInstallments': numberOfInstallments,
      'monthlyInterestRate': monthlyInterestRate,
      'totalInstallmentPrice': totalInstallmentPrice,
      'implicitRate': implicitRate,
      'presentValueOfInstallments': presentValueOfInstallments,
      'bestOption': bestOption,
      'savingsOrAdditionalCost': savingsOrAdditionalCost,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory CashVsInstallmentCalculationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CashVsInstallmentCalculationModel(
      id: json['id'] as String,
      cashPrice: (json['cashPrice'] as num).toDouble(),
      installmentPrice: (json['installmentPrice'] as num).toDouble(),
      numberOfInstallments: json['numberOfInstallments'] as int,
      monthlyInterestRate: (json['monthlyInterestRate'] as num).toDouble(),
      totalInstallmentPrice: (json['totalInstallmentPrice'] as num).toDouble(),
      implicitRate: (json['implicitRate'] as num).toDouble(),
      presentValueOfInstallments: (json['presentValueOfInstallments'] as num)
          .toDouble(),
      bestOption: json['bestOption'] as String,
      savingsOrAdditionalCost: (json['savingsOrAdditionalCost'] as num)
          .toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
