import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../domain/entities/subscription_entity.dart';
import '../domain/interfaces/i_disposable_service.dart';
import '../domain/repositories/i_local_storage_repository.dart';
import '../domain/repositories/i_subscription_repository.dart';
import '../shared/utils/failure.dart';

/// Versão simplificada do serviço de sincronização de subscription
///
/// Esta implementação funcional foca nas funcionalidades essenciais:
/// - Stream reativo para status de subscription
/// - Cache local básico
/// - Verificação por app específico
/// - Interface limpa para os apps
class SimpleSubscriptionSyncService implements IDisposableService {
  final ISubscriptionRepository _subscriptionRepository;
  final ILocalStorageRepository _localStorage;

  /// Stream controller para subscription status updates
  final _subscriptionStreamController =
      StreamController<SubscriptionEntity?>.broadcast();

  /// Cache local da assinatura atual
  SubscriptionEntity? _cachedSubscription;

  /// Timer para sync periódico
  Timer? _periodicSyncTimer;

  /// Flag para indicar se está sincronizando
  bool _isSyncing = false;

  /// Flag para indicar se foi disposed
  bool _isDisposed = false;

  /// Key para storage local
  static const String _storageKey = 'cached_subscription';

  /// Intervalo para sync periódico (30 minutos)
  static const Duration _syncInterval = Duration(minutes: 30);

  SimpleSubscriptionSyncService({
    required ISubscriptionRepository subscriptionRepository,
    required ILocalStorageRepository localStorage,
  }) : _subscriptionRepository = subscriptionRepository,
       _localStorage = localStorage;

  /// Stream com o status atual da assinatura (offline-first)
  Stream<SubscriptionEntity?> get subscriptionStatus =>
      _subscriptionStreamController.stream;

  /// Subscription atual em cache (offline-first)
  SubscriptionEntity? get currentSubscription => _cachedSubscription;

  /// Se há uma assinatura ativa
  bool get hasActiveSubscription => _cachedSubscription?.isActive ?? false;

  /// Se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Inicializa o serviço
  Future<void> initialize() async {
    try {
      await _loadFromCache();
      _startPeriodicSync();
      unawaited(_performSync());

      if (kDebugMode) {
        print(
          '📱 SimpleSubscriptionSyncService: Initialized with ${_cachedSubscription != null ? "cached" : "no"} subscription',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Initialization error: $e');
      }
    }
  }

  /// Dispose do serviço
  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    // Cancel timer
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;

    // Close stream controller with error handling
    try {
      if (!_subscriptionStreamController.isClosed) {
        await _subscriptionStreamController.close();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error closing subscription stream controller: $e');
      }
    }

    // Clear cache
    _cachedSubscription = null;

    if (kDebugMode) {
      print('📱 SimpleSubscriptionSyncService: Disposed');
    }
  }

  @override
  bool get isDisposed => _isDisposed;

  /// Força sincronização completa
  Future<Either<Failure, SubscriptionEntity?>> forceSync() async {
    return await _performSync();
  }

  /// Verifica se tem assinatura ativa para um app específico
  Future<Either<Failure, bool>> hasActiveSubscriptionForApp(
    String appName,
  ) async {
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
    final isForApp = _isSubscriptionForApp(subscription, appName);
    return Right(isForApp);
  }

  /// Obtém produtos disponíveis para um app específico
  Future<Either<Failure, List<ProductInfo>>> getProductsForApp(
    String appName,
  ) async {
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
    return await _subscriptionRepository.isEligibleForTrial(
      productId: productId,
    );
  }

