import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart' as core;
import 'package:dartz/dartz.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../auth/presentation/providers/auth_usecase_providers.dart';
import '../../data/datasources/premium_local_data_source.dart';
import '../../data/datasources/premium_remote_data_source.dart';
import '../../data/datasources/premium_firebase_data_source.dart';
import '../../data/datasources/premium_webhook_data_source.dart';
import '../../data/services/premium_sync_service.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/check_premium_status.dart';
import '../../domain/usecases/can_use_feature.dart';
import '../../domain/usecases/can_add_vehicle.dart';
import '../../domain/usecases/can_add_fuel_record.dart';
import '../../domain/usecases/can_add_maintenance_record.dart';
import '../../domain/usecases/purchase_premium.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/manage_local_license.dart';

// Stub subscription repository for apps without subscription feature
class StubSubscriptionRepository implements core.ISubscriptionRepository {
  @override
  Stream<core.SubscriptionEntity?> get subscriptionStatus => Stream.value(null);

  @override
  Future<Either<core.Failure, bool>> hasActiveSubscription() async =>
      Right(false);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity?>>
      getCurrentSubscription() async => Right(null);

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
      getUserSubscriptions() async => Right([]);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>> getAvailableProducts(
          {required List<String> productIds}) async =>
      Right([]);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> purchaseProduct(
          {required String productId}) async =>
      Left(core.UnknownFailure('Not implemented'));

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
      restorePurchases() async => Right([]);

  @override
  Future<Either<core.Failure, void>> setUser(
          {required String userId, Map<String, String>? attributes}) async =>
      Right(null);

  @override
  Future<Either<core.Failure, void>> setUserAttributes(
          {required Map<String, String> attributes}) async =>
      Right(null);

  @override
  Future<Either<core.Failure, bool>> isEligibleForTrial(
          {required String productId}) async =>
      Right(false);

  @override
  Future<Either<core.Failure, String?>> getManagementUrl() async => Right(null);

  @override
  Future<Either<core.Failure, String?>> getSubscriptionManagementUrl() async =>
      Right(null);

  @override
  Future<Either<core.Failure, void>> cancelSubscription(
          {String? reason}) async =>
      Right(null);

  @override
  Future<Either<core.Failure, bool>> hasPlantisSubscription() async =>
      Right(false);

  @override
  Future<Either<core.Failure, bool>> hasReceitaAgroSubscription() async =>
      Right(false);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
      getPlantisProducts() async => Right([]);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
      getReceitaAgroProducts() async => Right([]);

  @override
  Future<Either<core.Failure, bool>> hasGasometerSubscription() async =>
      Right(false);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
      getGasometerProducts() async => Right([]);
}

final subscriptionRepositoryProvider =
    Provider<core.ISubscriptionRepository>((ref) {
  return StubSubscriptionRepository();
});

// Stub for apps without subscription feature
class PremiumRemoteDataSourceStub implements PremiumRemoteDataSource {
  @override
  Stream<core.SubscriptionEntity?> get subscriptionStatus => Stream.value(null);

  @override
  Future<Either<core.Failure, bool>> hasActiveSubscription() async =>
      Right(false);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity?>>
      getCurrentSubscription() async => Right(null);

  @override
  Future<Either<core.Failure, List<core.ProductInfo>>>
      getAvailableProducts() async => Right([]);

  @override
  Future<Either<core.Failure, core.SubscriptionEntity>> purchaseProduct(
          {required String productId}) async =>
      Left(core.UnknownFailure('Not implemented'));

  @override
  Future<Either<core.Failure, List<core.SubscriptionEntity>>>
      restorePurchases() async => Right([]);

  @override
  Future<Either<core.Failure, void>> setUser(
          {required String userId, Map<String, String>? attributes}) async =>
      Right(null);

  @override
  Future<Either<core.Failure, String?>> getManagementUrl() async => Right(null);

  @override
  Future<Either<core.Failure, bool>> isEligibleForTrial() async => Right(false);
}

// Data Sources
final premiumLocalDataSourceProvider = Provider<PremiumLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(gasometerSharedPreferencesProvider);
  return PremiumLocalDataSourceImpl(sharedPreferences);
});

final premiumRemoteDataSourceProvider =
    Provider<PremiumRemoteDataSource>((ref) {
  // For apps without subscription feature, use a stub
  // final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  // return PremiumRemoteDataSourceImpl(subscriptionRepository);
  return PremiumRemoteDataSourceStub();
});

final premiumFirebaseDataSourceProvider =
    Provider<PremiumFirebaseDataSource>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return PremiumFirebaseDataSource(
      FirebaseFirestore.instance, authRepository as core.IAuthRepository);
});

final premiumWebhookDataSourceProvider =
    Provider<PremiumWebhookDataSource>((ref) {
  return PremiumWebhookDataSource(FirebaseFirestore.instance);
});

// Services
final premiumSyncServiceProvider = Provider<PremiumSyncService>((ref) {
  final remoteDataSource = ref.watch(premiumRemoteDataSourceProvider);
  final firebaseDataSource = ref.watch(premiumFirebaseDataSourceProvider);
  final webhookDataSource = ref.watch(premiumWebhookDataSourceProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return PremiumSyncService(
    remoteDataSource,
    firebaseDataSource,
    webhookDataSource,
    authRepository as core.IAuthRepository,
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

final canAddMaintenanceRecordProvider =
    Provider<CanAddMaintenanceRecord>((ref) {
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
