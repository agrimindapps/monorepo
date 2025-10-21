import 'package:hive/hive.dart';
import '../../domain/entities/unemployment_insurance_calculation.dart';

part 'unemployment_insurance_calculation_model.g.dart';

@HiveType(typeId: 16)
class UnemploymentInsuranceCalculationModel extends UnemploymentInsuranceCalculation {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final double averageSalary;

  @HiveField(2)
  @override
  final int workMonths;

  @HiveField(3)
  @override
  final int timesReceived;

  @HiveField(4)
  @override
  final DateTime dismissalDate;

  @HiveField(5)
  @override
  final double installmentValue;

  @HiveField(6)
  @override
  final int numberOfInstallments;

  @HiveField(7)
  @override
  final double totalValue;

  @HiveField(8)
  @override
  final DateTime deadlineToRequest;

  @HiveField(9)
  @override
  final DateTime paymentStart;

  @HiveField(10)
  @override
  final DateTime paymentEnd;

  @HiveField(11)
  @override
  final List<DateTime> paymentSchedule;

  @HiveField(12)
  @override
  final bool eligible;

  @HiveField(13)
  @override
  final String ineligibilityReason;

  @HiveField(14)
  @override
  final int requiredCarencyMonths;

  @HiveField(15)
  @override
  final DateTime calculatedAt;

  const UnemploymentInsuranceCalculationModel({
    required this.id,
    required this.averageSalary,
    required this.workMonths,
    required this.timesReceived,
    required this.dismissalDate,
    required this.installmentValue,
    required this.numberOfInstallments,
    required this.totalValue,
    required this.deadlineToRequest,
    required this.paymentStart,
    required this.paymentEnd,
    required this.paymentSchedule,
    required this.eligible,
    required this.ineligibilityReason,
    required this.requiredCarencyMonths,
    required this.calculatedAt,
  }) : super(
          id: id,
          averageSalary: averageSalary,
          workMonths: workMonths,
          timesReceived: timesReceived,
          dismissalDate: dismissalDate,
          installmentValue: installmentValue,
          numberOfInstallments: numberOfInstallments,
          totalValue: totalValue,
          deadlineToRequest: deadlineToRequest,
          paymentStart: paymentStart,
          paymentEnd: paymentEnd,
          paymentSchedule: paymentSchedule,
          eligible: eligible,
          ineligibilityReason: ineligibilityReason,
          requiredCarencyMonths: requiredCarencyMonths,
          calculatedAt: calculatedAt,
        );

  factory UnemploymentInsuranceCalculationModel.fromEntity(UnemploymentInsuranceCalculation entity) {
    return UnemploymentInsuranceCalculationModel(
      id: entity.id,
      averageSalary: entity.averageSalary,
      workMonths: entity.workMonths,
      timesReceived: entity.timesReceived,
      dismissalDate: entity.dismissalDate,
      installmentValue: entity.installmentValue,
      numberOfInstallments: entity.numberOfInstallments,
      totalValue: entity.totalValue,
      deadlineToRequest: entity.deadlineToRequest,
      paymentStart: entity.paymentStart,
      paymentEnd: entity.paymentEnd,
      paymentSchedule: entity.paymentSchedule,
      eligible: entity.eligible,
      ineligibilityReason: entity.ineligibilityReason,
      requiredCarencyMonths: entity.requiredCarencyMonths,
      calculatedAt: entity.calculatedAt,
    );
  }

  UnemploymentInsuranceCalculation toEntity() => this;
}
