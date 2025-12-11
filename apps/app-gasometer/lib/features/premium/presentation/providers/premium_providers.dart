import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/subscription_local_repository.dart';
import '../../../../database/sync/adapters/subscription_drift_sync_adapter.dart';
import '../../../auth/presentation/providers/auth_usecase_providers.dart';
import '../../data/adapters/auth_repository_adapter.dart';
import '../../data/datasources/premium_firebase_data_source.dart';
import '../../data/datasources/premium_local_data_source.dart';
import '../../data/datasources/premium_remote_data_source.dart';
import '../../data/datasources/premium_webhook_data_source.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../../data/services/premium_sync_service.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/can_add_fuel_record.dart';
import '../../domain/usecases/can_add_maintenance_record.dart';
import '../../domain/usecases/can_add_vehicle.dart';
import '../../domain/usecases/can_use_feature.dart';
import '../../domain/usecases/check_premium_status.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/manage_local_license.dart';
import '../../domain/usecases/purchase_premium.dart';
import '../../domain/usecases/restore_purchases.dart';

// Stub subscription repository for apps without subscription feature
class StubSubscriptionRepository implements core.ISubscriptionRepository {
  @override
  Stream<core.SubscriptionEntity?> get subscriptionStatus => Stream.value(null);

  @override
  Future<Either<core.Failure, bool>> hasActiveSubscription() async =>
      const Right(false);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity?>>
  getCurrentSubscription() async => const Right(null);

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
  getUserSubscriptions() async => const Right([]);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>> getAvailableProducts({
    required List<String> productIds,
  }) async => const Right([]);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async => const Left(core.UnknownFailure('Not implemented'));

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
  restorePurchases() async => const Right([]);

  @override
  Future<Either<core.Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async => const Right(null);

  @override
  Future<Either<core.Failure, void>> setUserAttributes({
    required Map<String, String> attributes,
  }) async => const Right(null);

  @override
  Future<Either<core.Failure, bool>> isEligibleForTrial({
    required String productId,
  }) async => const Right(false);

  @override
  Future<Either<core.Failure, String?>> getManagementUrl() async =>
      const Right(null);

  @override
  Future<Either<core.Failure, String?>> getSubscriptionManagementUrl() async =>
      const Right(null);

  @override
  Future<Either<core.Failure, void>> cancelSubscription({
    String? reason,
  }) async => const Right(null);

  @override
  Future<Either<core.Failure, bool>> hasPlantisSubscription() async =>
      const Right(false);

  @override
  Future<Either<core.Failure, bool>> hasReceitaAgroSubscription() async =>
      const Right(false);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
  getPlantisProducts() async => const Right([]);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
  getReceitaAgroProducts() async => const Right([]);

  @override
  Future<Either<core.Failure, bool>> hasGasometerSubscription() async =>
      const Right(false);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
  getGasometerProducts() async => const Right([]);
}

final subscriptionRepositoryProvider = Provider<core.ISubscriptionRepository>((
  ref,
) {
  if (kDebugMode && kIsWeb) {
    return core.MockSubscriptionService();
  }
  return StubSubscriptionRepository();
});

// Stub for apps without subscription feature
class PremiumRemoteDataSourceStub implements PremiumRemoteDataSource {
  @override
  Stream<core.SubscriptionEntity?> get subscriptionStatus => Stream.value(null);

  @override
  Future<Either<core.Failure, bool>> hasActiveSubscription() async =>
      const Right(false);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity?>>
  getCurrentSubscription() async => const Right(null);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
  getAvailableProducts() async => const Right([]);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> purchaseProduct({
    required String productId,
  }) async => const Left(core.UnknownFailure('Not implemented'));

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
  restorePurchases() async => const Right([]);

  @override
  Future<Either<core.Failure, void>> setUser({
    required String userId,
    Map<String, String>? attributes,
  }) async => const Right(null);

  @override
  Future<Either<core.Failure, String?>> getManagementUrl() async =>
      const Right(null);

  @override
  Future<Either<core.Failure, bool>> isEligibleForTrial() async =>
      const Right(false);
}

