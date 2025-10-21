import 'package:hive/hive.dart';
import '../../domain/entities/cash_vs_installment_calculation.dart';

part 'cash_vs_installment_calculation_model.g.dart';

@HiveType(typeId: 15)
class CashVsInstallmentCalculationModel extends CashVsInstallmentCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double cashPrice;

  @HiveField(2)
  @override
  final double installmentPrice;

  @HiveField(3)
  @override
  final int numberOfInstallments;

  @HiveField(4)
  @override
  final double monthlyInterestRate;

  @HiveField(5)
  @override
  final double totalInstallmentPrice;

  @HiveField(6)
  @override
  final double implicitRate;

  @HiveField(7)
  @override
  final double presentValueOfInstallments;

  @HiveField(8)
  @override
  final String bestOption;

  @HiveField(9)
  @override
  final double savingsOrAdditionalCost;

  @HiveField(10)
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

  factory CashVsInstallmentCalculationModel.fromEntity(CashVsInstallmentCalculation entity) {
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
}
