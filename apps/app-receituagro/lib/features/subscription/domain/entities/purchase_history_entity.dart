import 'enums/purchase_status.dart';
import 'enums/purchase_type.dart';
import 'package:core/core.dart' hide PurchaseType;

/// Purchase history entity
/// Represents a purchase transaction in the user's history
class PurchaseHistoryEntity {
  final String id;
  final String productId;
  final String? transactionId;
  final PurchaseType type;
  final double amount;
  final String currency;
  final Store store;
  final DateTime purchaseDate;
  final DateTime? originalPurchaseDate;
  final PurchaseStatus status;
  final String? failureReason;
  final int quantity;
  final DateTime lastUpdated;
  final String? receiptUrl;
  final String? invoiceUrl;

  const PurchaseHistoryEntity({
    required this.id,
    required this.productId,
    this.transactionId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.store,
    required this.purchaseDate,
    this.originalPurchaseDate,
    required this.status,
    this.failureReason,
    required this.quantity,
    required this.lastUpdated,
    this.receiptUrl,
    this.invoiceUrl,
  });

  /// Factory constructor for default/initial state
  factory PurchaseHistoryEntity.initial(
    String productId,
    PurchaseType type,
    double amount,
  ) {
    final now = DateTime.now();
    return PurchaseHistoryEntity(
      id: 'purchase-${now.millisecondsSinceEpoch}',
      productId: productId,
      transactionId: null,
      type: type,
      amount: amount,
      currency: 'BRL',
      store: Store.unknown,
      purchaseDate: now,
      originalPurchaseDate: null,
      status: PurchaseStatus.pending,
      failureReason: null,
      quantity: 1,
      lastUpdated: now,
      receiptUrl: null,
      invoiceUrl: null,
    );
  }

  /// Create a copy with modified fields
  PurchaseHistoryEntity copyWith({
    String? id,
    String? productId,
    String? transactionId,
    PurchaseType? type,
    double? amount,
    String? currency,
    Store? store,
    DateTime? purchaseDate,
    DateTime? originalPurchaseDate,
    PurchaseStatus? status,
    String? failureReason,
    int? quantity,
    DateTime? lastUpdated,
    String? receiptUrl,
    String? invoiceUrl,
  }) {
    return PurchaseHistoryEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      store: store ?? this.store,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      originalPurchaseDate: originalPurchaseDate ?? this.originalPurchaseDate,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
    );
  }

  /// Check if purchase is pending
  bool get isPending => status == PurchaseStatus.pending;

  /// Check if purchase is completed successfully
  bool get isCompleted => status == PurchaseStatus.completed;

  /// Check if purchase failed
  bool get isFailed => status == PurchaseStatus.failed;

  /// Check if purchase was refunded
  bool get isRefunded => status == PurchaseStatus.refunded;

  /// Check if purchase was successful
  bool get isSuccessful => status.isSuccessful;

  /// Get total amount (considering quantity)
  double get totalAmount => amount * quantity;

  /// Get formatted amount for display
  String get formattedAmount {
    return '${currency == 'BRL' ? 'R\$ ' : ''}${amount.toStringAsFixed(2)}';
  }

  /// Get formatted total amount
  String get formattedTotalAmount {
    return '${currency == 'BRL' ? 'R\$ ' : ''}${totalAmount.toStringAsFixed(2)}';
  }

  /// Get how long ago this purchase was made
  Duration get timeSincePurchase {
    return DateTime.now().difference(purchaseDate);
  }

  /// Check if purchase is recent (within 24 hours)
  bool get isRecent => timeSincePurchase.inHours < 24;

  /// Get human readable purchase date
  String get formattedPurchaseDate {
    final day = purchaseDate.day.toString().padLeft(2, '0');
    final month = purchaseDate.month.toString().padLeft(2, '0');
    final year = purchaseDate.year;
    final hour = purchaseDate.hour.toString().padLeft(2, '0');
    final minute = purchaseDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year às $hour:$minute';
  }

  /// Get status display name with icon hint
  String get statusDisplay {
    switch (status) {
      case PurchaseStatus.pending:
        return '⏳ ${status.displayName}';
      case PurchaseStatus.completed:
        return '✅ ${status.displayName}';
      case PurchaseStatus.failed:
        return '❌ ${status.displayName}';
      case PurchaseStatus.cancelled:
        return '⛔ ${status.displayName}';
      case PurchaseStatus.refunded:
        return '↩️ ${status.displayName}';
      case PurchaseStatus.processing:
        return '⏳ ${status.displayName}';
      case PurchaseStatus.unknown:
        return '❓ ${status.displayName}';
    }
  }

  /// Check if receipt is available
  bool get hasReceipt => receiptUrl != null && receiptUrl!.isNotEmpty;

  /// Check if invoice is available
  bool get hasInvoice => invoiceUrl != null && invoiceUrl!.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseHistoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          transactionId == other.transactionId &&
          type == other.type &&
          amount == other.amount &&
          status == other.status &&
          purchaseDate == other.purchaseDate;

  @override
  int get hashCode =>
      id.hashCode ^
      productId.hashCode ^
      transactionId.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      status.hashCode ^
      purchaseDate.hashCode;

  @override
  String toString() {
    return '''PurchaseHistoryEntity(
      id: $id,
      productId: $productId,
      type: ${type.displayName},
      amount: $formattedTotalAmount,
      status: ${status.displayName},
      purchaseDate: $formattedPurchaseDate,
      store: ${store.displayName},
      isRecent: $isRecent,
      hasReceipt: $hasReceipt,
      hasInvoice: $hasInvoice,
    )''';
  }
}
