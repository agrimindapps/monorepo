import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Imports locais - evita ambiguidade com core
import '../../../../core/constants/product_ids.dart';
import '../../../../core/constants/subscription_features.dart';
import '../../../../core/providers/core_services_providers.dart'
    as local_providers;
import '../../../../database/providers/sync_providers.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/i_app_subscription_repository.dart';

part 'subscription_providers.g.dart';

// ============================================================================
// SUBSCRIPTION REPOSITORY PROVIDER
// ============================================================================

/// Provider para o repositório de assinaturas app-specific
@riverpod
IAppSubscriptionRepository appSubscriptionRepository(Ref ref) {
  final coreRepository = ref.watch(
    local_providers.subscriptionRepositoryProvider,
  );
  final localStorageRepository = _SimpleLocalStorageRepository();
  final subscriptionLocalRepo = ref.watch(subscriptionLocalRepositoryProvider);

  return SubscriptionRepositoryImpl(
    coreRepository,
    localStorageRepository,
    subscriptionLocalRepo, // Drift cache para assinaturas
    null, // AuthService - será conectado quando necessário
  );
}

// ============================================================================
// PREMIUM STATE & STATUS
// ============================================================================

/// Status premium específico do Petiveti
class PetivetiPremiumStatus {
  final bool isPremium;
  final bool isActive;
  final DateTime? expirationDate;
  final String? productId;
  final bool isTrialActive;
  final DateTime? trialEndDate;
  final bool isInGracePeriod;
  final int devicesUsed;
  final int maxDevices;
  final Map<String, bool> featurePermissions;

  const PetivetiPremiumStatus({
    required this.isPremium,
    required this.isActive,
    this.expirationDate,
    this.productId,
    this.isTrialActive = false,
    this.trialEndDate,
    this.isInGracePeriod = false,
    this.devicesUsed = 1,
    this.maxDevices = 3,
    this.featurePermissions = const {},
  });

  factory PetivetiPremiumStatus.free() {
    return PetivetiPremiumStatus(
      isPremium: false,
      isActive: false,
      featurePermissions: {
        for (final feature in PetivetiFeatures.freeFeatures) feature: true,
        for (final feature in PetivetiFeatures.premiumFeatures) feature: false,
      },
    );
  }

  factory PetivetiPremiumStatus.premium({
    required DateTime expirationDate,
    required String productId,
    bool isTrialActive = false,
    DateTime? trialEndDate,
    int devicesUsed = 1,
    int maxDevices = 3,
  }) {
    return PetivetiPremiumStatus(
      isPremium: true,
      isActive: true,
      expirationDate: expirationDate,
      productId: productId,
      isTrialActive: isTrialActive,
      trialEndDate: trialEndDate,
      devicesUsed: devicesUsed,
      maxDevices: maxDevices,
      featurePermissions: {
        // All features enabled for premium users
        for (final feature in PetivetiFeatures.freeFeatures) feature: true,
        for (final feature in PetivetiFeatures.premiumFeatures) feature: true,
      },
    );
  }

  bool hasFeature(String featureKey) {
    return featurePermissions[featureKey] ?? false;
  }

  bool get canAddDevice => devicesUsed < maxDevices;
  bool get isNearDeviceLimit => devicesUsed >= (maxDevices * 0.8);

  int? get daysRemaining {
    if (expirationDate == null) return null;
    return expirationDate!.difference(DateTime.now()).inDays;
  }

  bool get willExpireSoon {
    final days = daysRemaining;
    return days != null && days <= 7 && days > 0;
  }
}

/// Estado completo do Premium
class PetivetiPremiumState {
  final bool isInitialized;
  final bool isLoading;
  final PetivetiPremiumStatus status;
  final List<ProductInfo> availableProducts;
  final SubscriptionEntity? currentSubscription;
  final String? lastError;

  const PetivetiPremiumState({
    required this.isInitialized,
    required this.isLoading,
    required this.status,
    required this.availableProducts,
    this.currentSubscription,
    this.lastError,
  });

  factory PetivetiPremiumState.initial() {
    return PetivetiPremiumState(
      isInitialized: false,
      isLoading: false,
      status: PetivetiPremiumStatus.free(),
      availableProducts: const [],
      currentSubscription: null,
      lastError: null,
    );
  }