  /// Realiza sincronização com RevenueCat
  Future<Either<Failure, SubscriptionEntity?>> _performSync() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print(
          '📱 SimpleSubscriptionSyncService: Sync already in progress, skipping',
        );
      }
      return Right(_cachedSubscription);
    }

    _isSyncing = true;

    try {
      if (kDebugMode) {
        print('📱 SimpleSubscriptionSyncService: Starting sync');
      }
      final revenueCatResult =
          await _subscriptionRepository.getCurrentSubscription();
      if (revenueCatResult.isLeft()) {
        if (kDebugMode) {
          print(
            '⚠️ SimpleSubscriptionSyncService: RevenueCat failed, using cache',
          );
        }
        return Right(_cachedSubscription);
      }

      final latestSubscription = revenueCatResult.fold(
        (failure) => null,
        (subscription) => subscription,
      );
      final hasChanges = _hasSubscriptionChanged(latestSubscription);

      if (hasChanges) {
        if (kDebugMode) {
          print(
            '📱 SimpleSubscriptionSyncService: Changes detected, updating cache',
          );
        }
        await _saveToCache(latestSubscription);
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
            print(
              '⚠️ SimpleSubscriptionSyncService: Failed to load from cache: ${failure.message}',
            );
          }
        },
        (jsonString) {
          if (jsonString != null && jsonString.isNotEmpty) {
            try {
              final Map<String, dynamic> json = _decodeJson(jsonString);
              _cachedSubscription = _deserializeSubscription(json);
              _subscriptionStreamController.add(_cachedSubscription);

              if (kDebugMode) {
                print(
                  '📱 SimpleSubscriptionSyncService: Loaded cached subscription (${_cachedSubscription?.productId})',
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                  '⚠️ SimpleSubscriptionSyncService: Failed to deserialize cache: $e',
                );
              }
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(
          '⚠️ SimpleSubscriptionSyncService: Failed to load from cache: $e',
        );
      }
    }
  }

  /// Salva subscription no cache local
  Future<void> _saveToCache(SubscriptionEntity? subscription) async {
    try {
      if (subscription != null) {
        final Map<String, dynamic> json = _serializeSubscription(subscription);
        final String jsonString = _encodeJson(json);

        await _localStorage.save<String>(key: _storageKey, data: jsonString);
      } else {
        await _localStorage.remove(key: _storageKey);
      }

      _cachedSubscription = subscription;

      if (kDebugMode) {
        print(
          '📱 SimpleSubscriptionSyncService: Saved subscription to cache (${subscription?.productId})',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ SimpleSubscriptionSyncService: Failed to save to cache: $e');
      }
    }
  }

  /// Serializa SubscriptionEntity para Map
  Map<String, dynamic> _serializeSubscription(SubscriptionEntity subscription) {
    return {
      'id': subscription.id,
      'userId': subscription.userId,
      'productId': subscription.productId,
      'status': subscription.status.name,
      'tier': subscription.tier.name,
      'expirationDate': subscription.expirationDate?.millisecondsSinceEpoch,
      'purchaseDate': subscription.purchaseDate?.millisecondsSinceEpoch,
      'originalPurchaseDate':
          subscription.originalPurchaseDate?.millisecondsSinceEpoch,
      'store': subscription.store.name,
      'isInTrial': subscription.isInTrial,
      'isSandbox': subscription.isSandbox,
      'createdAt': subscription.createdAt?.millisecondsSinceEpoch,
      'updatedAt': subscription.updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Deserializa Map para SubscriptionEntity
  SubscriptionEntity _deserializeSubscription(Map<String, dynamic> json) {
    return SubscriptionEntity(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.unknown,
      ),
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expirationDate:
          json['expirationDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                json['expirationDate'] as int,
              )
              : null,
      purchaseDate:
          json['purchaseDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['purchaseDate'] as int)
              : null,
      originalPurchaseDate:
          json['originalPurchaseDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                json['originalPurchaseDate'] as int,
              )
              : null,
      store: Store.values.firstWhere(
        (e) => e.name == json['store'],
        orElse: () => Store.unknown,
      ),
      isInTrial: json['isInTrial'] as bool? ?? false,
      isSandbox: json['isSandbox'] as bool? ?? false,
      createdAt:
          json['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
              : DateTime.now(),
    );
  }

  /// Encode Map to JSON string (simple implementation)
  String _encodeJson(Map<String, dynamic> map) {
    final buffer = StringBuffer('{');
    final entries = map.entries.toList();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final value = entry.value;

      buffer.write('"${entry.key}":');

      if (value == null) {
        buffer.write('null');
      } else if (value is String) {
        buffer.write('"$value"');
      } else if (value is bool || value is num) {
        buffer.write(value.toString());
      } else {
        buffer.write('"$value"');
      }

      if (i < entries.length - 1) {
        buffer.write(',');
      }
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Decode JSON string to Map (simple implementation)
  Map<String, dynamic> _decodeJson(String jsonString) {
    final map = <String, dynamic>{};
    var content = jsonString.trim();
    if (content.startsWith('{')) content = content.substring(1);
    if (content.endsWith('}')) {
      content = content.substring(0, content.length - 1);
    }
    final pairs = content.split(',');

    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        var key = parts[0].trim().replaceAll('"', '');
        var value = parts[1].trim();
        if (value == 'null') {
          map[key] = null;
        } else if (value == 'true') {
          map[key] = true;
        } else if (value == 'false') {
          map[key] = false;
        } else if (value.startsWith('"') && value.endsWith('"')) {
          map[key] = value.substring(1, value.length - 1);
        } else {
          final numValue = int.tryParse(value);
          map[key] = numValue ?? value;
        }
      }
    }

    return map;
  }

  /// Verifica se a subscription mudou comparando com cache
  bool _hasSubscriptionChanged(SubscriptionEntity? newSubscription) {
    if (_cachedSubscription == null && newSubscription == null) {
      return false;
    }

    if (_cachedSubscription == null || newSubscription == null) {
      return true;
    }
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
extension _Unawaited<T> on Future<T> {}
