import 'dart:async';
import 'dart:developer' as developer;

import 'package:core/core.dart' hide Column, SubscriptionState, SubscriptionInfo;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/product_ids.dart';
import '../../../../core/providers/core_services_providers.dart'
    as local_providers;
import 'subscription_state.dart';

part 'subscription_notifier.g.dart';

/// Notifier para gerenciamento de assinaturas Premium do Petiveti
/// 
/// Gerencia:
/// - Estado da assinatura atual
/// - Compra de novos planos
/// - Restauração de compras
/// - Verificação de acesso a features
/// 
/// Usa o RevenueCat via core package para operações reais de IAP
@riverpod
class Subscription extends _$Subscription {
  ISubscriptionRepository get _subscriptionRepository =>
      ref.read(local_providers.subscriptionRepositoryProvider);

  StreamSubscription<SubscriptionEntity?>? _subscriptionStreamSubscription;

  @override
  SubscriptionState build() {
    // Cleanup quando o provider for descartado
    ref.onDispose(() {
      _subscriptionStreamSubscription?.cancel();
      developer.log(
        '🧹 Subscription stream listener cancelled',
        name: 'SubscriptionNotifier',
      );
    });

    // Inicializa os dados em background
    Future.microtask(_initialize);

    return SubscriptionState.initial();
  }

  /// Inicializa o notifier carregando dados e configurando listeners
  Future<void> _initialize() async {
    state = state.copyWith(
      isLoadingPlans: true,
      isLoadingCurrentSubscription: true,
    );

    try {
      if (kIsWeb) {
        developer.log(
          '🌐 Subscription: Running on web platform (limited IAP support)',
          name: 'SubscriptionNotifier',
        );
      }

      // Configura listener para atualizações em tempo real
      _subscriptionStreamSubscription = _subscriptionRepository
          .subscriptionStatus
          .listen(
            _handleSubscriptionUpdate,
            onError: (Object error) {
              developer.log(
                '⚠️ Subscription stream error: $error',
                name: 'SubscriptionNotifier',
                error: error,
              );
            },
          );

      // Carrega dados iniciais
      await Future.wait([
        _loadCurrentSubscription(),
        _loadAvailablePlans(),
      ]);

      // Tenta auto-restore se não encontrou assinatura
      if (state.currentSubscription == null && !kIsWeb) {
        developer.log(
          '🔄 No cached subscription found, attempting auto-restore...',
          name: 'SubscriptionNotifier',
        );
        unawaited(_attemptAutoRestore());
      }

      developer.log(
        '✅ Subscription Service initialized',
        name: 'SubscriptionNotifier',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Subscription initialization failed: $e',
        name: 'SubscriptionNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      state = state.copyWith(
        isLoadingPlans: false,
        isLoadingCurrentSubscription: false,
        errorMessage: 'Falha ao inicializar serviço de assinatura: $e',
      );
    }
  }