  PetivetiPremiumState copyWith({
    bool? isInitialized,
    bool? isLoading,
    PetivetiPremiumStatus? status,
    List<ProductInfo>? availableProducts,
    SubscriptionEntity? currentSubscription,
    String? lastError,
  }) {
    return PetivetiPremiumState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      availableProducts: availableProducts ?? this.availableProducts,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      lastError: lastError ?? this.lastError,
    );
  }

  PetivetiPremiumState clearError() {
    return copyWith(lastError: null);
  }

  bool get isPremium => status.isPremium;
  bool get isActive => status.isActive;
  bool get isTrialActive => status.isTrialActive;
}

// ============================================================================
// SIMPLE PROVIDERS (FutureProvider)
// ============================================================================

/// Provider para verificar se tem assinatura premium ativa
@riverpod
Future<bool> hasPremiumSubscription(Ref ref) async {
  final repository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await repository.hasPetivetiSubscription();
  return result.fold((failure) => false, (hasPremium) => hasPremium);
}

/// Provider para obter informações da assinatura atual
@riverpod
Future<SubscriptionInfo?> currentSubscription(Ref ref) async {
  final coreRepository = ref.watch(
    local_providers.subscriptionRepositoryProvider,
  );
  final result = await coreRepository.getCurrentSubscription();

  return result.fold((Failure failure) => null, (
    SubscriptionEntity? subscription,
  ) {
    if (subscription == null) return null;

    return SubscriptionInfo(
      productId: subscription.productId,
      isPremium: subscription.isActive,
      isTrialPeriod: subscription.isTrialActive,
      hasUsedTrial: subscription.trialEndDate != null,
      purchaseDate: subscription.purchaseDate,
      expirationDate: subscription.expirationDate,
      originalTransactionId: subscription.id,
    );
  });
}

/// Provider para listar planos disponíveis
@riverpod
Future<List<ProductInfo>> availablePlans(Ref ref) async {
  final coreRepository = ref.watch(
    local_providers.subscriptionRepositoryProvider,
  );
  final result = await coreRepository.getAvailableProducts(
    productIds: PetivetiProducts.allSubscriptions,
  );

  return result.fold(
    (Failure failure) => <ProductInfo>[],
    (List<ProductInfo> products) => products,
  );
}

/// Provider para verificar acesso a feature específica
@riverpod
Future<bool> hasFeatureAccess(Ref ref, String featureKey) async {
  final repository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await repository.hasFeatureAccess(featureKey);
  return result.fold(
    (failure) => PetivetiFeatures.isFreeFeature(featureKey),
    (hasAccess) => hasAccess,
  );
}

/// Provider para verificar se trial está ativo
@riverpod
Future<bool> hasActiveTrial(Ref ref) async {
  final repository = ref.watch(appSubscriptionRepositoryProvider);
  final result = await repository.hasActiveTrial();
  return result.fold((failure) => false, (hasTrial) => hasTrial);
}

