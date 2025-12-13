import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../data/revenue_cat_service.dart';

final customerInfoProvider = FutureProvider<CustomerInfo?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getCustomerInfo();
});

final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return await service.getOfferings();
});

final isPremiumProvider = Provider<bool>((ref) {
  final customerInfoAsync = ref.watch(customerInfoProvider);
  final service = ref.watch(revenueCatServiceProvider);
  
  return customerInfoAsync.when(
    data: (customerInfo) => service.isPremium(customerInfo),
    loading: () => false,
    error: (_, __) => false,
  );
});
