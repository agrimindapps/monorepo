import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../domain/repositories/i_local_storage_repository.dart';
import '../domain/repositories/i_subscription_repository.dart';
import '../domain/entities/subscription_entity.dart';
import '../shared/utils/failure.dart';

/// Versão simplificada do serviço de sincronização de subscription
///
/// Esta implementação funcional foca nas funcionalidades essenciais:
/// - Stream reativo para status de subscription
/// - Cache local básico
/// - Verificação por app específico
/// - Interface limpa para os apps
class SimpleSubscriptionSyncService {
  final ISubscriptionRepository _subscriptionRepository;
  final ILocalStorageRepository _localStorage;

  /// Stream controller para subscription status updates
  final _subscriptionStreamController = StreamController<SubscriptionEntity?>.broadcast();

  /// Cache local da assinatura atual
  SubscriptionEntity? _cachedSubscription;

  /// Timer para sync periódico
  Timer? _periodicSyncTimer;

  /// Flag para indicar se está sincronizando
  bool _isSyncing = false;

  /// Key para storage local
  static const String _storageKey = 'cached_subscription';

  /// Intervalo para sync periódico (30 minutos)
  static const Duration _syncInterval = Duration(minutes: 30);

  SimpleSubscriptionSyncService({
    required ISubscriptionRepository subscriptionRepository,
    required ILocalStorageRepository localStorage,
  })  : _subscriptionRepository = subscriptionRepository,
        _localStorage = localStorage;

  /// Stream com o status atual da assinatura (offline-first)
  Stream<SubscriptionEntity?> get subscriptionStatus => _subscriptionStreamController.stream;

  /// Subscription atual em cache (offline-first)
  SubscriptionEntity? get currentSubscription => _cachedSubscription;

  /// Se há uma assinatura ativa
  bool get hasActiveSubscription => _cachedSubscription?.isActive ?? false;

  /// Se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      // Carrega subscription do cache local
      await _loadFromCache();

      // Inicia sync periódico
      _startPeriodicSync();