/// Provider simples de subscription (compatibilidade com SubscriptionState do core)
@riverpod
Future<bool> subscription(Ref ref) async {
  return ref.watch(hasPremiumSubscriptionProvider.future);
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

/// Informações de assinatura simplificadas (para UI)
class SubscriptionInfo {
  final String productId;
  final bool isPremium;
  final bool isTrialPeriod;
  final bool hasUsedTrial;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final String? originalTransactionId;
  final EntitlementInfo? entitlementInfo;

  const SubscriptionInfo({
    required this.productId,
    required this.isPremium,
    this.isTrialPeriod = false,
    this.hasUsedTrial = false,
    this.purchaseDate,
    this.expirationDate,
    this.originalTransactionId,
    this.entitlementInfo,
  });

  bool get isActive =>
      isPremium && (expirationDate?.isAfter(DateTime.now()) ?? false);
  bool get isExpired => !isActive && expirationDate != null;

  int get daysUntilExpiration {
    if (expirationDate == null) return -1;
    return expirationDate!.difference(DateTime.now()).inDays;
  }
}

// ============================================================================
// LOCAL STORAGE IMPLEMENTATION
// ============================================================================

/// Repository de armazenamento local simplificado (implementação em memória)
/// Usada para cache temporário de status premium
/// TODO: Substituir por SharedPreferences ou Drift para persistência real
class _SimpleLocalStorageRepository implements ILocalStorageRepository {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _ttlExpiry = {};

  @override
  Future<Either<Failure, void>> initialize() async => const Right(null);

  @override
  Future<Either<Failure, T?>> get<T>({required String key, String? box}) async {
    try {
      final value = _cache[key];
      if (value == null) return const Right(null);
      return Right(value as T);
    } catch (e) {
      return Left(CacheFailure('Erro ao ler cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> save<T>({
    required String key,
    required T data,
    String? box,
  }) async {
    try {
      _cache[key] = data;
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao salvar cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> remove({
    required String key,
    String? box,
  }) async {
    try {
      _cache.remove(key);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao remover cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clear({String? box}) async {
    try {
      _cache.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao limpar cache: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> contains({
    required String key,
    String? box,
  }) async {
    return Right(_cache.containsKey(key));
  }

  @override
  Future<Either<Failure, List<String>>> getKeys({String? box}) async {
    return Right(_cache.keys.toList());
  }

  @override
  Future<Either<Failure, List<T>>> getValues<T>({String? box}) async {
    try {
      return Right(_cache.values.cast<T>().toList());
    } catch (e) {
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, int>> length({String? box}) async {
    return Right(_cache.length);
  }

  @override
  Future<Either<Failure, void>> saveList<T>({
    required String key,
    required List<T> data,
    String? box,
  }) async {
    _cache[key] = data;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<T>>> getList<T>({
    required String key,
    String? box,
  }) async {
    try {
      final data = _cache[key];
      if (data == null) return const Right([]);
      return Right(List<T>.from(data as List));
    } catch (e) {
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, void>> addToList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    final list = _cache[key] as List? ?? [];
    list.add(item);
    _cache[key] = list;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFromList<T>({
    required String key,
    required T item,
    String? box,
  }) async {
    final list = _cache[key] as List?;
    if (list != null) {
      list.remove(item);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveWithTTL<T>({
    required String key,
    required T data,
    required Duration ttl,
    String? box,
  }) async {
    _cache[key] = data;
    _ttlExpiry[key] = DateTime.now().add(ttl);
    return const Right(null);
  }

  @override
  Future<Either<Failure, T?>> getWithTTL<T>({
    required String key,
    String? box,
  }) async {
    final expiry = _ttlExpiry[key];
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      _cache.remove(key);
      _ttlExpiry.remove(key);
      return const Right(null);
    }
    return get<T>(key: key);
  }

  @override
  Future<Either<Failure, void>> cleanExpiredData({String? box}) async {
    final now = DateTime.now();
    final expiredKeys = _ttlExpiry.entries
        .where((e) => now.isAfter(e.value))
        .map((e) => e.key)
        .toList();
    for (final key in expiredKeys) {
      _cache.remove(key);
      _ttlExpiry.remove(key);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveUserSetting({
    required String key,
    required dynamic value,
  }) async {
    _cache['user_setting_$key'] = value;
    return const Right(null);
  }

  @override
  Future<Either<Failure, T?>> getUserSetting<T>({
    required String key,
    T? defaultValue,
  }) async {
    final value = _cache['user_setting_$key'];
    if (value == null) return Right(defaultValue);
    return Right(value as T);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllUserSettings() async {
    final settings = <String, dynamic>{};
    for (final entry in _cache.entries) {
      if (entry.key.startsWith('user_setting_')) {
        settings[entry.key.replaceFirst('user_setting_', '')] = entry.value;
      }
    }
    return Right(settings);
  }

  @override
  Future<Either<Failure, void>> saveOfflineData<T>({
    required String key,
    required T data,
    DateTime? lastSync,
  }) async {
    _cache['offline_$key'] = OfflineData<T>(
      data: data,
      createdAt: DateTime.now(),
      lastSync: lastSync,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, OfflineData<T>?>> getOfflineData<T>({
    required String key,
  }) async {
    final data = _cache['offline_$key'];
    if (data == null) return const Right(null);
    return Right(data as OfflineData<T>);
  }

  @override
  Future<Either<Failure, void>> markAsSynced({required String key}) async {
    final data = _cache['offline_$key'];
    if (data != null && data is OfflineData) {
      _cache['offline_$key'] = OfflineData(
        data: data.data,
        createdAt: data.createdAt,
        lastSync: DateTime.now(),
        isSynced: true,
      );
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<String>>> getUnsyncedKeys() async {
    final unsyncedKeys = <String>[];
    for (final entry in _cache.entries) {
      if (entry.key.startsWith('offline_') && entry.value is OfflineData) {
        final offlineData = entry.value as OfflineData;
        if (offlineData.needsSync) {
          unsyncedKeys.add(entry.key.replaceFirst('offline_', ''));
        }
      }
    }
    return Right(unsyncedKeys);
  }
}
