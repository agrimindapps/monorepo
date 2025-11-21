import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rate_limiter_service.dart';
import '../services/data_cleaner_service.dart';

part 'services_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
RateLimiterService rateLimiterService(RateLimiterServiceRef ref) {
  return RateLimiterService();
}

@Riverpod(keepAlive: true)
DataCleanerService dataCleanerService(DataCleanerServiceRef ref) {
  // DataCleanerService might have dependencies, let's check its constructor
  return DataCleanerService();
}
