/// Resultado de uma operação de compra
class PurchaseResult {
  final bool success;
  final String? error;
  final String? productId;
  final DateTime? purchaseDate;
  final double? price;
  final String? currency;

  const PurchaseResult({
    required this.success,
    this.error,
    this.productId,
    this.purchaseDate,
    this.price,
    this.currency,
  });

  /// Factory para criar resultado de sucesso
  factory PurchaseResult.success({
    required String productId,
    DateTime? purchaseDate,
    double? price,
    String? currency,
  }) {
    return PurchaseResult(
      success: true,
      productId: productId,
      purchaseDate: purchaseDate ?? DateTime.now(),
      price: price,
      currency: currency,
    );
  }

  /// Factory para criar resultado de erro
  factory PurchaseResult.error(String errorMessage) {
    return PurchaseResult(
      success: false,
      error: errorMessage,
    );
  }

  /// Factory para cancelamento
  factory PurchaseResult.cancelled() {
    return const PurchaseResult(
      success: false,
      error: 'Compra cancelada pelo usuário',
    );
  }

  @override
  String toString() {
    if (success) {
      return 'PurchaseResult.success(productId: $productId, purchaseDate: $purchaseDate)';
    } else {
      return 'PurchaseResult.error($error)';
    }
  }
}