import '../../domain/entities/unemployment_insurance_calculation.dart';

class UnemploymentInsuranceCalculationModel
    extends UnemploymentInsuranceCalculation {
  @override
  final String id;

  @override
  final double averageSalary;

  @override
  final int workMonths;

  @override
  final int timesReceived;

  @override
  final DateTime dismissalDate;

  @override
  final double installmentValue;

  @override
  final int numberOfInstallments;

  @override
  final double totalValue;

  @override
  final DateTime deadlineToRequest;

  @override
  final DateTime paymentStart;

  @override
  final DateTime paymentEnd;

  @override
  final List<DateTime> paymentSchedule;

  @override
  final bool eligible;

  @override
  final String ineligibilityReason;

  @override
  final int requiredCarencyMonths;

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

  factory UnemploymentInsuranceCalculationModel.fromEntity(
    UnemploymentInsuranceCalculation entity,
  ) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'averageSalary': averageSalary,
      'workMonths': workMonths,
      'timesReceived': timesReceived,
      'dismissalDate': dismissalDate.toIso8601String(),
      'installmentValue': installmentValue,
      'numberOfInstallments': numberOfInstallments,
      'totalValue': totalValue,
      'deadlineToRequest': deadlineToRequest.toIso8601String(),
      'paymentStart': paymentStart.toIso8601String(),
      'paymentEnd': paymentEnd.toIso8601String(),
      'paymentSchedule': paymentSchedule
          .map((date) => date.toIso8601String())
          .toList(),
      'eligible': eligible,
      'ineligibilityReason': ineligibilityReason,
      'requiredCarencyMonths': requiredCarencyMonths,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory UnemploymentInsuranceCalculationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnemploymentInsuranceCalculationModel(
      id: json['id'] as String,
      averageSalary: (json['averageSalary'] as num).toDouble(),
      workMonths: json['workMonths'] as int,
      timesReceived: json['timesReceived'] as int,
      dismissalDate: DateTime.parse(json['dismissalDate'] as String),
      installmentValue: (json['installmentValue'] as num).toDouble(),
      numberOfInstallments: json['numberOfInstallments'] as int,
      totalValue: (json['totalValue'] as num).toDouble(),
      deadlineToRequest: DateTime.parse(json['deadlineToRequest'] as String),
      paymentStart: DateTime.parse(json['paymentStart'] as String),
      paymentEnd: DateTime.parse(json['paymentEnd'] as String),
      paymentSchedule: (json['paymentSchedule'] as List<dynamic>)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      eligible: json['eligible'] as bool,
      ineligibilityReason: json['ineligibilityReason'] as String,
      requiredCarencyMonths: json['requiredCarencyMonths'] as int,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}
