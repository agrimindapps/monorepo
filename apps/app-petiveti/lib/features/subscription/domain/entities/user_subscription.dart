import 'package:equatable/equatable.dart';
import 'subscription_plan.dart';

class UserSubscription extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionPlan plan;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime? expirationDate;
  final DateTime? cancelledAt;
  final DateTime? pausedAt;
  final bool autoRenew;
  final String? transactionId;
  final String? receiptData;
  final bool isTrialPeriod;
  final DateTime? trialEndDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.plan,
    required this.status,
    required this.startDate,
    this.expirationDate,
    this.cancelledAt,
    this.pausedAt,
    this.autoRenew = true,
    this.transactionId,
    this.receiptData,
    this.isTrialPeriod = false,
    this.trialEndDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  UserSubscription copyWith({
    String? id,
    String? userId,
    String? planId,
    SubscriptionPlan? plan,
    PlanStatus? status,
    DateTime? startDate,
    DateTime? expirationDate,
    DateTime? cancelledAt,
    DateTime? pausedAt,
    bool? autoRenew,
    String? transactionId,
    String? receiptData,
    bool? isTrialPeriod,
    DateTime? trialEndDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      pausedAt: pausedAt ?? this.pausedAt,
      autoRenew: autoRenew ?? this.autoRenew,
      transactionId: transactionId ?? this.transactionId,
      receiptData: receiptData ?? this.receiptData,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == PlanStatus.active;
  bool get isExpired => status == PlanStatus.expired;
  bool get isCancelled => status == PlanStatus.cancelled;
  bool get isPaused => status == PlanStatus.paused;
  bool get isPending => status == PlanStatus.pending;

  bool get isValidPremium {
    if (!isActive) return false;
    if (expirationDate == null) return true; // Lifetime
    return DateTime.now().isBefore(expirationDate!);
  }

  bool get willExpireSoon {
    if (expirationDate == null) return false;
    final daysUntilExpiration = expirationDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration <= 7 && daysUntilExpiration > 0;
  }

  bool get isInTrialPeriod {
    if (!isTrialPeriod || trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  int get daysUntilTrialEnd {
    if (trialEndDate == null) return -1;
    return trialEndDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        plan,
        status,
        startDate,
        expirationDate,
        cancelledAt,
        pausedAt,
        autoRenew,
        transactionId,
        receiptData,
        isTrialPeriod,
        trialEndDate,
        metadata,
        createdAt,
        updatedAt,
      ];
}