      // Tenta sincronizar imediatamente (background)
      unawaited(_performSync());

      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Initialized with ${_cachedSubscription != null ? "cached" : "no"} subscription');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Initialization error: $e');
      }
    }
  }

  /// Dispose do serviço
  void dispose() {
    _periodicSyncTimer?.cancel();
    _subscriptionStreamController.close();
  }

  /// Força sincronização completa
  Future<Either<Failure, SubscriptionEntity?>> forceSync() async {
    return await _performSync();
  }

  /// Verifica se tem assinatura ativa para um app específico
  Future<Either<Failure, bool>> hasActiveSubscriptionForApp(String appName) async {
    // Se não tem cache, tenta sincronizar
    if (_cachedSubscription == null) {
      final syncResult = await _performSync();
      if (syncResult.isLeft()) {
        return Left(syncResult.fold((l) => l, (r) => throw Exception()));
      }
    }

    final subscription = _cachedSubscription;
    if (subscription == null || !subscription.isActive) {
      return const Right(false);
    }

    // Verifica se a assinatura é para o app específico através do productId
    final isForApp = _isSubscriptionForApp(subscription, appName);
    return Right(isForApp);
  }

  /// Obtém produtos disponíveis para um app específico
  Future<Either<Failure, List<ProductInfo>>> getProductsForApp(String appName) async {
    switch (appName.toLowerCase()) {
      case 'plantis':
        return await _subscriptionRepository.getPlantisProducts();
      case 'receituagro':
        return await _subscriptionRepository.getReceitaAgroProducts();
      case 'gasometer':
        return await _subscriptionRepository.getGasometerProducts();
      default:
        return Left(ValidationFailure('Unknown app: $appName'));
    }
  }

  /// Verifica elegibilidade para trial de um produto específico
  Future<Either<Failure, bool>> isEligibleForTrial(String productId) async {
    return await _subscriptionRepository.isEligibleForTrial(productId: productId);
  }

  /// Realiza sincronização com RevenueCat
  Future<Either<Failure, SubscriptionEntity?>> _performSync() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Sync already in progress, skipping');
      }
      return Right(_cachedSubscription);
    }

    _isSyncing = true;

    try {
      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Starting sync');
      }

      // Busca dados do RevenueCat (source of truth)
      final revenueCatResult = await _subscriptionRepository.getCurrentSubscription();
      if (revenueCatResult.isLeft()) {
        if (kDebugMode) {
          print('⚠️ SimpleSubscriptionSyncService: RevenueCat failed, using cache');
        }
        return Right(_cachedSubscription);
      }

      final latestSubscription = revenueCatResult.fold(
        (failure) => null,
        (subscription) => subscription,
      );

      // Compara com cache local para detectar mudanças
      final hasChanges = _hasSubscriptionChanged(latestSubscription);

      if (hasChanges) {
        if (kDebugMode) {
          print('📱 SimpleSubscriptionSyncService: Changes detected, updating cache');
        }

        // Salva no cache local
        await _saveToCache(latestSubscription);

        // Atualiza stream
        _subscriptionStreamController.add(latestSubscription);
      }

      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Sync completed');
      }

      return Right(latestSubscription);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Sync error: $e');
      }
      return Left(ServerFailure('Sync failed: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Carrega subscription do cache local
  Future<void> _loadFromCache() async {
    try {
      final result = await _localStorage.get<String>(key: _storageKey);
      result.fold(
        (failure) {
          if (kDebugMode) {
            print('⚠️ SimpleSubscriptionSyncService: Failed to load from cache: ${failure.message}');
          }
        },
        (cached) {
          if (cached != null) {
            // TODO: Implementar deserialização quando necessário
            // Por agora, apenas notifica que tem cache
            if (kDebugMode) {
              print('📱 SimpleSubscriptionSyncService: Found cached subscription');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Failed to load from cache: $e');
      }
    }
  }

  /// Salva subscription no cache local
  Future<void> _saveToCache(SubscriptionEntity? subscription) async {
    try {
      if (subscription != null) {
        // TODO: Implementar serialização quando necessário
        // Por agora, apenas armazena uma flag
        await _localStorage.save<String>(key: _storageKey, data: 'has_subscription');
      } else {
        await _localStorage.remove(key: _storageKey);
      }

      _cachedSubscription = subscription;

      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Saved subscription to cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Failed to save to cache: $e');
      }
    }
  }

  /// Verifica se a subscription mudou comparando com cache
  bool _hasSubscriptionChanged(SubscriptionEntity? newSubscription) {
    if (_cachedSubscription == null && newSubscription == null) {
      return false;
    }

    if (_cachedSubscription == null || newSubscription == null) {
      return true;
    }

    // Compara campos críticos
    return _cachedSubscription!.id != newSubscription.id ||
        _cachedSubscription!.status != newSubscription.status ||
        _cachedSubscription!.tier != newSubscription.tier;
  }

  /// Verifica se uma subscription é para um app específico
  bool _isSubscriptionForApp(SubscriptionEntity subscription, String appName) {
    final productId = subscription.productId.toLowerCase();
    final app = appName.toLowerCase();

    switch (app) {
      case 'plantis':
        return productId.contains('plantis');
      case 'receituagro':
        return productId.contains('receituagro');
      case 'gasometer':
        return productId.contains('gasometer');
      case 'petiveti':
        return productId.contains('petiveti');
      case 'taskolist':
        return productId.contains('taskolist');
      case 'agrihurbi':
        return productId.contains('agrihurbi');
      default:
        return false;
    }
  }

  /// Inicia sync periódico
  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(_syncInterval, (timer) {
      if (!_isSyncing) {
        unawaited(_performSync());
      }
    });
  }
}

/// Extension para usar unawaited sem import adicional
extension _Unawaited on Future {
  void get unawaited => null;
}