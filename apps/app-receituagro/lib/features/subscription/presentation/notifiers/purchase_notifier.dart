import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/index.dart';

part 'purchase_notifier.g.dart';

/// Estado do histórico de compras
class PurchaseState {
  final List<PurchaseHistoryEntity> purchases;
  final bool isLoading;
  final String? error;
  final DateTime? lastSynced;
  final int? totalPurchaseCount;

  const PurchaseState({
    this.purchases = const [],
    this.isLoading = false,
    this.error,
    this.lastSynced,
    this.totalPurchaseCount,
  });

  factory PurchaseState.initial() {
    return const PurchaseState(
      purchases: [],
      isLoading: false,
      error: null,
      lastSynced: null,
      totalPurchaseCount: null,
    );
  }

  /// Cópia com atualizações seletivas
  PurchaseState copyWith({
    List<PurchaseHistoryEntity>? purchases,
    bool? isLoading,
    String? error,
    DateTime? lastSynced,
    int? totalPurchaseCount,
  }) {
    return PurchaseState(
      purchases: purchases ?? this.purchases,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastSynced: lastSynced ?? this.lastSynced,
      totalPurchaseCount: totalPurchaseCount ?? this.totalPurchaseCount,
    );
  }

  /// Obtém apenas as compras bem-sucedidas
  List<PurchaseHistoryEntity> get successfulPurchases =>
      purchases.where((p) => p.isSuccessful).toList();

  /// Obtém apenas as compras pendentes
  List<PurchaseHistoryEntity> get pendingPurchases =>
      purchases.where((p) => p.isPending).toList();

  /// Obtém apenas as compras falhadas
  List<PurchaseHistoryEntity> get failedPurchases =>
      purchases.where((p) => p.isFailed).toList();

  /// Obtém apenas as compras recentes (< 24 horas)
  List<PurchaseHistoryEntity> get recentPurchases =>
      purchases.where((p) => p.isRecent).toList();

  /// Obtém apenas as compras com falha que podem ser reprocessadas
  List<PurchaseHistoryEntity> get retryablePurchases => failedPurchases
      .where((p) => p.purchaseDate.difference(DateTime.now()).inHours < 24)
      .toList();

  /// Indica se existem compras pendentes
  bool get hasPendingPurchases => pendingPurchases.isNotEmpty;

  /// Indica se existem compras falhadas
  bool get hasFailedPurchases => failedPurchases.isNotEmpty;

  /// Conta de compras falhadas
  int get failedPurchaseCount => failedPurchases.length;

  /// Total gasto em compras bem-sucedidas
  double get totalAmountSpent =>
      successfulPurchases.fold<double>(0, (sum, p) => sum + p.totalAmount);

  /// Indicador se precisa de atualização (> 1 hora)
  bool get needsRefresh {
    if (lastSynced == null) return true;
    final diff = DateTime.now().difference(lastSynced!);
    return diff.inHours > 1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseState &&
          runtimeType == other.runtimeType &&
          purchases == other.purchases &&
          isLoading == other.isLoading &&
          error == other.error &&
          lastSynced == other.lastSynced &&
          totalPurchaseCount == other.totalPurchaseCount;

  @override
  int get hashCode =>
      purchases.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      lastSynced.hashCode ^
      totalPurchaseCount.hashCode;

  @override
  String toString() =>
      'PurchaseState(purchases: ${purchases.length}, isLoading: $isLoading, error: $error, lastSynced: $lastSynced)';
}

/// Notifier que gerencia o histórico de compras
///
/// Responsabilidades:
/// - Carregar histórico de compras
/// - Processar novas compras
/// - Restaurar compras anteriores
/// - Gerenciar compras falhadas
/// - Sincronizar com backend
@riverpod
class PurchaseNotifier extends _$PurchaseNotifier {
  @override
  Future<PurchaseState> build() async {
    return PurchaseState.initial();
  }

