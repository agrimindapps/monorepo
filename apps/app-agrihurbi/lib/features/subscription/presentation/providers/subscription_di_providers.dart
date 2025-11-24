
import 'package:core/core.dart';


import '../../data/datasources/subscription_local_datasource.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/subscription_usecases.dart';

// External Services
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final coreSubscriptionRepositoryProvider = Provider<ISubscriptionRepository>((ref) {
  return RevenueCatService();
});

// Data Sources
final subscriptionLocalDataSourceProvider = Provider<SubscriptionLocalDataSource>((ref) {
  return SubscriptionLocalDataSourceImpl();
});

final subscriptionRemoteDataSourceProvider = Provider<SubscriptionRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final subscriptionRepository = ref.watch(coreSubscriptionRepositoryProvider);
  return SubscriptionRemoteDataSourceImpl(
    firestore: firestore,
    subscriptionRepository: subscriptionRepository,
  );
});

// Repository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final localDataSource = ref.watch(subscriptionLocalDataSourceProvider);
  final remoteDataSource = ref.watch(subscriptionRemoteDataSourceProvider);
  return SubscriptionRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// Use Cases
final getAvailablePlansProvider = Provider<GetAvailablePlans>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return GetAvailablePlans(repository);
});

final getCurrentSubscriptionProvider = Provider<GetCurrentSubscription>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return GetCurrentSubscription(repository);
});

final subscribeToPlanProvider = Provider<SubscribeToPlan>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscribeToPlan(repository);
});

final cancelSubscriptionProvider = Provider<CancelSubscription>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return CancelSubscription(repository);
});

final pauseSubscriptionProvider = Provider<PauseSubscription>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return PauseSubscription(repository);
});

final resumeSubscriptionProvider = Provider<ResumeSubscription>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return ResumeSubscription(repository);
});

final upgradePlanProvider = Provider<UpgradePlan>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return UpgradePlan(repository);
});

final restorePurchasesProvider = Provider<RestorePurchases>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return RestorePurchases(repository);
});
