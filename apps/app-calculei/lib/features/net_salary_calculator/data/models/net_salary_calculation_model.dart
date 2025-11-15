import '../../domain/entities/net_salary_calculation.dart';

class NetSalaryCalculationModel extends NetSalaryCalculation {
  @override
  final String id;

  @override
  final double grossSalary;

  @override
  final int dependents;

  @override
  final double transportationVoucher;

  @override
  final double healthInsurance;

  @override
  final double otherDiscounts;

  @override
  final double inssDiscount;

  @override
  final double irrfDiscount;

  @override
  final double transportationVoucherDiscount;

  @override
  final double totalDiscounts;

  @override
  final double netSalary;

  @override
  final double inssRate;

  @override
  final double irrfRate;

  @override
  final double irrfCalculationBase;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grossSalary': grossSalary,
      'dependents': dependents,
      'transportationVoucher': transportationVoucher,
      'healthInsurance': healthInsurance,
      'otherDiscounts': otherDiscounts,
      'inssDiscount': inssDiscount,
      'irrfDiscount': irrfDiscount,
      'transportationVoucherDiscount': transportationVoucherDiscount,
      'totalDiscounts': totalDiscounts,
      'netSalary': netSalary,
      'inssRate': inssRate,
      'irrfRate': irrfRate,
      'irrfCalculationBase': irrfCalculationBase,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory NetSalaryCalculationModel.fromJson(Map<String, dynamic> json) {
    return NetSalaryCalculationModel(
      id: json['id'] as String,
      grossSalary: (json['grossSalary'] as num).toDouble(),
      dependents: json['dependents'] as int,
      transportationVoucher: (json['transportationVoucher'] as num).toDouble(),
      healthInsurance: (json['healthInsurance'] as num).toDouble(),
      otherDiscounts: (json['otherDiscounts'] as num).toDouble(),
      inssDiscount: (json['inssDiscount'] as num).toDouble(),
      irrfDiscount: (json['irrfDiscount'] as num).toDouble(),
      transportationVoucherDiscount:
          (json['transportationVoucherDiscount'] as num).toDouble(),
      totalDiscounts: (json['totalDiscounts'] as num).toDouble(),
      netSalary: (json['netSalary'] as num).toDouble(),
      inssRate: (json['inssRate'] as num).toDouble(),
      irrfRate: (json['irrfRate'] as num).toDouble(),
      irrfCalculationBase: (json['irrfCalculationBase'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