  /// Carrega o histórico de compras do usuário
  ///
  /// Busca dados de:
  /// - API remota
  /// - Sistema de compras (App Store, Play Store)
  Future<void> loadPurchaseHistory() async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 800));

      // TODO: Substituir por chamada real ao repositório
      // final purchases = await _purchaseRepository.getPurchaseHistory();
      // final total = await _purchaseRepository.getTotalPurchaseCount();

      // Dados de exemplo (remover em produção)
      final examplePurchases = <PurchaseHistoryEntity>[
        PurchaseHistoryEntity(
          id: 'purchase_001',
          productId: 'com.receituagro.premium.yearly',
          transactionId: 'txn_123456789',
          type: PurchaseType.subscription,
          amount: 99.90,
          currency: 'BRL',
          store: Store.playStore,
          purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
          originalPurchaseDate: DateTime.now().subtract(
            const Duration(days: 30),
          ),
          status: PurchaseStatus.completed,
          failureReason: null,
          quantity: 1,
          lastUpdated: DateTime.now(),
          receiptUrl: 'https://example.com/receipt/001',
          invoiceUrl: 'https://example.com/invoice/001',
        ),
      ];

      state = AsyncValue.data(
        currentState.copyWith(
          purchases: examplePurchases,
          isLoading: false,
          lastSynced: DateTime.now(),
          totalPurchaseCount: examplePurchases.length,
        ),
      );
    } catch (error) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao carregar histórico: ${error.toString()}',
        ),
      );
    }
  }

  /// Simula uma nova compra de produto
  ///
  /// Parâmetros:
  /// - [productId]: ID do produto a comprar
  /// - [amount]: Valor da compra
  /// - [purchaseType]: Tipo da compra (subscription, trial, etc)
  Future<void> purchaseProduct({
    required String productId,
    required double amount,
    required PurchaseType purchaseType,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // TODO: Chamar backend/API de compra
      // final purchase = await _purchaseRepository.purchaseProduct(
      //   productId: productId,
      //   amount: amount,
      //   type: purchaseType,
      // );

      final newPurchase = PurchaseHistoryEntity(
        id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        type: purchaseType,
        amount: amount,
        currency: 'BRL',
        store: Store.playStore,
        purchaseDate: DateTime.now(),
        originalPurchaseDate: DateTime.now(),
        status: PurchaseStatus.completed,
        failureReason: null,
        quantity: 1,
        lastUpdated: DateTime.now(),
        receiptUrl: null,
        invoiceUrl: null,
      );

      final newPurchases = [...currentState.purchases, newPurchase];
      final newTotal = (currentState.totalPurchaseCount ?? 0) + 1;

      state = AsyncValue.data(
        currentState.copyWith(
          purchases: newPurchases,
          isLoading: false,
          lastSynced: DateTime.now(),
          totalPurchaseCount: newTotal,
        ),
      );

      // TODO: Log event de compra
      // _analyticsService.logEvent('purchase_completed', {
      //   'product_id': productId,
      //   'amount': amount,
      //   'type': purchaseType.toString(),
      // });
    } catch (error) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao processar compra: ${error.toString()}',
        ),
      );
    }
  }

  /// Restaura compras anteriores do usuário
  /// Útil para restaurar compras após reinstalar app
  ///
  /// Parâmetros:
  /// - [includeExpired]: Se deve incluir compras expiradas
  Future<void> restorePurchases({bool includeExpired = true}) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      // TODO: Chamar backend/API de restauração
      // final restored = await _purchaseRepository.restorePurchases(
      //   includeExpired: includeExpired,
      // );

      // Combinar com histórico existente
      // (em produção, seria necessário deduplicar)

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, lastSynced: DateTime.now()),
      );

      // TODO: Log event de restauração
      // _analyticsService.logEvent('purchases_restored', {
      //   'include_expired': includeExpired,
      // });
    } catch (error) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao restaurar compras: ${error.toString()}',
        ),
      );
    }
  }

  /// Faz retry de uma compra falhada
  ///
  /// Parâmetros:
  /// - [purchaseId]: ID da compra a reprocessar
  Future<void> retryFailedPurchase({required String purchaseId}) async {
    final currentState = state.value;
    if (currentState == null) return;

    final purchase = currentState.purchases.firstWhere(
      (p) => p.id == purchaseId,
      orElse: () => throw Exception('Compra não encontrada'),
    );

    if (!purchase.isFailed) {
      state = AsyncValue.data(
        currentState.copyWith(
          error: 'Apenas compras falhadas podem ser reprocessadas',
        ),
      );
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      // TODO: Chamar backend/API de retry
      // final retried = await _purchaseRepository.retryPurchase(purchaseId);

      // Atualizar status da compra
      final updated = purchase.copyWith(
        status: PurchaseStatus.completed,
        failureReason: null,
        lastUpdated: DateTime.now(),
      );

      final newPurchases = currentState.purchases
          .map((p) => p.id == purchaseId ? updated : p)
          .toList();

      state = AsyncValue.data(
        currentState.copyWith(
          purchases: newPurchases,
          isLoading: false,
          lastSynced: DateTime.now(),
        ),
      );

      // TODO: Log event de retry
      // _analyticsService.logEvent('purchase_retry', {
      //   'purchase_id': purchaseId,
      //   'product_id': purchase.productId,
      // });
    } catch (error) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao fazer retry: ${error.toString()}',
        ),
      );
    }
  }

  /// Sincroniza compras locais com servidor
  /// Verifica se há compras que precisam de confirmação/atualização
  Future<void> syncPurchasesWithServer() async {
    final currentState = state.value;
    if (currentState == null || currentState.purchases.isEmpty) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));

      // TODO: Sincronizar com backend
      // await _purchaseRepository.syncPurchases(currentState.purchases);

      state = AsyncValue.data(
        currentState.copyWith(isLoading: false, lastSynced: DateTime.now()),
      );

      // TODO: Log event de sincronização
      // _analyticsService.logEvent('purchases_synced', {
      //   'count': currentState.purchases.length,
      // });
    } catch (error) {
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: 'Erro ao sincronizar: ${error.toString()}',
        ),
      );
    }
  }

  /// Obtém uma compra específica pelo ID
  PurchaseHistoryEntity? getPurchaseById(String purchaseId) {
    final currentState = state.value;
    if (currentState == null) return null;

    try {
      return currentState.purchases.firstWhere((p) => p.id == purchaseId);
    } catch (_) {
      return null;
    }
  }

  /// Obtém compras de um produto específico
  List<PurchaseHistoryEntity> getPurchasesForProduct(String productId) {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.purchases.where((p) => p.productId == productId).toList();
  }

  /// Obtém compras de um período específico
  ///
  /// Parâmetros:
  /// - [startDate]: Data inicial (inclusive)
  /// - [endDate]: Data final (inclusive)
  List<PurchaseHistoryEntity> getPurchasesInPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.purchases.where((p) {
      return p.purchaseDate.isAfter(startDate) &&
          p.purchaseDate.isBefore(endDate);
    }).toList();
  }

  /// Obtém o valor total gasto em um período
  double getTotalAmountInPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final purchases = getPurchasesInPeriod(
      startDate: startDate,
      endDate: endDate,
    );
    return purchases.fold<double>(0, (sum, p) => sum + p.totalAmount);
  }

  /// Adiciona uma nova compra ao histórico
  /// Usado quando nova compra é processada via callback
  void addPurchase(PurchaseHistoryEntity purchase) {
    final currentState = state.value;
    if (currentState == null) return;

    final exists = currentState.purchases.any((p) => p.id == purchase.id);
    if (exists) return;

    final newPurchases = [...currentState.purchases, purchase];
    final newTotal = (currentState.totalPurchaseCount ?? 0) + 1;

    state = AsyncValue.data(
      currentState.copyWith(
        purchases: newPurchases,
        totalPurchaseCount: newTotal,
        lastSynced: DateTime.now(),
      ),
    );
  }

  /// Atualiza o status de uma compra
  /// Usado quando servidor notifica mudança de status
  void updatePurchaseStatus({
    required String purchaseId,
    required PurchaseStatus newStatus,
    String? failureReason,
  }) {
    final currentState = state.value;
    if (currentState == null) return;

    final purchase = currentState.purchases.firstWhere(
      (p) => p.id == purchaseId,
      orElse: () => throw Exception('Compra não encontrada'),
    );

    final updated = purchase.copyWith(
      status: newStatus,
      failureReason: failureReason,
      lastUpdated: DateTime.now(),
    );

    final newPurchases = currentState.purchases
        .map((p) => p.id == purchaseId ? updated : p)
        .toList();

    state = AsyncValue.data(
      currentState.copyWith(purchases: newPurchases, lastSynced: DateTime.now()),
    );
  }

  /// Obtém resumo de compras do mês atual
  Map<String, dynamic> getMonthlyPurchaseSummary() {
    final currentState = state.value;
    if (currentState == null) {
      return {
        'totalAmount': 0.0,
        'count': 0,
        'successful': 0,
        'pending': 0,
        'failed': 0,
      };
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthPurchases = getPurchasesInPeriod(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    return {
      'totalAmount': monthPurchases.fold<double>(
        0,
        (sum, p) => sum + p.totalAmount,
      ),
      'count': monthPurchases.length,
      'successful': monthPurchases.where((p) => p.isSuccessful).length,
      'pending': monthPurchases.where((p) => p.isPending).length,
      'failed': monthPurchases.where((p) => p.isFailed).length,
    };
  }

  /// Sincroniza com backend
  /// Chamado periodicamente ou quando volta para foreground
  Future<void> syncWithBackend() async {
    final currentState = state.value;
    if (currentState == null) return;

    if (currentState.needsRefresh) {
      await loadPurchaseHistory();
    }
    await syncPurchasesWithServer();
  }

  /// Limpa o estado e dados em cache
  void clearState() {
    state = AsyncValue.data(PurchaseState.initial());
  }
}
