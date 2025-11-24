import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/auth_interceptor.dart';
import '../services/premium_service.dart';

// Core Services Providers
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final secureStorageProvider = Provider<EnhancedSecureStorageService>((ref) {
  return EnhancedSecureStorageService(appIdentifier: 'app_agrihurbi');
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthService();
});

final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return FirebaseAnalyticsService();
});

final crashlyticsRepositoryProvider = Provider<ICrashlyticsRepository>((ref) {
  return FirebaseCrashlyticsService();
});

final performanceRepositoryProvider = Provider<IPerformanceRepository>((ref) {
  return PerformanceService();
});

final subscriptionRepositoryProvider = Provider<ISubscriptionRepository>((ref) {
  return RevenueCatService();
});

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final analyticsRepository = ref.watch(analyticsRepositoryProvider);
  
  // PremiumService expects concrete implementations or interfaces?
  // Based on injection_container.dart: PremiumService(RevenueCatService, FirebaseAnalyticsService)
  // Assuming PremiumService takes interfaces or concrete classes.
  // Let's assume it takes what we pass.
  return PremiumService(
    subscriptionRepository as RevenueCatService, 
    analyticsRepository as FirebaseAnalyticsService
  );
});

final dioServiceProvider = Provider<DioService>((ref) {
  final dioService = DioService();
  dioService.addInterceptor(AuthInterceptor());
  return dioService;
});