  /// Carrega a assinatura atual do usuário
  Future<void> _loadCurrentSubscription() async {
    try {
      final result = await _subscriptionRepository.getCurrentSubscription();

      result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load subscription: ${failure.message}',
            name: 'SubscriptionNotifier',
          );
          state = state.copyWith(isLoadingCurrentSubscription: false);
        },
        (subscription) {
          if (subscription != null) {
            state = state.copyWith(
              isLoadingCurrentSubscription: false,
              currentSubscription: PetivetiSubscriptionInfo.fromEntity(subscription),
            );
          } else {
            state = state.copyWith(isLoadingCurrentSubscription: false);
          }
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Error loading subscription: $e',
        name: 'SubscriptionNotifier',
        error: e,
      );
      state = state.copyWith(isLoadingCurrentSubscription: false);
    }
  }

  /// Carrega os planos disponíveis para compra
  Future<void> _loadAvailablePlans() async {
    try {
      final result = await _subscriptionRepository.getAvailableProducts(
        productIds: PetivetiProducts.allSubscriptions,
      );

      result.fold(
        (failure) {
          developer.log(
            '⚠️ Failed to load products: ${failure.message}',
            name: 'SubscriptionNotifier',
          );
          state = state.copyWith(isLoadingPlans: false);
        },
        (products) {
          state = state.copyWith(
            isLoadingPlans: false,
            availablePlans: products,
          );
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Error loading products: $e',
        name: 'SubscriptionNotifier',
        error: e,
      );
      state = state.copyWith(isLoadingPlans: false);
    }
  }

  /// Processa atualizações de assinatura recebidas via stream
  void _handleSubscriptionUpdate(SubscriptionEntity? subscription) {
    if (subscription != null) {
      developer.log(
        '📱 Subscription update received: ${subscription.productId}',
        name: 'SubscriptionNotifier',
      );

      state = state.copyWith(
        currentSubscription: PetivetiSubscriptionInfo.fromEntity(subscription),
      );
    } else {
      state = state.copyWith(currentSubscription: null);
    }
  }

  /// Compra um produto premium
  Future<Either<String, SubscriptionEntity>> purchaseProduct(
    String productId,
  ) async {
    if (state.isProcessingPurchase) {
      return const Left('Compra já em andamento');
    }

    state = state.copyWith(isProcessingPurchase: true).clearError();

    try {
      developer.log(
        '💰 Starting purchase: $productId',
        name: 'SubscriptionNotifier',
      );

      final result = await _subscriptionRepository.purchaseProduct(
        productId: productId,
      );

      return result.fold(
        (failure) {
          final errorMessage = _mapFailureToMessage(failure);
          state = state.copyWith(
            isProcessingPurchase: false,
            errorMessage: errorMessage,
          );
          return Left(errorMessage);
        },
        (subscription) {
          developer.log(
            '✅ Purchase successful: ${subscription.productId}',
            name: 'SubscriptionNotifier',
          );

          state = state.copyWith(
            isProcessingPurchase: false,
            currentSubscription: PetivetiSubscriptionInfo.fromEntity(subscription),
          );

          return Right(subscription);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Erro na compra: $e';

      developer.log(
        '❌ Purchase failed: $e',
        name: 'SubscriptionNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      state = state.copyWith(
        isProcessingPurchase: false,
        errorMessage: errorMessage,
      );

      return Left(errorMessage);
    }
  }

  /// Restaura compras anteriores
  Future<Either<String, List<SubscriptionEntity>>> restorePurchases() async {
    if (state.isRestoringPurchases) {
      return const Left('Restauração já em andamento');
    }

    state = state.copyWith(isRestoringPurchases: true).clearError();

    try {
      developer.log(
        '🔄 Starting restore purchases...',
        name: 'SubscriptionNotifier',
      );

      final result = await _subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) {
          final errorMessage = _mapFailureToMessage(failure);
          state = state.copyWith(
            isRestoringPurchases: false,
            errorMessage: errorMessage,
          );
          return Left(errorMessage);
        },
        (subscriptions) {
          PetivetiSubscriptionInfo? activeSubscription;

          if (subscriptions.isNotEmpty) {
            // Encontra a assinatura ativa mais recente
            final active = subscriptions.where((s) => s.isActive).toList();
            if (active.isNotEmpty) {
              activeSubscription = PetivetiSubscriptionInfo.fromEntity(active.first);
            }
          }

          developer.log(
            '✅ Restore completed: ${subscriptions.length} subscription(s) found',
            name: 'SubscriptionNotifier',
          );

          state = state.copyWith(
            isRestoringPurchases: false,
            currentSubscription: activeSubscription,
          );

          return Right(subscriptions);
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Erro ao restaurar compras: $e';

      developer.log(
        '❌ Restore failed: $e',
        name: 'SubscriptionNotifier',
        error: e,
        stackTrace: stackTrace,
      );

      state = state.copyWith(
        isRestoringPurchases: false,
        errorMessage: errorMessage,
      );

      return Left(errorMessage);
    }
  }

  /// Tenta restaurar compras automaticamente (silencioso)
  Future<void> _attemptAutoRestore() async {
    try {
      developer.log(
        '🔄 Auto-restore starting...',
        name: 'SubscriptionNotifier',
      );

      final result = await _subscriptionRepository.restorePurchases();

      result.fold(
        (failure) {
          developer.log(
            '⚠️ Auto-restore failed: ${failure.message}',
            name: 'SubscriptionNotifier',
          );
        },
        (subscriptions) {
          if (subscriptions.isNotEmpty) {
            final active = subscriptions.where((s) => s.isActive);
            if (active.isNotEmpty) {
              developer.log(
                '✅ Auto-restore successful: Found active subscription',
                name: 'SubscriptionNotifier',
              );

              state = state.copyWith(
                currentSubscription: PetivetiSubscriptionInfo.fromEntity(active.first),
              );
            }
          } else {
            developer.log(
              'ℹ️ Auto-restore: No subscriptions to restore',
              name: 'SubscriptionNotifier',
            );
          }
        },
      );
    } catch (e) {
      developer.log(
        '⚠️ Auto-restore error: $e',
        name: 'SubscriptionNotifier',
        error: e,
      );
      // Silenciosamente ignora erros no auto-restore
    }
  }

  /// Recarrega os dados de assinatura
  Future<void> refresh() async {
    await Future.wait([
      _loadCurrentSubscription(),
      _loadAvailablePlans(),
    ]);
  }

  /// Limpa mensagem de erro
  void clearError() {
    state = state.clearError();
  }

  /// Mapeia falhas para mensagens amigáveis
  String _mapFailureToMessage(Failure failure) {
    if (failure is SubscriptionPaymentFailure) {
      return 'Falha no pagamento: ${failure.message}';
    }
    if (failure is SubscriptionNetworkFailure) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    // SubscriptionCancelledFailure - usuário cancelou
    if (failure.message.contains('cancelled') || failure.message.contains('cancelado')) {
      return 'Compra cancelada';
    }
    return failure.message;
  }
}
