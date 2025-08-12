/// Resultado de uma operação de restauração de compras
class RestoreResult {
  final bool success;
  final String message;
  final List<String>? restoredProducts;
  final int restoredCount;

  const RestoreResult({
    required this.success,
    required this.message,
    this.restoredProducts,
    this.restoredCount = 0,
  });

  /// Factory para criar resultado de sucesso
  factory RestoreResult.success({
    List<String>? restoredProducts,
    String? customMessage,
  }) {
    final count = restoredProducts?.length ?? 0;
    final message = customMessage ?? 
        (count > 0 
          ? '$count compra${count > 1 ? 's' : ''} restaurada${count > 1 ? 's' : ''} com sucesso'
          : 'Compras restauradas com sucesso');
    
    return RestoreResult(
      success: true,
      message: message,
      restoredProducts: restoredProducts,
      restoredCount: count,
    );
  }

  /// Factory para quando não há compras para restaurar
  factory RestoreResult.noSubscriptions() {
    return const RestoreResult(
      success: false,
      message: 'Nenhuma assinatura encontrada para restaurar',
      restoredCount: 0,
    );
  }

  /// Factory para criar resultado de erro
  factory RestoreResult.error(String errorMessage) {
    return RestoreResult(
      success: false,
      message: 'Erro ao restaurar compras: $errorMessage',
      restoredCount: 0,
    );
  }

  /// Verifica se alguma compra foi restaurada
  bool get hasRestoredItems => restoredCount > 0;

  @override
  String toString() {
    if (success) {
      return 'RestoreResult.success(count: $restoredCount, products: $restoredProducts)';
    } else {
      return 'RestoreResult.error($message)';
    }
  }
}