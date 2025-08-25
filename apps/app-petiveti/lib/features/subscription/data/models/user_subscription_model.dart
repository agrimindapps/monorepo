import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import 'subscription_plan_model.dart';

class UserSubscriptionModel extends UserSubscription {
  const UserSubscriptionModel({
    required super.id,
    required super.userId,
    required super.planId,
    required super.plan,
    required super.status,
    required super.startDate,
    super.expirationDate,
    super.cancelledAt,
    super.pausedAt,
    super.autoRenew,
    super.transactionId,
    super.receiptData,
    super.isTrialPeriod,
    super.trialEndDate,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserSubscriptionModel.fromMap(Map<String, dynamic> map) {
    return UserSubscriptionModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      planId: map['planId']?.toString() ?? '',
      plan: SubscriptionPlanModel.fromMap((map['plan'] as Map<String, dynamic>?) ?? {}),
      status: PlanStatus.values.firstWhere(
        (e) => e.toString() == 'PlanStatus.${map['status']}',
        orElse: () => PlanStatus.pending,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch((map['startDate'] as int?) ?? 0),
      expirationDate: map['expirationDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['expirationDate'] as int))
          : null,
      cancelledAt: map['cancelledAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['cancelledAt'] as int))
          : null,
      pausedAt: map['pausedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['pausedAt'] as int))
          : null,
      autoRenew: (map['autoRenew'] as bool?) ?? true,
      transactionId: map['transactionId']?.toString(),
      receiptData: map['receiptData']?.toString(),
      isTrialPeriod: (map['isTrialPeriod'] as bool?) ?? false,
      trialEndDate: map['trialEndDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((map['trialEndDate'] as int))
          : null,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updatedAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'plan': (plan as SubscriptionPlanModel).toMap(),
      'status': status.toString().split('.').last,
      'startDate': startDate.millisecondsSinceEpoch,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'pausedAt': pausedAt?.millisecondsSinceEpoch,
      'autoRenew': autoRenew,
      'transactionId': transactionId,
      'receiptData': receiptData,
      'isTrialPeriod': isTrialPeriod,
      'trialEndDate': trialEndDate?.millisecondsSinceEpoch,
      'metadata': metadata,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserSubscriptionModel.fromEntity(UserSubscription subscription) {
    return UserSubscriptionModel(
      id: subscription.id,
      userId: subscription.userId,
      planId: subscription.planId,
      plan: subscription.plan,
      status: subscription.status,
      startDate: subscription.startDate,
      expirationDate: subscription.expirationDate,
      cancelledAt: subscription.cancelledAt,
      pausedAt: subscription.pausedAt,
      autoRenew: subscription.autoRenew,
      transactionId: subscription.transactionId,
      receiptData: subscription.receiptData,
      isTrialPeriod: subscription.isTrialPeriod,
      trialEndDate: subscription.trialEndDate,
      metadata: subscription.metadata,
      createdAt: subscription.createdAt,
      updatedAt: subscription.updatedAt,
    );
  }

  @override
  UserSubscriptionModel copyWith({
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
    return UserSubscriptionModel(
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
}