// Data Sources
final premiumLocalDataSourceProvider = Provider<PremiumLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(gasometerSharedPreferencesProvider);
  return PremiumLocalDataSourceImpl(sharedPreferences);
});

final premiumRemoteDataSourceProvider = Provider<PremiumRemoteDataSource>((
  ref,
) {
  if (kDebugMode && kIsWeb) {
    final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
    return PremiumRemoteDataSourceImpl(subscriptionRepository);
  }
  // For apps without subscription feature, use a stub
  // final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  // return PremiumRemoteDataSourceImpl(subscriptionRepository);
  return PremiumRemoteDataSourceStub();
});

final subscriptionLocalRepositoryProvider =
    Provider<SubscriptionLocalRepository>((ref) {
      final db = ref.watch(gasometerDatabaseProvider);
      return SubscriptionLocalRepository(db);
    });

final subscriptionSyncAdapterProvider = Provider<SubscriptionDriftSyncAdapter>((
  ref,
) {
  final db = ref.watch(gasometerDatabaseProvider);
  final firestore = FirebaseFirestore.instance;
  final connectivity = ref.watch(core.connectivityServiceProvider);
  return SubscriptionDriftSyncAdapter(db, firestore, connectivity);
});

final premiumFirebaseDataSourceProvider = Provider<PremiumFirebaseDataSource>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return PremiumFirebaseDataSource(FirebaseFirestore.instance, authRepository);
});

final premiumWebhookDataSourceProvider = Provider<PremiumWebhookDataSource>((
  ref,
) {
  return PremiumWebhookDataSource(FirebaseFirestore.instance);
});

// Services
final premiumSyncServiceProvider = Provider<PremiumSyncService>((ref) {
  final remoteDataSource = ref.watch(premiumRemoteDataSourceProvider);
  final firebaseDataSource = ref.watch(premiumFirebaseDataSourceProvider);
  final webhookDataSource = ref.watch(premiumWebhookDataSourceProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final localRepository = ref.watch(subscriptionLocalRepositoryProvider);

  return PremiumSyncService(
    remoteDataSource,
    firebaseDataSource,
    webhookDataSource,
    AuthRepositoryAdapter(authRepository),
    localRepository: localRepository,
  );
});

// Repository
final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  final remoteDataSource = ref.watch(premiumRemoteDataSourceProvider);
  final localDataSource = ref.watch(premiumLocalDataSourceProvider);
  final syncService = ref.watch(premiumSyncServiceProvider);

  return PremiumRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    syncService: syncService,
  );
});

// Use Cases
final checkPremiumStatusProvider = Provider<CheckPremiumStatus>((ref) {
  return CheckPremiumStatus(ref.watch(premiumRepositoryProvider));
});

final canUseFeatureProvider = Provider<CanUseFeature>((ref) {
  return CanUseFeature(ref.watch(premiumRepositoryProvider));
});

final canAddVehicleProvider = Provider<CanAddVehicle>((ref) {
  return CanAddVehicle(ref.watch(premiumRepositoryProvider));
});

final canAddFuelRecordProvider = Provider<CanAddFuelRecord>((ref) {
  return CanAddFuelRecord(ref.watch(premiumRepositoryProvider));
});

final canAddMaintenanceRecordProvider = Provider<CanAddMaintenanceRecord>((
  ref,
) {
  return CanAddMaintenanceRecord(ref.watch(premiumRepositoryProvider));
});

final purchasePremiumProvider = Provider<PurchasePremium>((ref) {
  return PurchasePremium(ref.watch(premiumRepositoryProvider));
});

final getAvailableProductsProvider = Provider<GetAvailableProducts>((ref) {
  return GetAvailableProducts(ref.watch(premiumRepositoryProvider));
});

final restorePurchasesProvider = Provider<RestorePurchases>((ref) {
  return RestorePurchases(ref.watch(premiumRepositoryProvider));
});

final generateLocalLicenseProvider = Provider<GenerateLocalLicense>((ref) {
  return GenerateLocalLicense(ref.watch(premiumRepositoryProvider));
});

final revokeLocalLicenseProvider = Provider<RevokeLocalLicense>((ref) {
  return RevokeLocalLicense(ref.watch(premiumRepositoryProvider));
});
