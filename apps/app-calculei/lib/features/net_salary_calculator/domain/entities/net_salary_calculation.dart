import 'package:equatable/equatable.dart';

class NetSalaryCalculation extends Equatable {
  // Input fields
  final String id;
  final double grossSalary;
  final int dependents;
  final double transportationVoucher;
  final double healthInsurance;
  final double otherDiscounts;

  // Calculated results
  final double inssDiscount;
  final double irrfDiscount;
  final double transportationVoucherDiscount;
  final double totalDiscounts;
  final double netSalary;
  final double inssRate;
  final double irrfRate;
  final double irrfCalculationBase;

  // Metadata
  final DateTime calculatedAt;

  const NetSalaryCalculation({
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
  });

  @override
  List<Object?> get props => [
    id,
    grossSalary,
    dependents,
    transportationVoucher,
    healthInsurance,
    otherDiscounts,
    inssDiscount,
    irrfDiscount,
    transportationVoucherDiscount,
    totalDiscounts,
    netSalary,
    inssRate,
    irrfRate,
    irrfCalculationBase,
    calculatedAt,
  ];

  NetSalaryCalculation copyWith({
    String? id,
    double? grossSalary,
    int? dependents,
    double? transportationVoucher,
    double? healthInsurance,
    double? otherDiscounts,
    double? inssDiscount,
    double? irrfDiscount,
    double? transportationVoucherDiscount,
    double? totalDiscounts,
    double? netSalary,
    double? inssRate,
    double? irrfRate,
    double? irrfCalculationBase,
    DateTime? calculatedAt,
  }) {
    return NetSalaryCalculation(
      id: id ?? this.id,
      grossSalary: grossSalary ?? this.grossSalary,
      dependents: dependents ?? this.dependents,
      transportationVoucher: transportationVoucher ?? this.transportationVoucher,
      healthInsurance: healthInsurance ?? this.healthInsurance,
      otherDiscounts: otherDiscounts ?? this.otherDiscounts,
      inssDiscount: inssDiscount ?? this.inssDiscount,
      irrfDiscount: irrfDiscount ?? this.irrfDiscount,
      transportationVoucherDiscount: transportationVoucherDiscount ?? this.transportationVoucherDiscount,
      totalDiscounts: totalDiscounts ?? this.totalDiscounts,
      netSalary: netSalary ?? this.netSalary,
      inssRate: inssRate ?? this.inssRate,
      irrfRate: irrfRate ?? this.irrfRate,
      irrfCalculationBase: irrfCalculationBase ?? this.irrfCalculationBase,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
