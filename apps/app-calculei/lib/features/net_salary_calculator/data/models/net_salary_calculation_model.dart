import 'package:hive/hive.dart';
import '../../domain/entities/net_salary_calculation.dart';

part 'net_salary_calculation_model.g.dart';

@HiveType(typeId: 13)
class NetSalaryCalculationModel extends NetSalaryCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double grossSalary;

  @HiveField(2)
  @override
  final int dependents;

  @HiveField(3)
  @override
  final double transportationVoucher;

  @HiveField(4)
  @override
  final double healthInsurance;

  @HiveField(5)
  @override
  final double otherDiscounts;

  @HiveField(6)
  @override
  final double inssDiscount;

  @HiveField(7)
  @override
  final double irrfDiscount;

  @HiveField(8)
  @override
  final double transportationVoucherDiscount;

  @HiveField(9)
  @override
  final double totalDiscounts;

  @HiveField(10)
  @override
  final double netSalary;

  @HiveField(11)
  @override
  final double inssRate;

  @HiveField(12)
  @override
  final double irrfRate;

  @HiveField(13)
  @override
  final double irrfCalculationBase;

  @HiveField(14)
  @override
  final DateTime calculatedAt;

  const NetSalaryCalculationModel({
    required this.id,
    required this.grossSalary,
    required this.dependents,
    required this.transportationVoucher,
    required this.healthInsurance,
    required this.otherDiscounts,
    required this.inssDiscount,
    required this.irrfDiscount,
    required this.transportationVoucherDiscount,
    required this.totalDiscounts,
    required this.netSalary,
    required this.inssRate,
    required this.irrfRate,
    required this.irrfCalculationBase,
    required this.calculatedAt,
  }) : super(
          id: id,
          grossSalary: grossSalary,
          dependents: dependents,
          transportationVoucher: transportationVoucher,
          healthInsurance: healthInsurance,
          otherDiscounts: otherDiscounts,
          inssDiscount: inssDiscount,
          irrfDiscount: irrfDiscount,
          transportationVoucherDiscount: transportationVoucherDiscount,
          totalDiscounts: totalDiscounts,
          netSalary: netSalary,
          inssRate: inssRate,
          irrfRate: irrfRate,
          irrfCalculationBase: irrfCalculationBase,
          calculatedAt: calculatedAt,
        );

  factory NetSalaryCalculationModel.fromEntity(NetSalaryCalculation entity) {
    return NetSalaryCalculationModel(
      id: entity.id,
      grossSalary: entity.grossSalary,
      dependents: entity.dependents,
      transportationVoucher: entity.transportationVoucher,
      healthInsurance: entity.healthInsurance,
      otherDiscounts: entity.otherDiscounts,
      inssDiscount: entity.inssDiscount,
      irrfDiscount: entity.irrfDiscount,
      transportationVoucherDiscount: entity.transportationVoucherDiscount,
      totalDiscounts: entity.totalDiscounts,
      netSalary: entity.netSalary,
      inssRate: entity.inssRate,
      irrfRate: entity.irrfRate,
      irrfCalculationBase: entity.irrfCalculationBase,
      calculatedAt: entity.calculatedAt,
    );
  }

  NetSalaryCalculation toEntity() => this;
}
