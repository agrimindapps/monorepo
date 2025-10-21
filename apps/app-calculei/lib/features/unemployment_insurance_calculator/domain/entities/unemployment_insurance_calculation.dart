import 'package:equatable/equatable.dart';

class UnemploymentInsuranceCalculation extends Equatable {
  // Input fields
  final String id;
  final double averageSalary;
  final int workMonths;
  final int timesReceived;
  final DateTime dismissalDate;

  // Calculated results
  final double installmentValue;
  final int numberOfInstallments;
  final double totalValue;
  final DateTime deadlineToRequest;
  final DateTime paymentStart;
  final DateTime paymentEnd;
  final List<DateTime> paymentSchedule;
  final bool eligible;
  final String ineligibilityReason;
  final int requiredCarencyMonths;

  // Metadata
  final DateTime calculatedAt;

  const UnemploymentInsuranceCalculation({
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
  });

  @override
  List<Object?> get props => [
    id,
    averageSalary,
    workMonths,
    timesReceived,
    dismissalDate,
    installmentValue,
    numberOfInstallments,
    totalValue,
    deadlineToRequest,
    paymentStart,
    paymentEnd,
    paymentSchedule,
    eligible,
    ineligibilityReason,
    requiredCarencyMonths,
    calculatedAt,
  ];

  UnemploymentInsuranceCalculation copyWith({
    String? id,
    double? averageSalary,
    int? workMonths,
    int? timesReceived,
    DateTime? dismissalDate,
    double? installmentValue,
    int? numberOfInstallments,
    double? totalValue,
    DateTime? deadlineToRequest,
    DateTime? paymentStart,
    DateTime? paymentEnd,
    List<DateTime>? paymentSchedule,
    bool? eligible,
    String? ineligibilityReason,
    int? requiredCarencyMonths,
    DateTime? calculatedAt,
  }) {
    return UnemploymentInsuranceCalculation(
      id: id ?? this.id,
      averageSalary: averageSalary ?? this.averageSalary,
      workMonths: workMonths ?? this.workMonths,
      timesReceived: timesReceived ?? this.timesReceived,
      dismissalDate: dismissalDate ?? this.dismissalDate,
      installmentValue: installmentValue ?? this.installmentValue,
      numberOfInstallments: numberOfInstallments ?? this.numberOfInstallments,
      totalValue: totalValue ?? this.totalValue,
      deadlineToRequest: deadlineToRequest ?? this.deadlineToRequest,
      paymentStart: paymentStart ?? this.paymentStart,
      paymentEnd: paymentEnd ?? this.paymentEnd,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      eligible: eligible ?? this.eligible,
      ineligibilityReason: ineligibilityReason ?? this.ineligibilityReason,
      requiredCarencyMonths: requiredCarencyMonths ?? this.requiredCarencyMonths,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
