// Package imports:
import 'package:purchases_flutter/purchases_flutter.dart';

enum PurchaseState {
  idle,
  loading,
  purchasing,
  restoring,
  success,
  error,
  cancelled,
}

class PurchaseStateData {
  final PurchaseState state;
  final String? errorMessage;
  final Package? purchasedPackage;
  final bool isRestoreOperation;
  final DateTime? timestamp;

  const PurchaseStateData({
    required this.state,
    this.errorMessage,
    this.purchasedPackage,
    this.isRestoreOperation = false,
    this.timestamp,
  });

  bool get isIdle => state == PurchaseState.idle;
  bool get isLoading => state == PurchaseState.loading;
  bool get isPurchasing => state == PurchaseState.purchasing;
  bool get isRestoring => state == PurchaseState.restoring;
  bool get isSuccess => state == PurchaseState.success;
  bool get isError => state == PurchaseState.error;
  bool get isCancelled => state == PurchaseState.cancelled;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isProcessing => isPurchasing || isRestoring || isLoading;

  static PurchaseStateData idle() {
    return const PurchaseStateData(state: PurchaseState.idle);
  }

  static PurchaseStateData loading() {
    return PurchaseStateData(
      state: PurchaseState.loading,
      timestamp: DateTime.now(),
    );
  }

  static PurchaseStateData purchasing(Package package) {
    return PurchaseStateData(
      state: PurchaseState.purchasing,
      purchasedPackage: package,
      timestamp: DateTime.now(),
    );
  }

  static PurchaseStateData restoring() {
    return PurchaseStateData(
      state: PurchaseState.restoring,
      isRestoreOperation: true,
      timestamp: DateTime.now(),
    );
  }

  static PurchaseStateData success({
    Package? package,
    bool isRestore = false,
  }) {
    return PurchaseStateData(
      state: PurchaseState.success,
      purchasedPackage: package,
      isRestoreOperation: isRestore,
      timestamp: DateTime.now(),
    );
  }

  static PurchaseStateData error(String message, {bool isRestore = false}) {
    return PurchaseStateData(
      state: PurchaseState.error,
      errorMessage: message,
      isRestoreOperation: isRestore,
      timestamp: DateTime.now(),
    );
  }

  static PurchaseStateData cancelled({bool isRestore = false}) {
    return PurchaseStateData(
      state: PurchaseState.cancelled,
      isRestoreOperation: isRestore,
      timestamp: DateTime.now(),
    );
  }

  PurchaseStateData copyWith({
    PurchaseState? state,
    String? errorMessage,
    Package? purchasedPackage,
    bool? isRestoreOperation,
    DateTime? timestamp,
  }) {
    return PurchaseStateData(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      purchasedPackage: purchasedPackage ?? this.purchasedPackage,
      isRestoreOperation: isRestoreOperation ?? this.isRestoreOperation,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'PurchaseStateData(state: $state, error: $errorMessage, package: ${purchasedPackage?.identifier}, isRestore: $isRestoreOperation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PurchaseStateData &&
        other.state == state &&
        other.errorMessage == errorMessage &&
        other.purchasedPackage?.identifier == purchasedPackage?.identifier &&
        other.isRestoreOperation == isRestoreOperation;
  }

  @override
  int get hashCode {
    return Object.hash(
      state,
      errorMessage,
      purchasedPackage?.identifier,
      isRestoreOperation,
    );
  }
}

class PurchaseResult {
  final bool success;
  final String? error;
  final Package? package;
  final CustomerInfo? customerInfo;

  const PurchaseResult({
    required this.success,
    this.error,
    this.package,
    this.customerInfo,
  });

  static PurchaseResult successful({
    Package? package,
    CustomerInfo? customerInfo,
  }) {
    return PurchaseResult(
      success: true,
      package: package,
      customerInfo: customerInfo,
    );
  }

  static PurchaseResult failed(String error) {
    return PurchaseResult(
      success: false,
      error: error,
    );
  }

  static PurchaseResult cancelled() {
    return const PurchaseResult(
      success: false,
      error: 'Compra cancelada pelo usuário',
    );
  }

