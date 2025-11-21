import 'enums/billing_issue_type.dart';

/// Billing issue entity
/// Represents billing problems that need attention
class BillingIssueEntity {
  final String id;
  final String? billingIssueCode;
  final BillingIssueType type;
  final String message;
  final String? localizedMessage;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final String? resolutionAction;
  final int retryCount;
  final DateTime? nextRetryAt;
  final DateTime lastUpdated;

  const BillingIssueEntity({
    required this.id,
    this.billingIssueCode,
    required this.type,
    required this.message,
    this.localizedMessage,
    required this.detectedAt,
    this.resolvedAt,
    this.resolutionAction,
    required this.retryCount,
    this.nextRetryAt,
    required this.lastUpdated,
  });

  /// Factory constructor for default/initial state
  factory BillingIssueEntity.initial(BillingIssueType type, String message) {
    final now = DateTime.now();
    return BillingIssueEntity(
      id: 'issue-${now.millisecondsSinceEpoch}',
      billingIssueCode: null,
      type: type,
      message: message,
      localizedMessage: message,
      detectedAt: now,
      resolvedAt: null,
      resolutionAction: null,
      retryCount: 0,
      nextRetryAt: null,
      lastUpdated: now,
    );
  }

  /// Create a copy with modified fields
  BillingIssueEntity copyWith({
    String? id,
    String? billingIssueCode,
    BillingIssueType? type,
    String? message,
    String? localizedMessage,
    DateTime? detectedAt,
    DateTime? resolvedAt,
    String? resolutionAction,
    int? retryCount,
    DateTime? nextRetryAt,
    DateTime? lastUpdated,
  }) {
    return BillingIssueEntity(
      id: id ?? this.id,
      billingIssueCode: billingIssueCode ?? this.billingIssueCode,
      type: type ?? this.type,
      message: message ?? this.message,
      localizedMessage: localizedMessage ?? this.localizedMessage,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionAction: resolutionAction ?? this.resolutionAction,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if issue needs user attention
  bool get needsAttention => resolvedAt == null;

  /// Check if issue has been resolved
  bool get isResolved => resolvedAt != null;

  /// Check if retry is possible
  bool get canRetry {
    if (retryCount >= 3) return false;
    if (nextRetryAt == null) return true;
    return DateTime.now().isAfter(nextRetryAt!);
  }

  /// Get time until next retry attempt
  Duration? get timeUntilRetry {
    if (nextRetryAt == null) return null;
    final remaining = nextRetryAt!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Get how long this issue has been active
  Duration get activeDuration {
    return DateTime.now().difference(detectedAt);
  }

  /// Check if issue is critical and requires immediate action
  bool get isCritical => type.isCritical;

  /// Check if issue requires user action
  bool get requiresUserAction => type.requiresAction;

  /// Get human readable error message
  String get displayMessage => localizedMessage ?? message;

  /// Get suggested action for user
  String get suggestedAction {
    switch (type) {
      case BillingIssueType.paymentFailed:
        return 'Atualize seu método de pagamento';
      case BillingIssueType.paymentMethodExpired:
        return 'Seu cartão expirou. Atualize os dados de pagamento';
      case BillingIssueType.billingAddressInvalid:
        return 'Verifique seu endereço de cobrança';
      case BillingIssueType.accountHeld:
        return 'Contate o suporte de cobrança';
      case BillingIssueType.insufficientFunds:
        return 'Fundos insuficientes em sua conta';
      case BillingIssueType.fraudDetected:
        return 'Contate o suporte de segurança';
      case BillingIssueType.taxIssue:
        return 'Verifique suas informações de imposto';
      case BillingIssueType.productNotFound:
        return 'O produto não está mais disponível';
      case BillingIssueType.unknown:
        return 'Tente novamente mais tarde';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingIssueEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          message == other.message &&
          detectedAt == other.detectedAt &&
          resolvedAt == other.resolvedAt &&
          retryCount == other.retryCount;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      message.hashCode ^
      detectedAt.hashCode ^
      resolvedAt.hashCode ^
      retryCount.hashCode;

  @override
  String toString() {
    return '''BillingIssueEntity(
      id: $id,
      type: ${type.displayName},
      message: $message,
      detectedAt: $detectedAt,
      needsAttention: $needsAttention,
      canRetry: $canRetry,
      isCritical: $isCritical,
      retryCount: $retryCount/3,
    )''';
  }
}