  @override
  String toString() {
    return 'PurchaseResult(success: $success, error: $error, package: ${package?.identifier})';
  }
}

class RestoreResult {
  final bool success;
  final String? error;
  final List<String> restoredProductIds;
  final CustomerInfo? customerInfo;

  const RestoreResult({
    required this.success,
    this.error,
    this.restoredProductIds = const [],
    this.customerInfo,
  });

  bool get hasRestoredProducts => restoredProductIds.isNotEmpty;
  int get restoredCount => restoredProductIds.length;

  static RestoreResult successful({
    List<String> restoredProducts = const [],
    CustomerInfo? customerInfo,
  }) {
    return RestoreResult(
      success: true,
      restoredProductIds: restoredProducts,
      customerInfo: customerInfo,
    );
  }

  static RestoreResult failed(String error) {
    return RestoreResult(
      success: false,
      error: error,
    );
  }

  static RestoreResult noProducts() {
    return const RestoreResult(
      success: true,
      error: 'Nenhuma compra encontrada para restaurar',
    );
  }

  @override
  String toString() {
    return 'RestoreResult(success: $success, error: $error, restored: ${restoredProductIds.length})';
  }
}

class PurchaseStateRepository {
  static String getStateDisplayName(PurchaseState state) {
    switch (state) {
      case PurchaseState.idle:
        return 'Aguardando';
      case PurchaseState.loading:
        return 'Carregando';
      case PurchaseState.purchasing:
        return 'Processando compra';
      case PurchaseState.restoring:
        return 'Restaurando compras';
      case PurchaseState.success:
        return 'Sucesso';
      case PurchaseState.error:
        return 'Erro';
      case PurchaseState.cancelled:
        return 'Cancelado';
    }
  }

  static String getStateDescription(PurchaseStateData data) {
    switch (data.state) {
      case PurchaseState.idle:
        return 'Aguardando ação do usuário';
      case PurchaseState.loading:
        return 'Carregando informações de assinatura';
      case PurchaseState.purchasing:
        return 'Processando compra do ${data.purchasedPackage?.storeProduct.title ?? 'plano'}';
      case PurchaseState.restoring:
        return 'Restaurando compras anteriores';
      case PurchaseState.success:
        if (data.isRestoreOperation) {
          return 'Compras restauradas com sucesso';
        }
        return 'Assinatura realizada com sucesso';
      case PurchaseState.error:
        return data.errorMessage ?? 'Ocorreu um erro inesperado';
      case PurchaseState.cancelled:
        if (data.isRestoreOperation) {
          return 'Restauração cancelada';
        }
        return 'Compra cancelada';
    }
  }

  static bool shouldShowProgress(PurchaseState state) {
    return state == PurchaseState.loading ||
           state == PurchaseState.purchasing ||
           state == PurchaseState.restoring;
  }

  static bool shouldDisableUI(PurchaseState state) {
    return shouldShowProgress(state);
  }

  static Duration getAutoResetDuration(PurchaseState state) {
    switch (state) {
      case PurchaseState.success:
        return const Duration(seconds: 3);
      case PurchaseState.error:
        return const Duration(seconds: 5);
      case PurchaseState.cancelled:
        return const Duration(seconds: 2);
      default:
        return Duration.zero;
    }
  }

  static bool shouldAutoReset(PurchaseState state) {
    return state == PurchaseState.success ||
           state == PurchaseState.error ||
           state == PurchaseState.cancelled;
  }

  static String formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }

  static Map<String, dynamic> getStateStatistics(List<PurchaseStateData> history) {
    final stats = <String, int>{};
    
    for (final state in PurchaseState.values) {
      stats[state.name] = history.where((h) => h.state == state).length;
    }
    
    final errorCount = history.where((h) => h.hasError).length;
    final successfulPurchases = history.where((h) => 
        h.state == PurchaseState.success && !h.isRestoreOperation).length;
    final successfulRestores = history.where((h) => 
        h.state == PurchaseState.success && h.isRestoreOperation).length;
    
    return {
      'total': history.length,
      'errors': errorCount,
      'successfulPurchases': successfulPurchases,
      'successfulRestores': successfulRestores,
      'byState': stats,
    };
  }
}
